###=============================================================================
#
#          FILE: Infra.jl
# 
#         USAGE: include("../Infra.jl") 
# 
#   DESCRIPTION: Julia interface to launch containers through Azure VM
# 
#       OPTIONS: ---
#  DEPENDENCIES: sshpass
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raphael P. Ribeiro <raphaelpr01@gmail.com>
#  ORGANIZATION: GSD-UFAL
#       CREATED: 23-09-2015 17:16
#          TODO:
#               - Error handling
#               - Optimize addprocs
#
###=============================================================================

using Requests

###== Top-level variables ======================================================

global host=""
global passwd=""
const ssh_key=homedir()*"/.ssh/azkey"
const ssh_pubkey=homedir()*"/.ssh/azkey.pub"

###=============================================================================

# TODO: using module to make this call only at pre-compile time 
run(`chmod +x $(Pkg.dir("CloudArray"))/src/cloud_setup.sh`)

type Container # Abstraction for Docker container
          cid::AbstractString
          pid::Integer 
          n_of_cpus::Integer
          mem_size::Integer
      
          function Container(cid,pid,n_of_cpus=0,mem_size=512)
              return new(cid,pid,n_of_cpus,mem_size)
          end
end

const map_containers = Dict{Integer, Container}()

let next_key = 1    # cid -> container id
    global get_next_key
    function get_next_key() retval = next_key
        next_key += 1
        retval
    end
end

@doc """
### set_host(h::AbstractString,p::AbstractString)

Set a Virtual Machine to host containers.

(Requires sshpass)

```Example
set_host("cloudarray01.cloudapp.net","password")
```
""" ->
function set_host(h::AbstractString,p::AbstractString)
    reply = success(`./cloud_setup.sh $h $p`) # set up ssh. if errors occurs, return false
    if (reply)
        global host=h
        global passwd=p
        true
    else
        println("ERROR: There is an error during SSH configuration. Please see the log for more details: cloud_setup.log")
        false
    end
end

function get_port()
      response = get("http://$host:8000")
      parse(Int,join(map(Char,response.data)))
end

@doc """
### create_containers(n_of_containers::Integer, n_of_cpus::Integer, mem_size::Integer)

Launch container(s) and adds as a worker via SSH.
Requires sshpass.

```Example
create_containers(2,3,1024) # 2 containers with 3 CPU Cores and 1gb RAM
create_containers(1,2,512)  # 1 container with 2 CPU Cores and 512mb RAM
```
""" ->
function create_containers(n_of_containers::Integer, n_of_cpus=0, mem_size=512)
        reserved_mem=200 # reserved memory for initializing a worker into a container 
        mem_size=mem_size+reserved_mem
        for i in 1:n_of_containers
            key = get_next_key()
            port = 3000+get_port()
            # Creating a docker container in VM
            println("Creating container ($key)...")
            @time cid = readall(`ssh -i $ssh_key -o StrictHostKeyChecking=no dockeru@$host "docker run -d -p 0.0.0.0:$port:22/tcp --cpuset-cpus="$n_of_cpus" -m=$(mem_size)M cloudarray:latest"`)
            # Configuring ssh without password (transfer public key to container)
            println("SSH configuration ($key)... ")
            @time run(pipeline(`cat $ssh_pubkey`,`sshpass -p $passwd ssh -o StrictHostKeyChecking=no -p $port root@$host 'umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys'`))
            println("Adding worker ($key)...")
            @time pid = addprocs(["root@$host"]; tunnel=true,sshflags=`-i $ssh_key -p $port`,dir="/opt/julia/bin")
            map_containers[key] = Container(chomp(cid),pid[1],n_of_cpus,mem_size) # Adding Container to Dict
        end
end

@doc """
### delete_containers(args...)

Removes the specified container(s)/worker(s).

```Example
delete_containers(3)    # delete container 3
create_containers(1:5)  # delete from 1st to 5th container
create_containers(all)  # delete all containers
```
""" ->
function delete_containers(args...) #  (splat) variable number of arguments. Ex.: delete_containers(1,2,3) or delete_containers(1:3)
    containers_rmlist = ""
    if vcat(args...)[1] == all
        for i in collect(keys(map_containers))
            if haskey(map_containers, i) # container exist?
                container = map_containers[i]
                rmprocs(container.pid)
                delete!(map_containers,i)
                containers_rmlist = containers_rmlist*" $(container.cid)" # adding Counter ID to string
            end
        end
    else
        for i in vcat(args...) # vcat -> concatenate to a array 1 dimension
            if haskey(map_containers, i) # container exist?
                container = map_containers[i]
                rmprocs(container.pid)
                delete!(map_containers,i)
                containers_rmlist = containers_rmlist*" $(container.cid)" # adding Counter ID to string
            end
        end
    end
    if (!isempty(containers_rmlist))
            run(`ssh -i $ssh_key dockeru@$host "docker rm -f $containers_rmlist"`) # deleting containers from Docker
    end
end


@doc """
```Example
containers()
```

Returns a list of all containers processes identifiers.

""" ->
function containers()
    sort(collect(keys(map_containers)))
end

@doc """
```Example
ncontainers()
```

Get the number of available containers processes.

""" ->
function ncontainers()
    length(map_containers)
end

@doc """
### list_containers()
```Example
list_containers()
```

List container(s) as a sorted list.

""" ->
function list_containers()
    for key in sort(collect(keys(map_containers)))
           println("$key => $(map_containers[key])")

    end
end

@doc """
### mem_usage(key::Integer)

Returns the specified container memory usage via SSH.

```Example
mem_usage(2)
```
""" ->
function mem_usage(key::Integer)
    container = map_containers[key]
    memory = readall(`ssh -i $ssh_key dockeru@$host "cat /sys/fs/cgroup/memory/docker/$(container.cid)/memory.usage_in_bytes"`)
    parse(Int,memory)/10^6 # convert byte to Megabytes (MB)
    # returns float
end
