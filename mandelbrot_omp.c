#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>

#define NUM_THREADS	8
#define ESCAPE_RADIUS 4
#define MAX_ITERATIONS 200

double cx_min;
double cx_max;
double cy_min;
double cy_max;

double pixel_width;
double pixel_height;

omp_lock_t stacklock;

int image_size;
int current_col;
unsigned char **image_buffer;

int ix_max;
int iy_max;
int image_buffer_size;

int gradient_size = 16;
int colors[17][3] = {
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

void allocate_image_buffer(){
    int rgb_size = 3;
    image_buffer = (unsigned char **) malloc(sizeof(unsigned char *) * image_buffer_size);

    for(int i = 0; i < image_buffer_size; i++){
        image_buffer[i] = (unsigned char *) malloc(sizeof(unsigned char) * rgb_size);
    };
};

void init(int argc, char *argv[]){
    if(argc < 6){
        printf("usage: ./mandelbrot_pth c_x_min c_x_max c_y_min c_y_max image_size\n");
        printf("examples with image_size = 11500:\n");
        printf("    Full Picture:         ./mandelbrot_pth -2.5 1.5 -2.0 2.0 11500\n");
        printf("    Seahorse Valley:      ./mandelbrot_pth -0.8 -0.7 0.05 0.15 11500\n");
        printf("    Elephant Valley:      ./mandelbrot_pth 0.175 0.375 -0.1 0.1 11500\n");
        printf("    Triple Spiral Valley: ./mandelbrot_pth -0.188 -0.012 0.554 0.754 11500\n");
        exit(0);
    }
    else {
        sscanf(argv[1], "%lf", &cx_min);
        sscanf(argv[2], "%lf", &cx_max);
        sscanf(argv[3], "%lf", &cy_min);
        sscanf(argv[4], "%lf", &cy_max);
        sscanf(argv[5], "%d", &image_size);

        ix_max = image_size;
        iy_max = image_size;
        image_buffer_size = image_size * image_size;

        pixel_width = (cx_max - cx_min) / ix_max;
        pixel_height = (cy_max - cy_min) / iy_max;
    };
};

void update_rgb_buffer(int iteration, int x, int y){
    int color;

    if(iteration == MAX_ITERATIONS){

        image_buffer[(iy_max * y) + x][0] = colors[gradient_size][0];
        image_buffer[(iy_max * y) + x][1] = colors[gradient_size][1];
        image_buffer[(iy_max * y) + x][2] = colors[gradient_size][2];
    }
    else {
        color = iteration % gradient_size;

        image_buffer[(iy_max * y) + x][0] = colors[color][0];
        image_buffer[(iy_max * y) + x][1] = colors[color][1];
        image_buffer[(iy_max * y) + x][2] = colors[color][2];
    };
};

void write_to_file(){
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

    int nthreads, tid;
    omp_init_lock(&stacklock);

    #pragma omp parallel private(nthreads, tid)
    {
        tid = omp_get_thread_num();

        int iteration;
        int offset = 0;

        double cx;
        double cy;
        double zx;
        double zy;
        double zx_squared;
        double zy_squared;

        int col;
        int row;

        omp_set_lock(&stacklock);
        col = current_col++;
        omp_unset_lock(&stacklock);

        while (col < image_size) {

            cy = cy_min + col * pixel_height;

            for (int row = 0; row < image_size; row++) {

                cx = cx_min + row * pixel_width;

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

                update_rgb_buffer(iteration, row, col);

            };

            omp_set_lock(&stacklock);
            col = current_col++;
            omp_unset_lock(&stacklock);

        };


    };

};

int main(int argc, char *argv[]){

    init(argc, argv);
    current_col = 0;

    allocate_image_buffer();

    compute_mandelbrot();

    write_to_file();

    return 0;
};
