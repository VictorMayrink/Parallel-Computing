#include <math.h>
#include <time.h>
#include <stdio.h>

enum step {alloc, calc, ioops};

void start_timers(double cpu_start[], struct timespec wc_start[], enum step s);
void end_timers(double cpu_end[], struct timespec wc_end[], enum step s);
void print_elapsed(double cpu_start[], struct timespec wc_start[], double cpu_end[], struct timespec wc_end[]);
void print_like_time(double cpu_start[], struct timespec wc_start[], double cpu_end[], struct timespec wc_end[]);
