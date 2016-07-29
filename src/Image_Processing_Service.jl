using ParallelAccelerator
using ImageView
include("/home/naelson/repositories/PolSAR.jl/src/ZoomImage.jl")

#module ImageProcessingService
function initiate(image_id::Int64, business_model)
end

function set_up_VM(resource_requirements)
end

function book_and_start(VM) #Most likely a VM id, so in this case it would be an integer. TODO
end

function load_time(image_id::Int64)
end

function view(output_id::Int64, format::AbstractString)
end

function stop_and_get_bill()
end

function get_bill()
end



#Sample algorithm
function f(a) 
(a[-1,-1]+ a[-1,+1] + a[-1,0] + a[0,+1]+a[0,-1]+a[+1,+1]+a[+1,0]+a[+1,-1])
end


src_height= 11858
src_width = 1650
windowHeight= 11858
windowWidth = 1650
zoomHeight  = 11858
zoomWidth   = 1650
src = open("SanAnd_05508_10007_005_100114_L090HHHH_CX_01.mlc")


function areLimitsWrong(summary_height,src_height,summary_width,src_width,starting_line,roi_height,roi_width,starting_col)
#checking if the summary overleaps the roi
	if (summary_height > src_height || summary_width > src_width)
		println("Your summary size overleaps the ROI size")
		return true	
	end

	#Checking if roi_y > src_y
	if ( (starting_line-1 + roi_height) > src_height)
		println("Starting line: ",starting_line," Roi Height: ",roi_height," SRC height: ", src_height)
		println("Your ROI height overleaps the source height")
		return true
	end
		#Checking if roi_x > src_x
	if (starting_col-1 + roi_width > src_height)
		println("Your ROI width overleaps the source width")
		return true
	end

	return false
end



function process(algorithm=f, summary_size::Tuple{Int64,Int64}=(11858-1,1650-1), roi::Tuple{Int64,Int64}=(11858-1,1650-1), start::Tuple{Int64,Int64} = (1,1); debug::Bool=false, img::IOStream=src) 

	starting_line = start[1]
	starting_col = start[2]	
	starting_pos =  starting_line + (starting_col-1)*src_width

	roi_height = roi[1]
	roi_width = roi[2]

	summary_height = summary_size[1]
	summary_width = summary_size[2]

	row_step = Int64(round(roi_height/summary_height))
	col_step = Int64(round(roi_width/summary_width))	

	#TODO put these checks in one function
	



if (areLimitsWrong(summary_height,src_height,summary_width,src_width,starting_line,roi_height,roi_width,starting_col))
	#The function will print a warning and the program will stop
else 
	##TODO: Fix the ZoomImage function to make it return a matrix instead of an array
	roi_subarray = ZoomImage(starting_pos, roi_height, roi_width, summary_height, summary_width, src_height, src_width, src) 


	println("Deu zoom suave")

	roi_subarray = reshape(roi_subarray, summary_height,summary_width)
	println("Deu reshape suave")
	

	buffer = Array(Real,summary_height,summary_width) 
	iterations = 1
	println("Criou buffer suave")
	runStencil(buffer, roi_subarray, iterations, :oob_src_zero) do b, a
		b[0,0] =  algorithm(a)
		return a, b
	end


	return buffer
end




end



#end
