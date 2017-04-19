setwd("~/Desktop/Parallel-Computing")

seq_full = read.table("./results/mandelbrot_seq/full.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
omp_full = read.table("./results/mandelbrot_omp/full.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
pth_full = read.table("./results/mandelbrot_pth/full.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)

seq_elephant = read.table("./results/mandelbrot_seq/elephant.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
omp_elephant = read.table("./results/mandelbrot_omp/elephant.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
pth_elephant = read.table("./results/mandelbrot_pth/elephant.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)

seq_seahorse = read.table("./results/mandelbrot_seq/seahorse.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
omp_seahorse = read.table("./results/mandelbrot_omp/seahorse.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
pth_seahorse = read.table("./results/mandelbrot_pth/seahorse.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)

seq_triplesp = read.table("./results/mandelbrot_seq/triple_spiral.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
omp_triplesp = read.table("./results/mandelbrot_omp/triple_spiral.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
pth_triplesp = read.table("./results/mandelbrot_pth/triple_spiral.log", header = FALSE, sep = "\t", stringsAsFactors = FALSE)

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
                     "./mandelbrot_seq" = {"seq"},
                     "./mandelbrot_omp" = {"omp"},
                     "./mandelbrot_pth" = {"seq"},
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
    image = image,
    nthreads = nthreads,
    imsize = imsize,
    task_clock = task_clock,
    context_switches = context_switches,
    cpu_migrations = cpu_migrations,
    page_faults = page_faults,
    cycles = cycles,
    stalled_cycles_frontend = stalled_cycles_frontend,
    instructions = instructions,
    branches = branches,
    branches_misses = branches_misses,
    time_elapsed = time_elapsed
  )
  
}

results <- do.call("rbind", lapply(results, read_result))
