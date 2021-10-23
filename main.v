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
