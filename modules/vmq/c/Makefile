#
#
#
#

COMPILER = gcc
OPTIMIZATION = -O3
FLAGS = -std=c99 -Wall
CC = $(COMPILER) $(FLAGS)
CO = $(CC) -c 
LIBZMQ_INCLUDE = $(shell pkg-config --cflags libzmq)
LIBZMQ_LINK = $(shell pkg-config --libs libzmq)

vmq_bridge.o: vmq.c
	$(CO) $(LIBZMQ_INCLUDE) $(LIBZMQ_LINK) vmq.c -o vmq_bridge.o

