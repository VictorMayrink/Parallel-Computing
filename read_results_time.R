setwd("~/Desktop/Parallel-Computing")
library("ggplot2")

seq_full = read.csv("./results_time/mandelbrot_seq/full.log", header = F, stringsAsFactors = F)
omp_full = read.csv("./results_time/mandelbrot_omp/full.log", header = F, stringsAsFactors = F)
pth_full = read.csv("./results_time/mandelbrot_pth/full.log", header = F, stringsAsFactors = F)

seq_elephant = read.csv("./results_time/mandelbrot_seq/elephant.log", header = F, stringsAsFactors = F)
omp_elephant = read.csv("./results_time/mandelbrot_omp/elephant.log", header = F, stringsAsFactors = F)
pth_elephant = read.csv("./results_time/mandelbrot_pth/elephant.log", header = F, stringsAsFactors = F)

seq_seahorse = read.csv("./results_time/mandelbrot_seq/seahorse.log", header = F, stringsAsFactors = F)
omp_seahorse = read.csv("./results_time/mandelbrot_omp/seahorse.log", header = F, stringsAsFactors = F)
pth_seahorse = read.csv("./results_time/mandelbrot_pth/seahorse.log", header = F, stringsAsFactors = F)

seq_triplesp = read.csv("./results_time/mandelbrot_seq/triplesp.log", header = F, stringsAsFactors = F)
omp_triplesp = read.csv("./results_time/mandelbrot_omp/triplesp.log", header = F, stringsAsFactors = F)
pth_triplesp = read.csv("./results_time/mandelbrot_pth/triplesp.log", header = F, stringsAsFactors = F)

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

results <- split(fulldata, f = rep(1:(nrow(fulldata)/4), each = 4))

read_result <- function(df) {
  
  header <- strsplit(df$output_line[1], "[ ]")[[1]]
  real <- strsplit(df$output_line[2], "[\tm]")[[1]]
  user <- strsplit(df$output_line[3], "[\tm]")[[1]]
  sys  <- strsplit(df$output_line[4], "[\tm]")[[1]]
  
  algorithm <- switch(header[2],
                     "./mandelbrot_seq_withIO" = {"seq"},
                     "./mandelbrot_seq_withoutIO" = {"seq"},
                     "./mandelbrot_omp_withoutIO" = {"omp"},
                     "./mandelbrot_pth_withoutIO" = {"pth"},
                     stop("Algorithm unrecognized."))
  
  iomode <- switch(header[2],
                      "./mandelbrot_seq_withIO" = {"withIO"},
                      "./mandelbrot_seq_withoutIO" = {"withoutIO"},
                      "./mandelbrot_omp_withoutIO" = {"withoutIO"},
                      "./mandelbrot_pth_withoutIO" = {"withoutIO"},
                      stop("Algorithm unrecognized."))
  
  image <- switch(header[3],
                 "-2.500" = {"full"},
                 "-0.800" = {"seahorse"},
                 "0.175"  = {"elephant"},
                 "-0.188" = {"triple_spiral"},
                 stop("Image unrecognized."))
  
  nthreads <- if (algorithm == "seq") 1 else as.numeric(header[7])
  imsize <- if (algorithm == "seq") as.numeric(header[7]) else as.numeric(header[8])
  
  real <- 60*as.numeric(real[2]) + as.numeric(gsub("s", "", real[3]))
  user <- 60*as.numeric(user[2]) + as.numeric(gsub("s", "", user[3]))
  sys <- 60*as.numeric(sys[2]) + as.numeric(gsub("s", "", sys[3]))

  results <- data.frame(
    algorithm = algorithm,
    iomode = iomode,
    image = image,
    nthreads = nthreads,
    imsize = imsize,
    user = user,
    real = real,
    sys = sys
  )
  
}

results <- do.call("rbind", lapply(results, read_result))

size256 = results[results$imsize == 256 & results$iomode == "withoutIO",]

fig1 <- ggplot(data = size256, aes(x = as.factor(nthreads), y = real, color = algorithm)) +
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

pdf("boxplot.pdf", width = 16, height = 9)
  print(fig1)
dev.off()
