# 🌐 Multithreaded Proxy Web Server in C

A high-performance, multithreaded HTTP proxy server built from scratch in C using POSIX threads and sockets. It intercepts client HTTP requests, forwards them to remote origin servers, and relays the responses back — all while maintaining a thread-safe **LRU cache** for faster repeated lookups.

---

## ✨ Features

| Feature | Description |
|---|---|
| **Multithreaded Architecture** | Spawns a dedicated thread for each incoming client connection using `pthreads`, enabling true concurrent request handling |
| **LRU Caching** | Implements a Least Recently Used (LRU) cache with configurable size limits to serve repeated requests instantly without re-fetching from the origin server |
| **HTTP Request Parsing** | Full HTTP/1.0 and HTTP/1.1 GET request parsing via a dedicated parsing library (`proxy_parse.c/h`) that extracts method, host, port, path, version, and headers |
| **Thread-Safe Design** | Uses POSIX mutexes (`pthread_mutex_t`) and semaphores (`sem_t`) to safely manage shared cache access and limit concurrent connections |
| **Proper Error Handling** | Returns standards-compliant HTTP error responses (400, 403, 404, 500, 501, 505) with formatted HTML bodies |
| **Configurable Port** | Server port is specified as a command-line argument for flexible deployment |
| **Connection Limiting** | Semaphore-based concurrency control caps the number of simultaneous client connections (default: 10) |

---

## 🏗️ Architecture

```
┌────────────┐        ┌──────────────────────┐        ┌───────────────┐
│   Client   │──TCP──▶│   Proxy Server       │──TCP──▶│ Origin Server │
│  Browser   │◀──TCP──│   (this project)     │◀──TCP──│  (e.g. web)   │
└────────────┘        │                      │        └───────────────┘
                      │  ┌────────────────┐  │
                      │  │   LRU Cache    │  │
                      │  │  (in-memory)   │  │
                      │  └────────────────┘  │
                      │  ┌────────────────┐  │
                      │  │  Thread Pool   │  │
                      │  │  (pthreads)    │  │
                      │  └────────────────┘  │
                      └──────────────────────┘
```

### Request Flow

1. **Client connects** → The main loop in `main()` accepts the TCP connection.
2. **Thread spawns** → A new `pthread` is created via `thread_fn()` to handle the request, controlled by a semaphore (max 10 concurrent threads).
3. **Cache lookup** → `find()` checks if the requested URL already exists in the LRU cache.
   - **Cache HIT** → Response is served directly from cache. LRU timestamp is updated.
   - **Cache MISS** → Proceeds to step 4.
4. **Forward to origin** → `connectRemoteServer()` opens a TCP socket to the actual web server, sends the request, and streams the response back to the client.
5. **Cache storage** → `add_cache_element()` stores the response in the LRU cache for future requests. If the cache exceeds its size limit, `remove_cache_element()` evicts the least recently used entry.
6. **Cleanup** → Socket is closed, semaphore is released, thread exits.

---

## 📁 Project Structure

```
.
├── main.c              # Core proxy server — socket setup, threading, caching, request handling
├── proxy_parse.c       # HTTP request parsing library (parser implementation)
├── proxy_parse.h       # HTTP request parsing library (header/API)
├── Makefile            # Build automation (compile, link, clean)
├── .gitignore          # Excludes binaries, logs, and local scripts
└── README.md           # This file
```

---

## 🔧 Prerequisites

- **GCC** (or any C compiler with C99+ support)
- **POSIX-compliant OS** — Linux or macOS (uses `pthreads`, `semaphore.h`, POSIX sockets)
- **Make** (optional, for using the Makefile)

---

## 🚀 Build & Run

### Using Make (Recommended)

```bash
# Compile
make

# Run on port 8080
./proxy 8080

# Clean build artifacts
make clean
```

### Using GCC Directly

```bash
# Compile
gcc -g -Wall -o proxy_parse.o -c proxy_parse.c -lpthread
gcc -g -Wall -o proxy.o -c main.c -lpthread
gcc -g -Wall -o proxy proxy_parse.o proxy.o -lpthread

# Run on port 8080
./proxy 8080
```

---

## 🧪 Testing

### With curl

```bash
# Start the proxy on port 8080
./proxy 8080

# In another terminal, make a request through the proxy
curl -x http://localhost:8080 http://httpbin.org/get
```

### With a Browser

Configure your browser's HTTP proxy settings to point to `localhost:8080`, then browse any HTTP website. The proxy will intercept and forward the requests.

> **Note:** This proxy currently supports **HTTP only** (not HTTPS). Use it with `http://` URLs.

---

## ⚙️ Configuration

These constants are defined at the top of `main.c` and can be modified before compilation:

| Constant | Default | Description |
|---|---|---|
| `max_clients` | `10` | Maximum number of concurrent client threads |
| `max_bytes` | `4096` | Size of the read/write buffer per request (bytes) |
| `max_element_size` | `10 KB` | Maximum size of a single cache entry |
| `max_size` | `200 MB` | Maximum total size of the LRU cache |
| `port_number` | `8080` | Default port (overridden by command-line argument) |

---

## 🔑 Key Concepts Demonstrated

- **POSIX Sockets** — `socket()`, `bind()`, `listen()`, `accept()`, `connect()`, `send()`, `recv()`
- **Multithreading** — `pthread_create()`, `pthread_join()`, thread functions
- **Synchronization** — `pthread_mutex_lock/unlock()`, `sem_wait/post()` for thread-safe cache and connection limiting
- **DNS Resolution** — `gethostbyname()` for resolving hostnames to IP addresses
- **LRU Cache** — Linked-list based cache with time-tracked eviction
- **HTTP Parsing** — Tokenizing and extracting fields from raw HTTP request buffers
