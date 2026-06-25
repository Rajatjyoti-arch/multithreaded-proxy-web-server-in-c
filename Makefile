CC := gcc
CFLAGS := -g -Wall -Wextra -std=c11 -pthread
TARGET := proxy
OBJECTS := main.o proxy_parse.o

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $(OBJECTS)

main.o: main.c proxy_parse.h
	$(CC) $(CFLAGS) -c main.c

proxy_parse.o: proxy_parse.c proxy_parse.h
	$(CC) $(CFLAGS) -c proxy_parse.c

clean:
	rm -f $(TARGET) $(OBJECTS)
