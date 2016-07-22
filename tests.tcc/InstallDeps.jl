default_packages="PyPlot DataFrames"

clone_packages=Dict(
                    "CloudArray"    => "https://github.com/gsd-ufal/CloudArray.jl.git"
                    )

Pkg.update()
installed = Pkg.installed()

# Docker.jl must be the first package
if !haskey(installed,"Docker")
    Pkg.clone("https://github.com/Keno/Docker.jl.git")
end

for pkg in keys(clone_packages)
    if !haskey(installed,pkg) # not installed? Pkg.clone!
        Pkg.clone(clone_packages[pkg])
    end
end

ENV["PYTHON"]=""
Pkg.build("PyCall")

Pkg.update()
