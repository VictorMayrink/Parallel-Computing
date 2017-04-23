#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <pthread.h>

double c_x_min;
double c_x_max;
double c_y_min;
double c_y_max;

double pixel_width;
double pixel_height;

int iteration_max = 200;

int image_size;
int rgb_size = 3;
unsigned char *image_buffer;

int i_x_max;
int i_y_max;
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
                        {16, 16, 16},
                    };


int nthreads;
pthread_t * thread_pool;

#define STEPS_SIZE 3

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
    else{
        sscanf(argv[1], "%lf", &c_x_min);
        sscanf(argv[2], "%lf", &c_x_max);
        sscanf(argv[3], "%lf", &c_y_min);
        sscanf(argv[4], "%lf", &c_y_max);
        sscanf(argv[5], "%d", &nthreads);
        sscanf(argv[6], "%d", &image_size);

        thread_pool = (pthread_t *) malloc(sizeof(pthread_t) * nthreads);

        i_x_max           = image_size;
        i_y_max           = image_size;
        image_buffer_size = image_size * image_size;

        pixel_width       = (c_x_max - c_x_min) / i_x_max;
        pixel_height      = (c_y_max - c_y_min) / i_y_max;
    };
};

void update_rgb_buffer(int iteration, int x, int y){

    unsigned char* tmp_pointer;
    int color = gradient_size;

    if(iteration != iteration_max){
        color = iteration % gradient_size;
    };

    tmp_pointer  = image_buffer + (((i_y_max * y) + x) * rgb_size);
    *tmp_pointer = (unsigned char)colors[color][0];

    tmp_pointer  += 1;
    *tmp_pointer = (unsigned char)colors[color][1];

    tmp_pointer  += 1;
    *tmp_pointer = (unsigned char)colors[color][2];
};

void write_to_file(){
    FILE * file;
    char * filename               = "output.ppm";
    char * comment                = "# ";

    int max_color_component_value = 255;

    file = fopen(filename,"wb");

    fprintf(file, "P6\n %s\n %d\n %d\n %d\n", comment,
            i_x_max, i_y_max, max_color_component_value);

    fwrite(image_buffer, 1, 3 * image_buffer_size, file);

    fclose(file);
};

void* compute_mandelbrotX(void* args){


    double* args_arr = (double *) args;
    int init = (int)args_arr[0];
    int end = (int)args_arr[1];
    double c_y = args_arr[2];
    int i_y = (int)args_arr[3];

    
    return NULL;
}

void* compute_mandelbrot(void* args){

    double z_x;
    double z_y;
    double z_x_squared;
    double z_y_squared;
    double escape_radius_squared = 4;

    int iteration;
    int i_x;
    int i_y;

    double c_x;
    double c_y;

    int* args_arr = (int *) args;
    int init = args_arr[0];
    int end = args_arr[1];

    for(i_y = init; i_y < end; i_y++){
        c_y = c_y_min + i_y * pixel_height;

        if(fabs(c_y) < pixel_height / 2){
            c_y = 0.0;
        };

        for(i_x = 0; i_x < i_x_max; i_x++){
            c_x         = c_x_min + i_x * pixel_width;

            z_x         = 0.0;
            z_y         = 0.0;

            z_x_squared = 0.0;
            z_y_squared = 0.0;

            for(iteration = 0;
                iteration < iteration_max && \
                ((z_x_squared + z_y_squared) < escape_radius_squared);
                iteration++){
                z_y         = 2 * z_x * z_y + c_y;
                z_x         = z_x_squared - z_y_squared + c_x;

                z_x_squared = z_x * z_x;
                z_y_squared = z_y * z_y;
            };

            update_rgb_buffer(iteration, i_x, i_y);
        };
    };
    return NULL;
};

void call_mandelbrot(){

    int chunk = i_y_max/nthreads;
    int init, end, i;
    for(i = init = 0, end = chunk; i < nthreads; end += chunk, init += chunk, i++){

        if(end + chunk > i_y_max)
            end = i_y_max;

        int * args = (int *) malloc(sizeof(int) * 2);
        args[0] = init;
        args[1] = end;
        pthread_create(&thread_pool[i], NULL, compute_mandelbrot, (void *) args);
    };
}

int main(int argc, char *argv[]){

    struct timespec init_t, end_t;
    double elapsed;
    init(argc, argv);

    image_buffer = (unsigned char *) malloc(sizeof(unsigned char) * 3 * image_buffer_size);

    clock_gettime(CLOCK_MONOTONIC, &init_t);
    int i = 0;
    call_mandelbrot();
    for(i = 0; i < nthreads; i++)
        pthread_join(thread_pool[i], NULL);
    clock_gettime(CLOCK_MONOTONIC, &end_t);

    elapsed = end_t.tv_sec - init_t.tv_sec;
    elapsed += fabs((end_t.tv_nsec - init_t.tv_nsec) / 1000000000.0);

    write_to_file();

    return 0;
};