#This library is used to plot the data
# more: https://github.com/dcjones/Gadfly.jl
using Gadfly


@doc """
Takes an Array of pair length, like: [a,b,c,d,e,f,g,h] and returns
2 arrays splited in half -> [a,b,c,d] [e,f,g,h]
call: a,b = split_indexes(myArray)
""" ->
function split_indexes(input::Array)
	mid = length(input)/2
	tail = length(input)	
	return input[1:mid], input[mid+1:tail]
end



@doc """
It takes the raw data stored in /tests_output/input_data and fetch it in the layer() format in order to make the data readable for Gadfly
The raw data format is: n lines with pairs of numbers (one int and one float) separated by a coma, just like:
1,0.5
2,3.10
""" ->
function gadfly_output(input_data::AbstractString)
	logs_dir = joinpath(realpath("."),"tests_output",input_data)	
	layers = layer(x=[],y=[],Geom.point)
	logs = readdir(logs_dir)		
	for i in logs
		data = readdlm(joinpath(logs_dir,i),',')
		X, Y = split_indexes(data)	
        Ymin = 0.9*Y
        Ymax = 1.1*Y
		layers = vcat(layers,layer(x=X,y=Y, ymin=Ymin, ymax=Ymax, Geom.errorbar, Geom.line, Geom.point))
	end
	
	return(layers)
end

@doc """
Takes an input path for a data which has been used to create a DArray(input_data::AbstractString, debug=true), gadfly the data with gadfly_output(...) and plots it.
""" ->
function plot_tests(input_data::AbstractString)
	plot(gadfly_output(input_data),Guide.title("Parallel reduce execution"),Guide.xlabel("Amount of chunks"),Guide.ylabel("Time to reduce (s)"))
end
