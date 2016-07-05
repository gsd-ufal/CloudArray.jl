module ImageProcessingService
function initiate(image_id::Int64, business_model)
end

function set_up_VM(resource_requirements)
end

function book_and_start(VM) #Most likely a VM id, so in this case it would be an integer. TODO
end

function load_time(image_id::Int64)
end

function process(algorithm, summary_size::Array{Int64,1}, roi::Array{Tuple{Int64,Int64},1}) #roi --> [(x1,y1),(x2,y2)]
end

function view(output_id::Int64, format::AbstractString)
end

function stop_and_get_bill()
end

function get_bill()
end

end