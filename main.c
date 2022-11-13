#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>

int read_string(int* str, int max_size, FILE* input_stream);
void print_string(int* str, int size, FILE* output);

int count_words(int* str, int size) {
    int result = 0;
    for (int i = 0; i + 1 < size; ++i) {
        if (isspace(str[i + 1]) && !isspace(str[i])) {
            ++result;
        }
    }
    if (size != 0 && !isspace(str[size - 1])) {
        ++result;
    }
    return result;
}

void put_words(int* str, int size, int** words_start) {
    if (size == 0) {
        return;
    }
    int j = 0;
    if (!isspace(str[0])) {
        words_start[j++] = str;
    }
    for (int i = 1; i < size; ++i) {
        if (isspace(str[i - 1]) && !isspace(str[i])) {
            words_start[j++] = str + i;
        }
    }
}

void reverse_words(int* str, int size) {
    int cnt = count_words(str, size);
    int** words = malloc(cnt * sizeof(int*));
    put_words(str, size, words);

    int* tmp = malloc(size * sizeof(int));
    int j = 0;
    for (int i = 0; i < size; ++i) {
        if ((i == 0 || isspace(str[i - 1])) && !isspace(str[i])) {
            --cnt;
            while (!isspace(*words[cnt])) {
                tmp[j++] = *words[cnt]++;
            }
        } else if (isspace(str[i])) {
            tmp[j++] = str[i];
        }
    }
    for (int i = 0; i < size; ++i) {
        str[i] = tmp[i];
    }
    free(words);
    free(tmp);
}

int main(int argc, char* argv[]) {
    const int N = 100000;
    int* str = malloc(N * sizeof(int));

    FILE* input = stdin;
    FILE* output = stdout;

    if (argc > 2) {
        input = fopen(argv[1], "r");
        output = fopen(argv[2], "w");
    }

    int size = read_string(str, N, input);
    if (size == -1) {
        printf("text to big to process!");
        return 0;
    }

    reverse_words(str, size);
    print_string(str, size, output);

    free(str);

    if (argc > 2) {
        fclose(input);
        fclose(output);
    }

    return 0;
}

