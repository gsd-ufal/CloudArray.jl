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
function f(a::Real) 
 (a[-1,-1]+ a[-1,+1] + a[-1,0] + a[0,+1]+a[0,-1]+a[+1,+1]+a[+1,0]+a[+1,-1])
end

function process(algorithm=f, summary_size::Tuple{Int64,Int64}=(4,4), roi::Tuple{Int64,Int64}=(8,8), start::Tuple{Int64,Int64} = (1,1)) #roi --> [(x1,y1),(x2,y2)]

print("Input size: ",size(dataset))
print("\n")
print("Summary size: ",summary_size)
print("\n")
print("Roi size: ",roi)
print("\n")
print("Starting point: ",start)
print("\n")
print("\n")
print("Input dataset: \n", dataset)
print("\n\n")

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
	print(roiSubArray)
	

	resized = Real[]


	for (y=1:colStep:size(roiSubArray)[2])

		if (mod(colStep,y) != 0 || y==1)
			column = Real[]

			for (x=1:rowStep:size(roiSubArray)[1])
				if (mod(rowStep, x) != 0 || x == 1)

					push!(column, roiSubArray[x,y])
				end
			end

			if (y==1) #This is a workarround. Fix it later (flag WK)
				resized = column
			end	
			
			resized = hcat(resized, column)

			if (y==1) #This is undoing the workarround of flag WK
				resized = resized[:,2]
			end
		end
	end

	print("\n\n")
	print("Summary without filter: \n")
	print(resized)
	print("\n")
	

		xSummaryLeng = size(resized)[1]
		ySummaryLeng = size(resized)[2]


		buffer = Array(Real,xSummaryLeng,ySummaryLeng) 
		iterations = 1


	runStencil(buffer, resized, iterations, :oob_src_zero) do b, a
       b[0,0] =  algorithm(a)
       return a, b
    end
    
    print("\n \n")
    print("Summary with filter (sum of neighbors): \n")
    print(buffer)
    print("\n \n")
    print("\n \n")
    print("\n \n")
	
    
    return buffer
	end
end

process()
print("\n")

#end