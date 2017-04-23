#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>
#include "time_utils.h"

#define RGB_SIZE 3
#define ESCAPE_RADIUS 4
#define GRADIENT_SIZE 16
#define MAX_ITERATIONS 200

double cx_min;
double cx_max;
double cy_min;
double cy_max;

int ix_max;
int iy_max;

double pixel_width;
double pixel_height;

int image_size;
int image_buffer_size;
unsigned char **image_buffer;

int nthreads;
int current_iy;
omp_lock_t stacklock;

int colors[GRADIENT_SIZE + 1][RGB_SIZE] = {
    {66, 30, 15},
    {25, 7, 26},
    {9, 1, 47},
    {4, 4, 73},
    {0, 7, 100},
    {12, 44, 138},
    {24, 82, 177},
    {57, 125, 209},
    {134, 181, 229},
    {211, 236, 248},
    {241, 233, 191},
    {248, 201, 95},
    {255, 170, 0},
    {204, 128, 0},
    {153, 87, 0},
    {106, 52, 3},
    {0, 0, 0},
};

#define STEPS_SIZE 3

void allocate_image_buffer(){

    image_buffer = (unsigned char **) malloc(sizeof(unsigned char *) * image_buffer_size);

    for (int i = 0; i < image_buffer_size; i++) {
        image_buffer[i] = (unsigned char *) malloc(sizeof(unsigned char) * RGB_SIZE);
    };

};

void init(int argc, char *argv[]){

    if (argc < 7) {

        printf("usage: ./mandelbrot_pth cx_min cx_max cy_min cy_max nthreads image_size\n");
        printf("examples with image_size = 11500:\n");
        printf("    Full Picture:         ./mandelbrot_pth -2.5 1.5 -2.0 2.0 8 11500\n");
        printf("    Seahorse Valley:      ./mandelbrot_pth -0.8 -0.7 0.05 0.15 8 11500\n");
        printf("    Elephant Valley:      ./mandelbrot_pth 0.175 0.375 -0.1 0.1 8 11500\n");
        printf("    Triple Spiral Valley: ./mandelbrot_pth -0.188 -0.012 0.554 0.754 8 11500\n");
        exit(0);

    } else {

        current_iy = 0;

        sscanf(argv[1], "%lf", &cx_min);
        sscanf(argv[2], "%lf", &cx_max);
        sscanf(argv[3], "%lf", &cy_min);
        sscanf(argv[4], "%lf", &cy_max);
        sscanf(argv[5], "%d", &nthreads);
        sscanf(argv[6], "%d", &image_size);

        ix_max = image_size;
        iy_max = image_size;
        image_buffer_size = image_size * image_size;

        pixel_width = (cx_max - cx_min) / ix_max;
        pixel_height = (cy_max - cy_min) / iy_max;

    };

};

void update_rgb_buffer(int iteration, int x, int y){

    if (iteration == MAX_ITERATIONS) {

        image_buffer[(iy_max * y) + x][0] = colors[GRADIENT_SIZE][0];
        image_buffer[(iy_max * y) + x][1] = colors[GRADIENT_SIZE][1];
        image_buffer[(iy_max * y) + x][2] = colors[GRADIENT_SIZE][2];

    } else {

        int color = iteration % GRADIENT_SIZE;

        image_buffer[(iy_max * y) + x][0] = colors[color][0];
        image_buffer[(iy_max * y) + x][1] = colors[color][1];
        image_buffer[(iy_max * y) + x][2] = colors[color][2];

    };

};

void write_to_file() {

    FILE * file;
    char * filename = "output.ppm";
    char * comment = "# ";

    int max_color_component_value = 255;

    file = fopen(filename,"wb");

    fprintf(file, "P6\n %s\n %d\n %d\n %d\n", comment,
            ix_max, iy_max, max_color_component_value);

    for(int i = 0; i < image_buffer_size; i++){
        fwrite(image_buffer[i], 1 , 3, file);
    };

    fclose(file);
};

void compute_mandelbrot(){

    int tid;

    omp_set_dynamic(0);
    omp_set_num_threads(nthreads);

    #pragma omp parallel private(nthreads, tid)
    {
        tid = omp_get_thread_num();

        int iteration;

        double cx;
        double cy;
        double zx;
        double zy;
        double zx_squared;
        double zy_squared;

        int iy;
        int ix;

        omp_set_lock(&stacklock);
        iy = current_iy++;
        omp_unset_lock(&stacklock);

        while (iy < image_size) {

            cy = cy_min + iy * pixel_height;

            for (int ix = 0; ix < image_size; ix++) {

                cx = cx_min + ix * pixel_width;

                zx = 0.0;
                zy = 0.0;

                zx_squared = 0.0;
                zy_squared = 0.0;

                for(iteration = 0;
                    iteration < MAX_ITERATIONS && \
                    ((zx_squared + zy_squared) < ESCAPE_RADIUS);
                    iteration++){

                    zy = 2 * zx * zy + cy;
                    zx = zx_squared - zy_squared + cx;

                    zx_squared = zx * zx;
                    zy_squared = zy * zy;
                };

                update_rgb_buffer(iteration, ix, iy);

            };

            omp_set_lock(&stacklock);
            iy = current_iy++;
            omp_unset_lock(&stacklock);

        };


    };

};

int main(int argc, char *argv[]){

    omp_init_lock(&stacklock);

    init(argc, argv);
    struct timespec wc_start[STEPS_SIZE], wc_end[STEPS_SIZE];
    double cpu_start[STEPS_SIZE], cpu_end[STEPS_SIZE];

    start_timers(cpu_start, wc_start, alloc);
    allocate_image_buffer();
    end_timers(cpu_end, wc_end, alloc);

    start_timers(cpu_start, wc_start, calc);
    compute_mandelbrot();
    end_timers(cpu_end, wc_end, calc);

    start_timers(cpu_start, wc_start, ioops);
    write_to_file();
    end_timers(cpu_end, wc_end, ioops);

    print_like_time(cpu_start, wc_start, cpu_end, wc_end);

    return 0;
};
