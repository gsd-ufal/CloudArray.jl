

files = readdir()

step1= Float64[]
step2= Float64[]
step3= Float64[]

for (f in files)
	dataset = readtable(f)
	step1 = [step1,mean(dataset[1])]	
	step2 = [step2,mean(dataset[2])]	
	step3 = [step3,mea(dataset[3])]	
end


xlabel("X: Resume size (% of data set)")
ylabel("Y: Execution time (seconds)")
grid("on")



errorbar(x, # Original x data points, N values
    y, # Original y data points, N values
    yerr=errs, # Plus/minus error ranges, Nx2 values
    fmt="o") # Format




errorbar()
x=[100,50,25,15.5,6.25,3.125,1.5325]


errorbar(x, # Original x data points, N values
    y, # Original y data points, N values
    yerr=errs, # Plus/minus error ranges, Nx2 values
    fmt="o") # Format




errorbar(X,step1,yerr=[step1*0.9,y*1.1])


