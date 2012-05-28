# A makefile

CC=gcc
LD=gcc

CFLAGS=-O2 -Wno-unused-result
LDFLAGS=
LIBS=-lpng -lz
all: timeCluster

timeCluster: 
	$(CC) $(CFLAGS) -o timeCluster timeCluster.c $(LIBS)

clean:
	rm -f timeCluster timeCluster.o
