#include(".../Cloudarray_time_test.jl")
#
#   DESCRIPTION: Tests the CloudArray construtor method in order to get it's cloud management execution time
#		 It will apply the function call parallel_reduce(+,darray) to the created carray
# 		 For a sequencial array (eg. 1:100) it should return an arithmetic progression ---> (n[1]+n[last])*n/2 which results 5050 in the 1:100 case	
#		 
#
#       OPTIONS: ---
#  DEPENDENCIES: Infra.jl, DistributedArrays.jl, CloudArray.jl, PyPlot.jl, sshpass
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Naelson Douglas C. Oliveira
#  ORGANIZATION: GSD-UFAL
#       CREATED: 2015-10-09 05:32
###=============================================================================



	

#To use simple plots: https://github.com/nolta/Winston.jl


#include("CloudArray.jl")
#run(`source cloud_setup.sh`)
#include("../Infra.jl")
#include("../CloudArray.jl")

const _BYTE_ = 1
const _KBYTE_ = 1024_BYTE_
const _MBYTE_ = 1024_KBYTE_
const _GBYTE_ = 1024_MBYTE_
const _PBYTE_ = 1024_GBYTE_
###=========================User interface=======================================
#How many times you want the code to run on the same input?

#TODO passar essas variáveis para o usuário
executions=20
#Input file. You also can use or generate an Array, just like this ---> input = [1:100]
input = "input_float_test.csv" 

#The max memory size used by the DArray in every containner
containers_memory = 10_KBYTE_
#first test = 200KB
#Second test = 50KB

#The folder where the output will be store ---> format output_folder/input/'data_execution_'[git commit ID]_[current date/time]
output_folder = "tests_output"
###=============================================================================

parallel_reduce(f,darray) = reduce(f, map(fetch, { @spawnat p reduce(f, localpart(darray)) for p in workers()} ))

darray = dzeros(1)

commit = chomp(readall(`git log --format="%H" -n 1 `))
mkpath(string(output_folder,"/",input))
path  = string(output_folder,"/",input,"/","data_execution_",commit,"_",Dates.now(),".txt")
touch(path)
output_file = open(path,"a")

input_file = open(input)
input_size = stat(input_file).size
close(input_file)

containers_memory = input_size*2 #one extra KB


for i=1:executions	

	
	println("___________________")
	println("\nTest call ",i," out of ",executions,"\nStarting carray with a maximum of ",containers_memory/1024,"KB for each chunk by")
	println("___________________")
	carray  = DArray(input,containers_memory)
	n_chunks = length(carray.chunks)
	println("CArray created with ",n_chunks," chunks of ",containers_memory," for bytes each chunk\n")
	
	tic() 
	parallel_reduce(+,carray) #Does the evaluation and stores the time
	eval_time = toc() 

	write(output_file,string(n_chunks,",",eval_time,"\n"))		
	
	delete_containers(all)	
	
	gc()	
	containers_memory = Int64(trunc(input_size/i)) 
	rmprocs(workers())
end

 flush(output_file)
close(output_file)



