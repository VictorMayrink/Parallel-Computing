setwd("~/Desktop/Parallel-Computing")
library("ggplot2")

seq_full = read.table("./results_perf/mandelbrot_seq/full.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
omp_full = read.table("./results_perf/mandelbrot_omp/full.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
pth_full = read.table("./results_perf/mandelbrot_pth/full.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)

seq_elephant = read.table("./results_perf/mandelbrot_seq/elephant.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
omp_elephant = read.table("./results_perf/mandelbrot_omp/elephant.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
pth_elephant = read.table("./results_perf/mandelbrot_pth/elephant.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)

seq_seahorse = read.table("./results_perf/mandelbrot_seq/seahorse.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
omp_seahorse = read.table("./results_perf/mandelbrot_omp/seahorse.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
pth_seahorse = read.table("./results_perf/mandelbrot_pth/seahorse.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)

seq_triplesp = read.table("./results_perf/mandelbrot_seq/triple_spiral.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
omp_triplesp = read.table("./results_perf/mandelbrot_omp/triple_spiral.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
pth_triplesp = read.table("./results_perf/mandelbrot_pth/triple_spiral.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)

fulldata = rbind(
  seq_full,
  omp_full,
  pth_full,
  seq_elephant,
  omp_elephant,
  pth_elephant,
  seq_seahorse,
  omp_seahorse,
  pth_seahorse,
  seq_triplesp,
  omp_triplesp,
  pth_triplesp
)

names(fulldata) <- "output_line" 

results <- split(fulldata, f = rep(1:(nrow(fulldata)/16), each = 16))

read_result <- function(df) {
  
  output <- lapply(strsplit(df$output_line, "[ :]"), function(x) x[x != ""])
  
  algorithm <- switch(output[[1]][5],
                     "./mandelbrot_seq_withIO" = {"seq"},
                     "./mandelbrot_seq_withoutIO" = {"seq"},
                     "./mandelbrot_omp_withoutIO" = {"omp"},
                     "./mandelbrot_pth_withoutIO" = {"pth"},
                     stop("Algorithm unrecognized."))
  
  iomode <- switch(output[[1]][5],
                      "./mandelbrot_seq_withIO" = {"withIO"},
                      "./mandelbrot_seq_withoutIO" = {"withoutIO"},
                      "./mandelbrot_omp_withoutIO" = {"withoutIO"},
                      "./mandelbrot_pth_withoutIO" = {"withoutIO"},
                      stop("Algorithm unrecognized."))
  
  image <- switch(output[[1]][6],
                 "-2.500" = {"full"},
                 "-0.800" = {"seahorse"},
                 "0.175"  = {"elephant"},
                 "-0.188" = {"triple_spiral"},
                 stop("Image unrecognized."))
  
  nthreads <- if (algorithm == "seq") 1 else as.numeric(output[[1]][10])
  imsize <- if (algorithm == "seq") as.numeric(output[[1]][10]) else as.numeric(output[[1]][11])
  
  task_clock <- as.numeric(gsub(",", "", output[[2]][1]))
  context_switches <- as.numeric(gsub(",", "", output[[3]][1]))
  cpu_migrations <- as.numeric(gsub(",", "", output[[4]][1]))
  page_faults <- as.numeric(gsub(",", "", output[[5]][1]))
  cycles <- as.numeric(gsub(",", "", output[[6]][1]))
  stalled_cycles_frontend <- as.numeric(gsub(",", "", output[[7]][1]))
  instructions <- as.numeric(gsub(",", "", output[[8]][1]))
  branches <- as.numeric(gsub(",", "", output[[10]][1]))
  branches_misses <- as.numeric(gsub(",", "", output[[11]][1]))
  time_elapsed <- as.numeric(gsub(",", "", output[[16]][1]))
  
  results <- data.frame(
    algorithm = algorithm,
    iomode = iomode,
    image = image,
    nthreads = nthreads,
    imsize = imsize,
    task_clock = task_clock,
    context_switches = context_switches,
    cpu_migrations = cpu_migrations,
    page_faults = page_faults,
    cycles = {if(cycles == 0) NA else cycles},
    stalled_cycles_frontend = stalled_cycles_frontend,
    instructions = instructions,
    branches = branches,
    branches_misses = branches_misses,
    time_elapsed = time_elapsed
  )
  
}

results <- do.call("rbind", lapply(results, read_result))


size8192 = results[results$imsize == 8192 & results$iomode == "withoutIO",]

fig1 <- ggplot(data = size8192, aes(x = as.factor(nthreads), y = time_elapsed, color = algorithm)) +
  geom_boxplot() +
  facet_wrap(~image, scales = "free") +
  ggtitle("Tempo de Execução x Número de Threads (Tamanho da imagem fixado em 256)") +
  xlab("Número de threads") +
  ylab("Tempo de execução (s)") +
  guides(color = guide_legend(title="Implementação")) +
  theme(plot.title = element_text(hjust = 0.5, vjust = 5, size = 20),
        strip.text = element_text(size= 16),
        axis.title = element_text(size = 16),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12),
        axis.text = element_text(size = 12),
        axis.title.y=element_text(vjust=5),
        axis.title.x=element_text(vjust=-65),
        plot.margin = unit(c(1,1,1,1), "cm"))

pdf("boxplot8192.pdf", width = 16, height = 9)
print(fig1)
dev.off()



# size1024omp = results2[results2$imsize == 1024 & results2$algorithm == "omp",]
# 
# pdf("boxplot.pdf", width = 10, height = 10)
# ggplot(data = size1024, aes(x = as.factor(nthreads), y = time_elapsed)) +
#   geom_boxplot() +
#   facet_wrap(~image)
# dev.off()























