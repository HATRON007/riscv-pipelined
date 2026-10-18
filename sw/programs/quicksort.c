#define SIG_ADDR (*(volatile int *)0x7F00)

int data[10] = {8, 3, 1, 7, 0, 10, 2, 4, 9, 5};

void swap(int *a, int *b) {
    int t = *a;
    *a = *b;
    *b = t;
}

int partition(int low, int high) {
    int pivot = data[high];
    int i = (low - 1);

    for (int j = low; j <= high - 1; j++) {
        if (data[j] < pivot) {
            i++;
            swap(&data[i], &data[j]);
        }
    }
    swap(&data[i + 1], &data[high]);
    return (i + 1);
}

void quicksort(int low, int high) {
    if (low < high) {
        int pi = partition(low, high);
        quicksort(low, pi - 1);
        quicksort(pi + 1, high);
    }
}

int main() {
    quicksort(0, 9);

    int checksum = 0;
    for (int i = 0; i < 10; i++) {
        checksum += data[i] * i;
    }

    SIG_ADDR = checksum;
    
    return 0;
}