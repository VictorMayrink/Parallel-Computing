OUTPUT=mandelbrot

IMAGE=.ppm

CC=gcc
CC_OPT=-std=c11

CC_OMP=-fopenmp
CC_PTH=-pthread

.PHONY: all
all: $(OUTPUT)_omp_withIO $(OUTPUT)_pth_withIO $(OUTPUT)_seq_withIO $(OUTPUT)_omp_withoutIO $(OUTPUT)_pth_withoutIO $(OUTPUT)_seq_withoutIO 

$(OUTPUT)_omp_withIO: $(OUTPUT)_omp_withIO.c
	$(CC) -o $(OUTPUT)_omp_withIO $(CC_OPT) $(CC_OMP) $(OUTPUT)_omp_withIO.c

$(OUTPUT)_pth_withIO: $(OUTPUT)_pth_withIO.c
	$(CC) -o $(OUTPUT)_pth_withIO $(CC_OPT) $(CC_PTH) $(OUTPUT)_pth_withIO.c

$(OUTPUT)_seq_withIO: $(OUTPUT)_seq_withIO.c
	$(CC) -o $(OUTPUT)_seq_withIO $(CC_OPT) $(OUTPUT)_seq_withIO.c

$(OUTPUT)_omp_withoutIO: $(OUTPUT)_omp_withoutIO.c
	$(CC) -o $(OUTPUT)_omp_withoutIO $(CC_OPT) $(CC_OMP) $(OUTPUT)_omp_withoutIO.c

$(OUTPUT)_pth_withoutIO: $(OUTPUT)_pth_withoutIO.c
	$(CC) -o $(OUTPUT)_pth_withoutIO $(CC_OPT) $(CC_PTH) $(OUTPUT)_pth_withoutIO.c

$(OUTPUT)_seq_withoutIO: $(OUTPUT)_seq_withoutIO.c
	$(CC) -o $(OUTPUT)_seq_withoutIO $(CC_OPT) $(OUTPUT)_seq_withoutIO.c

.PHONY: clean
clean:
	rm $(OUTPUT)_omp_withIO $(OUTPUT)_pth_withIO $(OUTPUT)_seq_withIO
	rm $(OUTPUT)_omp_withoutIO $(OUTPUT)_pth_withoutIO $(OUTPUT)_seq_withoutIO
	rm *$(IMAGE)
