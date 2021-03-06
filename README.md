#Paper

CloudArray paper was published at [IGARSS 2016](http://www.igarss2016.org): **[CloudArray: Easing huge image processing](http://ieeexplore.ieee.org/document/7729158/)**.

#Table of Contents

1. [Overview](https://github.com/gsd-ufal/CloudArray.jl#overview)
2. [Architecture](https://github.com/gsd-ufal/CloudArray.jl#architecture)
3. [Installation](https://github.com/gsd-ufal/CloudArray.jl#installation)
4. [Usage](https://github.com/gsd-ufal/CloudArray.jl#usage)

# Overview

**CloudArray** ([**<span style="color:blue">try it here!</span>**](http:/cloudarraybox.cloudapp.net/)) is a programming abstraction that eases big data programming in the cloud. CloudArray loads data from files then books and configures the right amount of resources (VMs, containers) able to process it. Data loading and resource management are entirely automatic and performed on-demand. 

CloudArray builds on top of [Julia](http://julialang.org) native [DistributedArrays](https://github.com/JuliaParallel/DistributedArrays.jl) abstraction, a multi-dimensional array whose data is transparently stored at distributed computers. Indeed, _a CloudArray is a DistributedArray whose data and resource managements are automatic_ as the figure bellow illustrates: data load, VM booking, Julia workers configuration on top of Docker containers. 

![CloudArray Architecture](docs/figures/cloudarray_overview.png "CloudArray Architecture")

Therefore, existent codes that use DistributedArrays don't need to be adapted in order to use CloudArray. You just need to include CloudArray and use your cloud account, no need to manually interact with your cloud provider.

You are very welcome to [**<span style="color:red">try CloudArray from CloudArrayBox</span>**](http:/cloudarraybox.cloudapp.net/), a Web front end hosted at Azure.


# Architecture

CloudArray design is composed by two layers (c.f. Figure Architecture):

* **CloudArray.jl** is an extension of [DistributedArrays.jl](https://github.com/JuliaParallel/DistributedArrays.jl) which automatically loads data from files (or other I/O stream) and store it at distributed Workers as DArray.
* **Infra.jl** books virtual machines (VMs) and creates, configures, and instantiates Docker containers on top of VMs. Then Julia Workers are configured and deployed on containers. 
	
![CloudArray Architecture](docs/figures/cloudarray_layers.png "CloudArray Architecture")

# Installation

### Requirements

#### Julia 0.4

[Download Julia 0.4](http://julialang.org/downloads/)

#### `sshpass`

Debian-based Linux distros as Ubuntu or through 

```
sudo apt-get install sshpass 
```

OS X through [macports](http://macports.org):

```
sudo port install sshpass
```

# Usage

First load CloudArray package:

```Julia
using CloudArray
```
Then tell CloudAarray the machine address and the password to passwordless SSH login:


```Julia
CloudArray.set_host(host_address,ssh_password)
```

To use CloudArrayBox VMs to test CloudArray use the following parameters:

```Julia
CloudArray.set_host("cloudarray.ddns.net","cloudarray@")
```

## Execution environment

### CloudArrayBox: Master and Workers

You may [**try CloudArray from your browser (CloudArrayBox)**](http:/cloudarraybox.cloudapp.net/), without installing any software at all. Just login with your Google account and run both Julia interface (Master) and cloud processing backend (Workers). 


We just kindly ask you to not overload our few Azure VMs which are available to Julia community to test CloudArray for free. In other words, please do not run large parallel or high-processing codes.

### Master at your computer and Workers at CloudArrayBox

You can also use CloudArray your computer with your local Julia 0.4 installation ([see installation instructions]([Julia 0.4](http://julialang.org/downloads/))) and use CloudArrayBox to deploy Workers.

### Custom runtime environment

Otherwise, you can define a customized runtime environment with your own cloud provider having Master and Workers configured as you prefer.


## Main constructors


CloudArray main constructors are very simple and can be created by using an `Array` or a file.

### Creating a CloudArray from an `Array`

You just need to tell `DArray` constructor which `Array` should be used to construct your CloudArray:

```
DArray(Array(...))
```

#### Example 

In this example, we first create the array `arr` with 100 random numbers then we create a CloudArray with the `arr` data:

```Julia
arr = rand(100)
cloudarray_from_array = CloudArray.DArray(arr) # will take less than one minute
```

We can now access any `cloudarray_from_array` value as it would be a local array:

```Julia
cloudarray_from_array[57]
```


### Creating a CloudArray from a file

If you are dealing with big data, i.e., your RAM memory is not enough to store your data, you can create a CloudArray from a file.

```Julia
CloudArray.DArray(file_path)
```

```file_path``` is the path to a text file in your local or distributed file system. All lines will be used to fill `DArray` elements sequentially. This constructor ignores empty lines.


#### Example 

Let's first create a simple text file with 100 random numbers. 

```Julia
f = open("data.txt","w+")
for i=1:100
    if i==100
        write(f,"$(rand())")
    else
        write(f,"$(rand())\n")
    end    
end
close(f)
```

Then we create a CloudArray with `data.txt` file.

```Julia
CloudArray.cloudarray_from_file = DArray("data.txt")
```

Let's perform a sum operation at `cloudarray_from_file`:

```Julia
sum(cloudarray_from_file)
```

This sum was performed locally at the Master, you can exploit DArray fully parallelism with further functions such as parallel Maps (`pmap`) and Reductions. See [here more information on Parallel programming in Julia](http://docs.julialang.org/en/latest/manual/parallel-computing/). 

## Core constructor

If you want to tune your CloudArray, you can directly use the CloudArray core constructor:

```julia
carray_from_task(generator::Task=task_from_text("test.txt"), is_numeric::Bool=true, chunk_max_size::Int=1024*1024,debug::Bool=false)
```
Arguments are:

* ```task_from_text``` same as ```file_path```.
* ```is_numeric``` set to ```false``` if you need to load String instead of Float.
* ```chunk_max_size``` sets the maximum size that is allowed for each DArray chunk.
* ```debug``` enables debug mode.

### Example

As follows, we create a CloudArray by using the `data.txt` file which holds numeric values, then second argument is set to `true`. We'll set the third argument (`chunk_max_size`) to `500` so DArray chunks will not have more than 500 bytes each.

```Julia
custom_cloudarray_from_file = DArray("data.txt", true, 500)
```

Now let's define and perform a [parallel reduction](https://www.youtube.com/watch?v=JoRn4ryMclc) at the just-created CloudArray:

```Julia
parallel_reduce(f,darray) = reduce(f, map(fetch, { @spawnat p reduce(f, localpart(darray)) for p in workers()} ))
parallel_reduce(+,custom_cloudarray_from_file)
```

The result is the sum of all values of `custom_cloudarray_from_file`. Each DArray chunk performed in parallel the sum of the part of the DArrau it holds. The result is sent to the Master which performs the final sum. The function `map` is used to get the values with the `fetch` function.


You don't really need to know it, but if you are curious on how your data is stored, you can get further information such as:

```Julia
@show custom_cloudarray_from_file.chunks
@show custom_cloudarray_from_file.cuts
@show custom_cloudarray_from_file.dims
@show custom_cloudarray_from_file.indexes
@show custom_cloudarray_from_file.pids
```

Please read [DistributedArrays documentation](https://github.com/JuliaParallel/DistributedArrays.jl) to better understand these low-level details if you want.

## `Infra.jl` documentation

Infra.jl provides **an interface to manage Docker containers** on top of Ubuntu machines. Infra.jl allows to configure, create, delete, list, and monitors containers as described next.

### set_host(h::AbstractString,p::AbstractString)

Configures passwordless SSH connections at host `h` whose password is `p`.

This function calls the `cloud_setup.sh` script which requires `sshpass`.

```Example
CloudArray.set_host("cloudarray.cloudapp.net","password")
```


### create_containers(n_of_containers::Integer, n_of_cpus::Integer, mem_size::Integer)
Launches Docker containers and adds them as Julia workers configured with passwordless SSH.
This function requires `sshpass` to be installed:

* Debian-based Linux distros as Ubuntu:

```
sudo apt-get install sshpass
```

* OS X through [macports](http://macports.org):

```
sudo port install sshpass
```

```Example
create_containers(2,3,1024) # 2 containers with 3 CPU Cores and 1gb RAM
create_containers(1,2,512)  # 1 container with 2 CPU Cores and 512mb RAM
```

### delete_containers(args...)
Removes the specified container(s)/worker(s).

```Example
delete_containers(3)    # delete container 3
create_containers(1:5)  # delete from 1st to 5th container
create_containers(all)  # delete all containers
```


### containers()
Returns the list of all containers' processes identifiers (IDs).

```Example
containers()
```

### ncontainers()
Gets the number of available container processes.

```Example
ncontainers()
```

### list_containers()

List container(s) as a sorted list.

```Example
list_containers()
```

### mem_usage(key::Integer)
Returns the container memory usage.

```Example
mem_usage(number_of_container)
```

### cpu_usage(key::Integer)
Returns the container CPU usage (%).

```Example
cpu_usage(number_of_container)
```

### io_usage(key::Integer)
Returns the number of kilobytes read and written by the cgroup.

```Example
io_usage(number_of_container)
```

### net_usage(key::Integer)
Returns networking TX/RX usage.

tx = number of bytes transmitted

rx = number of bytes reiceved

```Example
net_usage(number_of_container)
```

## Future Features

* Support other cloud infrastructures
	* Amazon EC2
	* OpenStack
* Set a price threshold
* Provide different QoS
	* E.g., Pricy and fastest vs. Cheapest and not so fast
* Add the following containers monitoring functions:
	* ```io_usage(key::Integer)```
* Let users define which CSV separator should be used
* RESTful API
* CloudDataFrame: extend CloudArray to support DataFrame
* Use Azure REST API
* Redundancy: if Julia fails, it removes containers (mask this fault)
* Create tests
* Use [@acc](https://github.com/IntelLabs/ParallelAccelerator.jl) to improve performance

## BUGFIX

* Explicitly release resources (containers and VMs) after usage
* Use Julia Module to be able to call ```cloud_setup.sh```
* CloudArrayBox logo transparent
* Replace `sshpass` by another means to authenticate through SSH
	* maybe require users' public key?

# Acknowledgements

CloudArray is developed by the LaCCAN lab at the Computing Institute of the Federal University of Alagoas (Brazil). CloudArray is funded by [Microsoft Azure Research Award](http://research.microsoft.com/en-us/projects/azure/), Brazilian National Council for Scientific and Technological Development (CNPq), and Alagoas Research Foundation (FAPEAL).
