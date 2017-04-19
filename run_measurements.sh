#! /bin/bash

set -o xtrace

MEASUREMENTS=10
ITERATIONS=4
INITIAL_SIZE=16

NTHREADS=('1' '2' '4' '8' '16' '32')

make
mkdir results

#MANDELBROT: Sequential
mkdir results/mandelbrot_seq
SIZE=$INITIAL_SIZE
for ((i=1; i<=$ITERATIONS; i++)); do
    for ((r = 1; r<=MEASUREMENTS; r++)); do
        perf stat -d ./mandelbrot_seq -2.500  1.500 -2.000 2.000 $SIZE >> full.log 2>&1
        perf stat -d ./mandelbrot_seq -0.800 -0.700  0.050 0.150 $SIZE >> seahorse.log 2>&1
        perf stat -d ./mandelbrot_seq  0.175  0.375 -0.100 0.100 $SIZE >> elephant.log 2>&1
        perf stat -d ./mandelbrot_seq -0.188 -0.012  0.554 0.754 $SIZE >> triple_spiral.log 2>&1
    done
    SIZE=$(($SIZE * 2))
done

mv *.log results/mandelbrot_seq
rm output.ppm

#MANDELBROT: OpenMP
mkdir results/mandelbrot_omp
SIZE=$INITIAL_SIZE
for THREADS in ${NTHREADS[@]}; do

    for ((i=1; i<=$ITERATIONS; i++)); do
        for ((r = 1; r<=MEASUREMENTS; r++)); do
            perf stat -d ./mandelbrot_omp -2.500  1.500 -2.000 2.000 $THREADS $SIZE >> full.log 2>&1
            perf stat -d ./mandelbrot_omp -0.800 -0.700  0.050 0.150 $THREADS $SIZE >> seahorse.log 2>&1
            perf stat -d ./mandelbrot_omp  0.175  0.375 -0.100 0.100 $THREADS $SIZE >> elephant.log 2>&1
            perf stat -d ./mandelbrot_omp -0.188 -0.012  0.554 0.754 $THREADS $SIZE >> triple_spiral.log 2>&1
        done
        SIZE=$(($SIZE * 2))
    done

    SIZE=$INITIAL_SIZE

done

mv *.log results/mandelbrot_omp
rm output.ppm

#MANDELBROT: Pthreads
mkdir results/mandelbrot_pth
SIZE=$INITIAL_SIZE
for THREADS in ${NTHREADS[@]}; do

    for ((i=1; i<=$ITERATIONS; i++)); do
        for ((r = 1; r<=MEASUREMENTS; r++)); do
            perf stat -d ./mandelbrot_pth -2.500  1.500 -2.000 2.000 $THREADS $SIZE >> full.log 2>&1
            perf stat -d ./mandelbrot_pth -0.800 -0.700  0.050 0.150 $THREADS $SIZE >> seahorse.log 2>&1
            perf stat -d ./mandelbrot_pth  0.175  0.375 -0.100 0.100 $THREADS $SIZE >> elephant.log 2>&1
            perf stat -d ./mandelbrot_pth -0.188 -0.012  0.554 0.754 $THREADS $SIZE >> triple_spiral.log 2>&1
        done
        SIZE=$(($SIZE * 2))
    done

    SIZE=$INITIAL_SIZE

done

mv *.log results/mandelbrot_pth
rm output.ppm