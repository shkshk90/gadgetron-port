# Gadgetron to sycl migration

## HOw to run 

```sh
gadgetron -s -c config.xml < input.h5 > output.h5
```

## Analysis

1. Server Mode (default) 
   
   The gadgetron binary runs as a TCP server on port 9002. Clients connect via gadgetron_ismrmrd_client.

2. Streaming Mode (embedded,  no network)

    The same gadgetron binary supports a -s / --from_stream flag that bypasses networking entirely:
    `gadgetron -s -c config.xml < input.h5 > output.h5`
    This uses StreamConsumer to process data from stdin/stdout or files — no server, no sockets, no forking.


## Some notes:

### After porting:

- `alignas(16)` issue with `axpy` and complex doubles
- dpct_holders and missing kernel names
- Some mis translated stuff, like the clash with `spmv`
- Replacing `axpy` with a custom kernel
- `sycl::ext::oneapi::experimental::use_root_sync` issue, that caused `CUDA_ERROR_COOPERATIVE_LAUNCH_TOO_LARGE` issue AT runtime
-  Device pointer dereference segfault: Replaced *mm_pair.first/*mm_pair.second with explicit queue.memcpy to safely copy values from device to host

