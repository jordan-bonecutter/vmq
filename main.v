import vmq
import time

fn main() {
	ctx := vmq.new_context()
	test_pubsub(ctx) ?
	test_pushpull(ctx) ?
}

fn test_pubsub(ctx &vmq.Context) ? {
	p := vmq.new_socket(ctx, vmq.SocketType.@pub) ?
	s := vmq.new_socket(ctx, vmq.SocketType.sub) ?

	p.bind('inproc://pubsubtest') ?
	s.connect('inproc://pubsubtest') ?

	s.subscribe('hi'.bytes()) ?

	p.send('hi world!'.bytes()) ?
	p.send('bye world!'.bytes()) ?
	p.send('hi (again)!'.bytes()) ?

	m1 := s.recv()?
	println(string(m1))

	m2 := s.recv()?
	println(string(m2))

	s.unsubscribe('hi'.bytes())?
	s.subscribe('hey'.bytes())?

	time.sleep(time.second)
	p.send('hi (again**2)!'.bytes())?
	p.send('hey world!'.bytes())?

	m3 := s.recv()?
	println(string(m3))
}

fn test_pushpull(ctx &vmq.Context) ? {
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
	msg := pull.recv() or {
		panic(err)
	}
	println(string(msg))
}
