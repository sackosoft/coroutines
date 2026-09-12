# FreeBSD Socket and kqueue Syscall Sequence

This document summarizes the syscall sequence for a nonblocking IPv4 TCP server using `kqueue`.
It assumes persistent, level-triggered kqueue registrations and one event loop.

## Assumptions

- The listener and accepted sockets are nonblocking.
- `SOCK_CLOEXEC` is set when descriptors are created.
- Each kqueue `udata` value points to a stable runtime-owned registration or request object.
- `EV_CLEAR` and `EV_ONESHOT` are omitted from the baseline design.
- Read and write operations drain their socket until `EAGAIN` or `EWOULDBLOCK`.

## 1. Create and configure the listening socket

```c
int listener_fd = socket(
    AF_INET,
    SOCK_STREAM | SOCK_NONBLOCK | SOCK_CLOEXEC,
    IPPROTO_TCP
);
```

`SO_REUSEADDR` is normally set before `bind`:

```c
int enabled = 1;
setsockopt(
    listener_fd,
    SOL_SOCKET,
    SO_REUSEADDR,
    &enabled,
    sizeof(enabled)
);
```

Construct a `struct sockaddr_in` in user space, then bind and listen:

```c
bind(
    listener_fd,
    (struct sockaddr *)&address,
    sizeof(address)
);

listen(listener_fd, backlog);
```

A typical address contains:

```c
struct sockaddr_in address = {
    .sin_family      = AF_INET,
    .sin_port        = htons(port),
    .sin_addr.s_addr = htonl(INADDR_ANY),
};
```

`htons`, `htonl`, and `inet_pton` are user-space helpers, not syscalls.

## 2. Create the kqueue

```c
int kq = kqueue();
```

On FreeBSD versions supporting it, `kqueuex(KQUEUE_CLOEXEC)` can create a close-on-exec kqueue directly.
Use either `kqueue` or `kqueuex`, not both.

## 3. Register the listening socket

`EV_SET` initializes a `struct kevent`; it is not a syscall.

```c
struct kevent change;

EV_SET(
    &change,
    listener_fd,       // ident
    EVFILT_READ,       // filter
    EV_ADD,            // flags; adding also enables the event
    0,                 // fflags
    0,                 // data
    listener_token     // udata
);
```

Register without waiting:

```c
kevent(kq, &change, 1, NULL, 0, NULL);
```

To reduce syscall count, registration and the first wait can be combined:

```c
kevent(
    kq,
    &change,
    1,
    events,
    event_capacity,
    NULL
);
```

The changelist is applied before pending events are returned.

## 4. Wait for readiness

When there are no registration changes to submit:

```c
int event_count = kevent(
    kq,
    NULL,              // changelist
    0,                 // number of changes
    events,            // output event array
    event_capacity,
    NULL               // wait indefinitely
);
```

For a listening socket, `EVFILT_READ` means that one or more connections are pending in the listen queue.
The event's `data` field is a snapshot of the listen backlog and is not a required accept count.

An event with `EV_ERROR` has its associated error number in `data`.

## 5. Accept connections

Drain the listener until the nonblocking operation reports that no more connections are immediately available:

```c
for (;;) {
    int client_fd = accept4(
        listener_fd,
        NULL,                       // no peer address requested
        NULL,                       // no address length needed
        SOCK_NONBLOCK | SOCK_CLOEXEC
    );

    if (client_fd >= 0) {
        // Register this client for EVFILT_READ.
        continue;
    }

    if (errno == EAGAIN || errno == EWOULDBLOCK) {
        break;
    }

    if (errno == EINTR || errno == ECONNABORTED) {
        continue;
    }

    // Handle EMFILE, ENFILE, and other policy-dependent errors.
    break;
}
```

There is no bulk `accept4` operation in this interface. One `accept4` call is required per accepted descriptor.
The optimization is to use one kqueue wait to discover readiness, then drain the queue to `EAGAIN`.

## 6. Register accepted clients for reading

For each accepted descriptor:

```c
EV_SET(
    &change,
    client_fd,
    EVFILT_READ,
    EV_ADD,
    0,
    0,
    client_token
);
```

The registration can be submitted immediately:

```c
kevent(kq, &change, 1, NULL, 0, NULL);
```

Or registrations for many accepted clients can be batched:

```c
kevent(
    kq,
    client_changes,
    client_change_count,
    events,
    event_capacity,
    NULL
);
```

## 7. Read data from a client

On a client `EVFILT_READ` event, repeatedly call `recv`:

```c
for (;;) {
    ssize_t received = recv(
        client_fd,
        input_buffer,
        sizeof(input_buffer),
        0
    );

    if (received > 0) {
        // Process or queue the received bytes.
        continue;
    }

    if (received == 0) {
        // The peer performed an orderly shutdown.
        break;
    }

    if (errno == EINTR) {
        continue;
    }

    if (errno == EAGAIN || errno == EWOULDBLOCK) {
        break;
    }

    // Handle the receive error and close the connection.
    break;
}
```

