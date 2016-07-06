using PyPlot

font_size = 13
data = readcsv("output.csv")
data = map(Float64,data[1:size(data,1) .!= 1,: ])

boxplot(data)
ylabel("Tempo de execução (segundos)", fontsize = font_size*1.25)
xlabel("Etapas", fontsize = font_size*1.25)
grid("on")
tick_params(axis="y", labelsize=font_size)
tick_params(axis="x", labelsize=font_size)

savefig(string("plot-",time(),".png"))
PyPlot.close()
