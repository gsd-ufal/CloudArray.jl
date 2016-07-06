using CloudArray
using DataFrames

tic()
CloudArray.set_host("cloudarray.ddns.net","cloudarray@")
host_time=toc()

function run_tests(reps)
    data = zeros(reps,5)
    for i in 1:reps
        time = CloudArray.create_containers(1,0,512,tunnel=true)
        push!(time,host_time+sum(time))
        data[i,1:5] = time
    end
    return data
end
    
data = run_tests(10)
data = DataFrame(data)
#rename!(data,:x1,:execution)
#rename!(data,:x2,:execution_time)
writetable("test.csv",data)
