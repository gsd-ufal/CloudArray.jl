module ImageProcessingService
function initiate(image_id::Int64, business_model)
end

function set_up_VM(resource_requirements)
end

function book_and_start(VM) #Most likely a VM id, so in this case it would be an integer. TODO
end

function load_time(image_id::Int64)
end

function process(algorithm, summary_size::Tuple{Int64,Int64}, roi::Tuple{Int64,Int64}, start::Tuple{Int64,Int64}) #roi --> [(x1,y1),(x2,y2)]
	roi=(100,100) #temp
	summary_size=(10,10) #temp
	start = (1,1)
	yRoiLeng = roi[1]
	xRoiLeng = roi[2]
	ySummSizeLeng = summary_size[1]
	xSummSizeLeng = summary_size[2]
	rowStep = Int64(round(yRoiLeng/ySummSizeLeng))
	colStep = Int64(round(xRoiLeng/xSummSizeLeng))

	subArray = dataset[start[1]:roi[1]+start[1], start[2]:roi[2]+start[2]]

	if (  (start[1] + roi[1] > length(dataset[:,1])) || 
		  (start[2] + roi[2] > length(dataset[1,:])) ) 
		println("Your region of interest overleaps the image size.")
	end




	buf = ones(10,10) 
    img = ones(10,10)
    iterations = 1       
	f(a) = 10*(a[-1,-1]+ a[-1,+1] + a[-1,0] + a[0,+1]+a[0,-1],a[+1,+1]+a[+1,0],a[+1,-1])

    runStencil(buf, img, iterations, :oob_skip) do b, a
       b[0,0] = f(a)
       return a, b
    end

	



end

function view(output_id::Int64, format::AbstractString)
end

function stop_and_get_bill()
end

function get_bill()
end

end