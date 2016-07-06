using CloudArray
using DataFrames

function run_tests(reps)
    data = zeros(reps,6)
    for i in 1:reps
        tic()
        CloudArray.set_host("cloudarray.ddns.net","cloudarray@")
        auth_time=toc()
        time = CloudArray.create_containers(1,0,512)
        push!(time,auth_time+sum(time)) # total exec time
        data[i,1] = auth_time
        data[i,2:6] = time
    end
    return data
end

data = run_tests(10)
data = DataFrame(data)
names!(data,[:etapa_1,:etapa_2,:etapa_3,:etapa_4,:etapa_5,:etapa_6])
writetable("output.csv",data)
