#!/bin/sh
zig test Coroutine.zig && \
 zig test IntrusiveStackList.zig && \
 zig test MinHeap.zig && \
 zig test PlatformProvider.zig && \
 zig test Runtime.zig && \
 zig test Stack.zig && \
 zig test StackHeader.zig && \
 zig test arch_x86_64.zig && \
 zig test platform_freebsd.zig
