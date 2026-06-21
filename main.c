#include "proxy_parse.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <sys/wait.h>
#include <errno.h>
#include <pthread.h>
#include <semaphore.h>

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
sem_t semaphore;
pthread_mutex_t lock;

cache_element* head;
int cache_size;

int main(int argc, char* argv[]){
    int client_socketID, client_lens;
    struct sockaddr server_addr, client_addr;
    sem_init(&semaphore, Max_Clients);

}