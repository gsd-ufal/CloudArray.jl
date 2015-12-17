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

#TODO passar essas variáveis para o usuário como parâmetro
#TODO criar um help

executions= 1
chunks = 1
#Input file. You also can use or generate an Array, just like this ---> input = [1:100]
input = "big_input.txt" 

#The max memory size used by the DArray in every containner
chunk_size = 10_KBYTE_
#first test = 200KB
#Second test = 50KB

#The folder where the output will be store ---> format output_folder/input/'data_execution_'[git commit ID]_[current date/time]
output_folder = "tests_output"
###=============================================================================


#Case study 1: parallel map
#TODO: parallel map
#Case study 2: parallel reduce
parallel_reduce(f,darray) = reduce(f, map(fetch, { @spawnat p reduce(f, localpart(darray)) for p in workers()} ))

darray = dzeros(1)


#Output data treatment
commit = chomp(readall(`git log --format="%H" -n 1 `))
mkpath(string(output_folder,"/",input))
path  = string(output_folder,"/",input,"/","data_execution_",commit,"_",Dates.now(),".txt")
touch(path)
output_file = open(path,"a")

#Get the input file size and calculate the chunks usage
input_file = open(input)
input_size = stat(input_file).size
close(input_file)
chunk_size = Int64(round(input_size*2))


#It loops 'execution' times and in each iteration it uses as many chunks as the iteration number.
#eg in iteration 4 it will create a CloudArray wit 4 chunks and in iteration 2 it will create a carray with 2 chunks
#Note: for some values the number may be shifted by +-1
for i=1:chunks
	eval_time = Array(Float64,1)
	for j=1:executions
	
		println("___________________")
		println("Test loop with ",i," cores. Evaluation: ",j," out of ",executions,"")
		#println("\nTest call ",j," out of ",executions,"\n Starting carray using ",i," chunks")
		println("___________________")

		#creates a cloudarray with the given input	
		carray  = DArray(input,chunk_size)
		#Get the amount of chunks in the new carray
		n_chunks = length(carray.chunks) 
		println("CArray created with ",n_chunks," chunk(s) of ",chunk_size," for bytes each chunk\n")
	
		#Here is what the test happens: it runs the parallel_reduce function and calculates its execution time with tic() toc()
		tic() 
		parallel_reduce(+,carray) 
		#Does the evaluation and stores the time		
		push!(eval_time,toc())				 
		#clear the variable
		carray = dzeros(1)
		@everywhere gc()



		if j==executions
			
			#Lower the chunk_size for each iteration to increase the chunks. The input is always the same(i.e. same size)
		
			if n_chunks > 1
				chunk_size = Int64(trunc(chunk_size - chunk_size/n_chunks))					
			else				
				chunk_size = Int64(trunc(chunk_size/2))
			end
			
			eval_mean = mean(eval_time)
			write(output_file,string(n_chunks,",",eval_mean,"\n"))		
			flush(output_file)	
			#we remove all containers and all data in order to free resources and start a new step in the loop
			delete_containers(all)										
		end

		
	end
end

#flush and close the IO link to the log output
flush(output_file)
close(output_file)

