CC=gcc
CFLAGS= -g -Wall

all: proxy

proxy: main.c
	$(CC) $(CFLAGS) -o proxy_parse.o -c proxy_parse.c -lpthread
	$(CC) $(CFLAGS) -o proxy.o -c main.c -lpthread
	$(CC) $(CFLAGS) -o proxy proxy_parse.o proxy.o -lpthread

clean:
	rm -f proxy *.o

# tar:
	# tar -cvzf ass1.tgz main.c README.md Makefile proxy_parse.c proxy_parse.h
