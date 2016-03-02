function save_tests()	

	data = readtable("output.csv")
	
	step1 = plot_step(data,"Step1")
	save_svg(step1,"Step1")

	step2 = plot_step(data,"Step2")
	save_svg(step2,"Step2")

	step3fix = plot_step(data,"Step3Fixed")
	save_svg(step3fix,"Step3Fixed")

	step1rand = plot_step(data,"Step3Random")
	save_svg(step1rand,"Step3Random")	
end

function plot_step(data::DataFrame, step::AbstractString)
	theme = Theme(default_color=colorant"gray",panel_fill=colorant"white")
	return plot(data,y=step,x=DataFrame(A=[step])[1],Geom.boxplot, theme)
end

function save_svg(layer::Plot, step::AbstractString)
	img = SVG(step, 6inch, 4inch)
	draw(img, layer)
end
