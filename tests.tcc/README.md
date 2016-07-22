# About

This repository provides the support materials for reproducing the research presented in the Raphael P. Ribeiro undergraduate final project.

# How to run the tests

Requirements:

* Julia v0.4.5 (64-bit) 
    * [Linux](https://julialang.s3.amazonaws.com/bin/linux/x64/0.4/julia-0.4.5-linux-x86_64.tar.gz) 
    * [OS X](https://s3.amazonaws.com/julialang/bin/osx/x64/0.4/julia-0.4.5-osx10.7+.dmg)
* sshpass
* cmake

Install dependencies
```
$ julia InstallDeps.jl
```

Generate data
```
$ julia run_tests.jl
```

Plotting data
```
$ julia plot.jl
```
