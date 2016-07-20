module ImageProcessingService
function initiate(image_id::Int64, business_model)
end

function set_up_VM(resource_requirements)
end

function book_and_start(VM) #Most likely a VM id, so in this case it would be an integer. TODO
end

function load_time(image_id::Int64)
end



#Sample algorithm
f(a) = (a[-1,-1]+ a[-1,+1] + a[-1,0] + a[0,+1]+a[0,-1],a[+1,+1]+a[+1,0],a[+1,-1])

function process(algorithm=f, summary_size::Tuple{Int64,Int64}=(10,10), roi::Tuple{Int64,Int64}=(3,3), start::Tuple{Int64,Int64} = (3,2)) #roi --> [(x1,y1),(x2,y2)]
	yRoiLeng = roi[1]
	xRoiLeng = roi[2]
	ySummSizeLeng = summary_size[1]
	xSummSizeLeng = summary_size[2]
	rowStep = Int64(round(yRoiLeng/ySummSizeLeng))
	colStep = Int64(round(xRoiLeng/xSummSizeLeng))

	

	if (  (start[1] + roi[1] > length(dataset[:,1])) || 
		  (start[2] + roi[2] > length(dataset[1,:])) ) 
		println("Your region of interest overleaps the image size.")
	else 
		#get the roiSubArray from dataset. This subarra is delimited by the size of the window (roi) and the starting index (start)
		roiSubArray = dataset[start[1]:roi[1]+start[1]-1, start[2]:roi[2]+start[2]-1] 

		buffer = ones(xRoiLeng,yRoiLeng) 
		iterations = 1       
		

	@acc runStencil(buffer, roiSubArray, iterations, :oob_src_zero) do b, a
       b[0,0] = algorithm(a)        
       return a, b
    end
    print(roiSubArray)
    print("\n")
    return buffer
	end
end

function view(output_id::Int64, format::AbstractString)
end

function stop_and_get_bill()
end

function get_bill()
end

end