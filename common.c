#include <stdio.h>
#include <ctype.h>

int read_string(int* str, int max_size, FILE* input_stream) {
    int i = 0;
    int ch;
    do {
        ch = fgetc(input_stream);
        str[i++] = ch;
    } while (ch != -1 && i != max_size);
    str[i - 1] = '\n';

    if (i == max_size && ch != -1) {
        return -1;
    }
    return i;
}


void print_string(int* str, int size, FILE* output) {
    while (size--) {
        fprintf(output, "%c", *str++);
    }
}
