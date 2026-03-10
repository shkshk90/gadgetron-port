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
