import vmq
import time

fn main() {
	ctx := vmq.new_context()

	push := vmq.new_socket(ctx, vmq.SocketType.push) ?
	pull := vmq.new_socket(ctx, vmq.SocketType.pull) ?

	// Generate some test keys
	pub_key, sec_key := vmq.curve_keypair()?
	push.setup_curve(pub_key, sec_key)?
	push.set_curve_server()?

	pull_pk, pull_sk := vmq.curve_keypair()?
	pull.setup_curve(pull_pk, pull_sk)?
	pull.set_curve_serverkey(pub_key)?

	push.bind('tcp://127.0.0.1:5555') ?
	pull.connect('tcp://127.0.0.1:5555') ?
	time.sleep(time.second)
	push.send('hello!'.bytes()) ?
	t := go recv(pull)
	t.wait()
}

fn recv(pull &vmq.Socket) {
	time.sleep(time.second)
	msg := pull.recv() or {
		panic(err)
	}
	println(string(msg))
}
