# vmq
![Run Main](https://github.com/jordan-bonecutter/vmq/workflows/Run%20Main/badge.svg)


V Wrapper For ZMQ

`vmq` attempts to maintain a similar API to libzmq. Typical usage is:

1. Create a context via `vmq.new_context()`
2. Create a socket via `vmq.new_socket(ctx, vmq.SocketType.@pub)`
3. Either call `sock.bind("tcp://127.0.0.1:5555")` or `sock.connect("inproc://test")` to bind or connect to some endpoint
4. Send on the socket via `sock.send([]byte)`
5. Receive from a socket via `sock.recv()` or `sock.recv_buf([]byte)`

Here's an example:

```v
import vmq

fn main() {
  ctx := vmq.new_context()
  push := vmq.new_socket(ctx, vmq.SocketType.push)?
  pull := vmq.new_socket(ctx, vmq.SocketType.pull)?
  
  push.bind("inproc://test")?
  pull.connect("inproc://test")?
  
  push.send("hello!".bytes())?
  msg := pull.recv()?

  println(string(msg))
}
```
