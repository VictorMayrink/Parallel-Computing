#! /bin/bash

set -o xtrace

MEASUREMENTS=20
ITERATIONS=10
INITIAL_SIZE=16

NTHREADS=('1' '2' '4' '8' '16' '32')

make
mkdir results_time

#MANDELBROT: Sequential (with I/O)
mkdir results_time/mandelbrot_seq
SIZE=$INITIAL_SIZE
for ((i=1; i<=$ITERATIONS; i++)); do
    for ((r = 1; r<=MEASUREMENTS; r++)); do
        (time ./mandelbrot_seq_withIO -2.500  1.500 -2.000 2.000 $SIZE) >> full.log 2>&1
        (time ./mandelbrot_seq_withIO -0.800 -0.700  0.050 0.150 $SIZE) >> seahorse.log 2>&1
        (time ./mandelbrot_seq_withIO  0.175  0.375 -0.100 0.100 $SIZE) >> elephant.log 2>&1
        (time ./mandelbrot_seq_withIO -0.188 -0.012  0.554 0.754 $SIZE) >> triplesp.log 2>&1
    done
    SIZE=$(($SIZE * 2))
done

#MANDELBROT: Sequential (without I/O)
mkdir results_time/mandelbrot_seq
SIZE=$INITIAL_SIZE
for ((i=1; i<=$ITERATIONS; i++)); do
    for ((r = 1; r<=MEASUREMENTS; r++)); do
        (time ./mandelbrot_seq_withoutIO -2.500  1.500 -2.000 2.000 $SIZE) >> full.log 2>&1
        (time ./mandelbrot_seq_withoutIO -0.800 -0.700  0.050 0.150 $SIZE) >> seahorse.log 2>&1
        (time ./mandelbrot_seq_withoutIO  0.175  0.375 -0.100 0.100 $SIZE) >> elephant.log 2>&1
        (time ./mandelbrot_seq_withoutIO -0.188 -0.012  0.554 0.754 $SIZE) >> triplesp.log 2>&1
    done
    SIZE=$(($SIZE * 2))
done

mv *.log results_time/mandelbrot_seq
rm output.ppm

#MANDELBROT: OpenMP (without I/O)
mkdir results_time/mandelbrot_omp
SIZE=$INITIAL_SIZE
for THREADS in ${NTHREADS[@]}; do

    for ((i=1; i<=$ITERATIONS; i++)); do
        for ((r = 1; r<=MEASUREMENTS; r++)); do
            (time ./mandelbrot_omp_withoutIO -2.500  1.500 -2.000 2.000 $THREADS $SIZE) >> full.log 2>&1
            (time ./mandelbrot_omp_withoutIO -0.800 -0.700  0.050 0.150 $THREADS $SIZE) >> seahorse.log 2>&1
            (time ./mandelbrot_omp_withoutIO  0.175  0.375 -0.100 0.100 $THREADS $SIZE) >> elephant.log 2>&1
            (time ./mandelbrot_omp_withoutIO -0.188 -0.012  0.554 0.754 $THREADS $SIZE) >> triplesp.log 2>&1
        done
        SIZE=$(($SIZE * 2))
    done

    SIZE=$INITIAL_SIZE

done

mv *.log results_time/mandelbrot_omp
rm output.ppm

#MANDELBROT: Pthreads (without I/O)
mkdir results_time/mandelbrot_pth
SIZE=$INITIAL_SIZE
for THREADS in ${NTHREADS[@]}; do

    for ((i=1; i<=$ITERATIONS; i++)); do
        for ((r = 1; r<=MEASUREMENTS; r++)); do
            (time ./mandelbrot_pth_withoutIO -2.500  1.500 -2.000 2.000 $THREADS $SIZE) >> full.log 2>&1
            (time ./mandelbrot_pth_withoutIO -0.800 -0.700  0.050 0.150 $THREADS $SIZE) >> seahorse.log 2>&1
            (time ./mandelbrot_pth_withoutIO  0.175  0.375 -0.100 0.100 $THREADS $SIZE) >> elephant.log 2>&1
            (time ./mandelbrot_pth_withoutIO -0.188 -0.012  0.554 0.754 $THREADS $SIZE) >> triplesp.log 2>&1
        done
        SIZE=$(($SIZE * 2))
    done

    SIZE=$INITIAL_SIZE

done

mv *.log results_time/mandelbrot_pth
rm output.ppm