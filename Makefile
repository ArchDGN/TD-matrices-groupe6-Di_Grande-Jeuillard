CC = gcc
CFLAGS = -std=c11 -Wall -Wextra -Wpedantic -g

all: demo_matrices test_ex1 test_ex2 test_ex3

demo_matrices: main.c matrice.c matrice_alloc.c matrice_io.c matrice_calcul.c
	$(CC) $(CFLAGS) main.c matrice.c matrice_alloc.c matrice_io.c matrice_calcul.c -o demo_matrices

test_ex1: test_ex1.c matrice.c matrice_alloc.c
	$(CC) $(CFLAGS) -DMAT_TEST_ALLOC test_ex1.c matrice.c matrice_alloc.c -o test_ex1

test_ex2: test_ex2.c matrice.c matrice_alloc.c matrice_io.c
	$(CC) $(CFLAGS) -DMAT_TEST_ALLOC test_ex2.c matrice.c matrice_alloc.c matrice_io.c -o test_ex2

test_ex3: test_ex3.c matrice.c matrice_alloc.c matrice_calcul.c
	$(CC) $(CFLAGS) -DMAT_TEST_ALLOC test_ex3.c matrice.c matrice_alloc.c matrice_calcul.c -o test_ex3

clean:
	rm -f *.o demo_matrices test_ex1 test_ex2 test_ex3 test_ex2_sortie.txt