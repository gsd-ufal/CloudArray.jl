###=============================================================================
#
#          FILE: CloudArrayDaemon.jl
# 
#         USAGE: include("CloudArrayDaemon.jl")
# 
#   DESCRIPTION: it generates unique numbers that will be used by Infra.jl to set as Docker containers' port as each Master launches its own Infra.jl.
# 
#       OPTIONS: ---
#  DEPENDENCIES: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: André Lage Freitas
#  ORGANIZATION: GSD-UFAL
#       CREATED: 2015-10-21 18:30
###=============================================================================

# DISCLAIMER: based on examples from:
# 	https://github.com/JuliaWeb/HttpServer.jl/tree/master/examples

using HttpServer

counter = (Int)[]

@doc """
### HttpHandler() do req::Request, res::Response

Answers HTTP request with a unique number which 
is used by Infra.jl to set Docker containers' port numbers.

```Example
TODO
```
""" ->
http = HttpHandler() do req::Request, res::Response
	push!(counter,1) # counter++
	current_port_number = "$(length(counter))"
    Response(current_port_number)
end

my_port = 8000

# HttpServer supports setting handlers for particular events
http.events["listen"] = (saddr) -> println("CloudArray daemon is running on https://$(saddr).")

server = Server(http) #create a server from your HttpHandler
run(server, port=my_port) 
