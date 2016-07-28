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



function process(algorithm=f, summary_size::Tuple{Int64,Int64}=(4,4), roi::Tuple{Int64,Int64}=(8,8), start::Tuple{Int64,Int64} = (100,10000); debug::Bool=false, img::IOStream=src) 

	#dataset = ones(10,10) #It should be the image. This variable is going to be deleted soon


	starting_line = start[1]
	starting_col = start[2]	
	starting_pos =  starting_line + (starting_col-1)*src_width

	roi_height = roi[1]
	roi_width = roi[2]

	summary_height = summary_size[1]
	summary_width = summary_size[2]
		



	row_step = Int64(round(roi_height/summary_height))
	col_step = Int64(round(roi_width/summary_width))



	if (  (starting_line + roi_height > src_width) || (starting_col + roi_width > src_height) ) 
		println("Your region of interest overleaps the image size.")
		return false
	else 

		roi_subarray = ZoomImage(starting_pos, roi_height, roi_width, summary_height, summary_width, src_height, src_width, src) ##TODO: Fix the ZoomImage function to make it return a matrix instead of an array

		roi_subarray = reshape(roi_subarray, summary_height,summary_width)

		if(debug)
			print("Roi\n")
			show(roi_subarray)
		end

		buffer = Array(Real,summary_width,summary_height) 
		iterations = 1

		runStencil(buffer, roi_subarray, iterations, :oob_src_zero) do b, a
			b[0,0] =  algorithm(a)
			return a, b
		end

		if (debug) 
			print("\n \n")
			print("Summary with filter (sum of neighbors): \n")
			show(buffer)
			print("\n \n \n \n \n \n")
		end
		return buffer
	end
end

process()
print("\n")

#end
