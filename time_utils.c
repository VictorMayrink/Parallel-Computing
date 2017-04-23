#include "time_utils.h"

void start_timers(double cpu_start[], struct timespec wc_start[], enum step s){
    cpu_start[s] = (double)clock() /(double) CLOCKS_PER_SEC;
    clock_gettime(CLOCK_MONOTONIC, &wc_start[s]);
}

void end_timers(double cpu_end[], struct timespec wc_end[], enum step s){
    cpu_end[s] = (double)clock() /(double) CLOCKS_PER_SEC;
    clock_gettime(CLOCK_MONOTONIC, &wc_end[s]);
}

void print_elapsed(double cpu_start[], struct timespec wc_start[], double cpu_end[], struct timespec wc_end[]){
    enum step s;

    double wc_elapsed = -1.0, cpu_elapsed = -1.0, wc_total = -1.0, cpu_total = -1.0;
    for (s = alloc; s <= ioops; s++) {
        wc_elapsed = wc_end[s].tv_sec - wc_start[s].tv_sec;
        wc_elapsed += fabs((wc_end[s].tv_nsec - wc_start[s].tv_nsec) / 1000000000.0);
        cpu_elapsed = cpu_end[s] - cpu_start[s];

        wc_total += wc_elapsed;
        cpu_total += cpu_elapsed;
        printf("WC Time: %lf\nCPU Time: %lf\n\n", wc_elapsed, cpu_elapsed);
    }

    printf("Total WC Time: %lf\nTotal CPU Time: %lf\n\n", wc_total, cpu_total);
}

void print_like_time(double cpu_start[], struct timespec wc_start[], double cpu_end[], struct timespec wc_end[]){
    double wc_elapsed = -1.0, cpu_elapsed = -1.0;

    wc_elapsed = wc_end[calc].tv_sec - wc_start[calc].tv_sec;
    wc_elapsed += fabs((wc_end[calc].tv_nsec - wc_start[calc].tv_nsec) / 1000000000.0);
    cpu_elapsed = cpu_end[calc] - cpu_start[calc];

    printf("real    %dm%0.3lfs\nuser    %dm%0.3lfs\nsys     0m0.000s", (int)wc_elapsed/60, wc_elapsed - (int)wc_elapsed/60, (int)cpu_elapsed/60, cpu_elapsed - (int)cpu_elapsed/60);
}