font_size = 30
files = readdir()

step1= Float64[]
step2= Float64[]
step3= Float64[]
stepall= Float64[]
first_csv=readtable(files[1])
table_size = length(first_csv[:Step1]) #I only wanna check the size of the table, it could use Step2 or 3

global_ci = []

for (f in files)
	dataset = readtable(f)
	mean1 = mean(dataset[:Step1])	
	mean2 = mean(dataset[:Step2])
	mean3 = mean(dataset[:Step3])
	
	all_time = dataset[:Step1]+dataset[:Step2]+dataset[:Step3]
	current_ci = ci(OneSampleTTest(all_time))


	ci_spam = current_ci[2]-current_ci[1]
	mean_all = mean(all_time)


	step1 = [step1,mean1]	
	step2 = [step2,mean2]	
	step3 = [step3,mean3]
	stepall = [stepall, mean_all]
	global_ci = [global_ci,ci_spam]


total_time = step1+step2+step3
	
end





ylabel("Execution time (seconds)", fontsize = font_size*1.25)
grid("on")
tick_params(axis="y", labelsize=30)
tick_params(axis="x", labelsize=30)



x=[1.5325,3.125,6.25,15.5,25.0,50]/100 # image cut % (the machine failed in 100%)
x=x*35.1

raw_intervals_1 = readtable("../scenario\ 1")
sc1_step1_intervals =  raw_intervals_1[:step1high]-raw_intervals_1[:step1low]
sc1_step2_intervals =  raw_intervals_1[:step2high]-raw_intervals_1[:step2low]
sc1_step3_intervals =  raw_intervals_1[:step3high]-raw_intervals_1[:step3low]





xlabel("Summary physical size (GB)",fontsize = 1.25*font_size)
errorbar(x,stepall,color="black",fmt="-",label="Total",linewidth=4)
errorbar(x,step2,fmt="-",color="black",label="Pauli decomposition",linewidth=2)
errorbar(x,step1,fmt="--",color="black",label="Data loading",linewidth=2)
errorbar(x,step3,fmt=":",color="black",label="Visualization",linewidth=2)
legend(loc=2, fontsize = font_size)

errorbar(x,stepall,yerr = global_ci,fmt="-",color="black",label="Total",linewidth=4)
errorbar(x,step1,yerr = sc1_step1_intervals,fmt="--",color="black",label="Data loading",linewidth=2)
errorbar(x,step2,yerr = sc1_step2_intervals,fmt="-",color="black",label="Pauli decomposition",linewidth=2)
errorbar(x,step3,yerr = sc1_step3_intervals,fmt=":",color="black",label="Visualization",linewidth=2)

errorbar(x,step3,yerr = sc1_step3_intervals,fmt=".",color="black",label="Visualization",linewidth=2)

















tick_params(axis="y", labelsize=30)
tick_params(axis="x", labelsize=30)

raw_intervals_2 = readtable("../scenario\ 2")
sc2_step1_intervals =  raw_intervals_2[:step1high]-raw_intervals_2[:step1low]
sc2_step2_intervals =  raw_intervals_2[:step2high]-raw_intervals_2[:step2low]
sc2_step3_intervals =  raw_intervals_2[:step3high]-raw_intervals_2[:step3low]

x=[1.5325,3.125,6.25,15.5,25.0,50,100] # image cut % (the machine failed in 100%)

ylabel("Execution time (seconds)", fontsize = 1.25*font_size)
xlabel("Size of region of interest (% of data set size)",fontsize = 1.25*font_size)

#:. pontilhado
#-- tracejado
#- cheio

#Total, Pauli, Loading, Visu
errorbar(x,stepall,color="black",label="Total",linewidth=4)
errorbar(x,step2,fmt="-",color="black",label="Pauli decomposition",linewidth=2)
errorbar(x+1,step1,fmt="--",color="black",label="Data loading",linewidth=2,capsize=10)
errorbar(x-0.5,step3,fmt=":",color="black",label="Visualization",linewidth=2,capsize=10)

legend(loc=2, fontsize = font_size) 


errorbar(x+1,step1,yerr = sc2_step1_intervals,fmt="--",color="black",label="Data loading",linewidth=2,capsize=10)
errorbar(x,step2,yerr = sc2_step2_intervals,fmt="-",color="black",label="Pauli decomposition",linewidth=2,capsize=15)
errorbar(x-0.5,step3,yerr = sc2_step3_intervals,fmt=":.",color="black",label="Visualization",linewidth=2,capsize=10)




errorbar(x,stepall,yerr = global_ci,fmt="-",color="black",label="Total",linewidth=4,capsize=30)

grid("on")




curva da Data loading com linha tracejada
curva da Pauli com linha cheia
curva da Visualization com linha pontilhada




















