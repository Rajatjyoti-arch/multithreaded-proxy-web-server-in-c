# Multithreaded Proxy Web Server in C

A high-performance, multithreaded HTTP proxy web server implemented in C. This server handles concurrent client requests using POSIX threads (`pthreads`), intercepts HTTP requests, forwards them to origin servers, and caches/returns responses back to clients.

## Features
- **Multithreading**: Concurrent request handling using `pthread` thread pool or on-demand thread creation.
- **HTTP Proxying**: Fully handles GET, POST, and other HTTP request methods.
- **Automated Pushing**: Equipped with an automated script that tracks modifications and pushes changes to GitHub every 10 minutes with descriptive commit messages.

## Getting Started

### Prerequisites
- GCC Compiler
- POSIX-compliant environment (Linux/macOS)

### Building
To compile the proxy server:
```bash
gcc -pthread main.c -o proxy_server
```

### Running
```bash
./proxy_server <port>
```