`EV_EOF` does not necessarily mean that the receive buffer is empty. Drain available data before closing.

## 8. Echo data back to the client

Use `send` until all output has been sent or the socket would block:

```c
while (output_bytes_remaining > 0) {
    ssize_t sent = send(
        client_fd,
        output_pointer,
        output_bytes_remaining,
        MSG_NOSIGNAL
    );

    if (sent > 0) {
        output_pointer += sent;
        output_bytes_remaining -= (size_t)sent;
        continue;
    }

    if (sent < 0 && errno == EINTR) {
        continue;
    }

    if (sent < 0 &&
        (errno == EAGAIN || errno == EWOULDBLOCK)) {
        // Preserve the unsent suffix and register EVFILT_WRITE.
        break;
    }

    // Handle EPIPE, ECONNRESET, and other send errors.
    break;
}
```

A nonblocking send may be partial. The unsent suffix must remain in a connection-owned output buffer.
`MSG_NOSIGNAL` prevents a failed send from terminating the process with `SIGPIPE`.

## 9. Register for write readiness only when needed

Do not normally monitor `EVFILT_WRITE` continuously; most connected sockets are writable most of the time.
Register it only when output remains after `send` returns `EAGAIN`:

```c
EV_SET(
    &change,
    client_fd,
    EVFILT_WRITE,
    EV_ADD,
    0,
    0,
    client_token
);

kevent(kq, &change, 1, NULL, 0, NULL);
```

When a write event arrives, retry `send` until the output buffer is empty or the socket returns `EAGAIN`.
When the output buffer becomes empty, remove the write filter:

```c
EV_SET(
    &change,
    client_fd,
    EVFILT_WRITE,
    EV_DELETE,
    0,
    0,
    NULL
);

kevent(kq, &change, 1, NULL, 0, NULL);
```

The add or delete change can be batched with other changes and the next blocking `kevent` call.

## 10. Close descriptors

Close a client after EOF, an unrecoverable error, or after the echo response has been flushed:

```c
close(client_fd);
```

Closing a descriptor automatically removes its descriptor-associated kqueue events. Explicit `EV_DELETE` is
therefore not required before `close`, but explicit deletion can help invalidate runtime registration state first.

At server shutdown:

```c
close(listener_fd);
close(kq);
```

`shutdown` is optional; it is only needed when half-closing one direction before closing the descriptor.

## Condensed sequence

```text
socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK | SOCK_CLOEXEC, IPPROTO_TCP)
setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, ...)
bind(listener, ...)
listen(listener, backlog)

kqueue()

kevent(
    add listener EVFILT_READ,
    optionally wait for events
)

kevent(wait for events)

accept4(listener, ..., SOCK_NONBLOCK | SOCK_CLOEXEC)
accept4(listener, ..., SOCK_NONBLOCK | SOCK_CLOEXEC)
...
accept4(listener, ...)
    -> EAGAIN

kevent(
    add client EVFILT_READ registrations,
    wait for events
)

recv(client, ...)
send(client, ...)

if send returns EAGAIN:
    kevent(add client EVFILT_WRITE, ...)
    kevent(wait for events)
    send(client, ...)

kevent(delete EVFILT_WRITE, ...)
close(client)
```

## Scheduler-mediated operation mapping

The coroutine-facing operation can be expressed as a request while the scheduler owns the actual syscalls:

```text
accept request:
    attempt accept4
    if it returns EAGAIN, wait for EVFILT_READ

read request:
    attempt recv or read
    if it returns EAGAIN, wait for EVFILT_READ

write request:
    attempt send or write
    if it returns EAGAIN, wait for EVFILT_WRITE
```

The request should retain the descriptor, operation kind, buffers where applicable, result or error, and a stable
registration/token identity across suspension. The `udata` target must remain valid until its kqueue registration
and any associated event have been invalidated.

## Syscall-minimization rules

1. Set `SOCK_NONBLOCK` and `SOCK_CLOEXEC` during `socket` and `accept4`; avoid per-descriptor `fcntl` calls.
2. Use one `kevent` call to submit changes and wait whenever possible.
3. Batch registrations and deletions into one changelist.
4. Let one `kevent` call return many ready descriptors.
5. Drain `accept4`, `recv`, and `send` until `EAGAIN`, subject to scheduler fairness limits.
6. Keep `EVFILT_READ` registered persistently after setup.
7. Register `EVFILT_WRITE` only while output is pending.
8. Size the event list for expected bursts so a large ready set does not require extra waits.

This document covers socket readiness. Regular files are different: `EVFILT_READ` does not generally represent disk-I/O
completion. File operations may require FreeBSD AIO, a worker thread, or a specialized operation such as `sendfile`.
