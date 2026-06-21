#include "proxy_parse.h"
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <pthread.h>

#define Max_Clients 10

typedef struct cache_element cache_element;

struct cache_element{
    char* data;
    int len;
    char* url;
    time_t lru_time_track;
    cache_element*next;
};
cache_element* find(char* url);
int  add_cache_element(char* url, char* data, int size); 
void remove_cache_element();

int port_number = 8080;
int proxy_socketID;
pthread_t tid[Max_Clients];