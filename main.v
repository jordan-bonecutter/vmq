import vmq
import time

fn main() {
	ctx := vmq.new_context()
	test_timeout(ctx) ?
	test_pubsub(ctx) ?
	test_pushpull(ctx) ?
}

fn test_timeout(ctx &vmq.Context) ? {
	p1 := vmq.new_socket(ctx, vmq.SocketType.pair) ?
	p2 := vmq.new_socket(ctx, vmq.SocketType.pair) ?

	p1.bind('inproc://timeouttest') ?
	p1.set_send_timeout(time.millisecond * 100) ?
	p1.send('this will fail becuase no pair is connected'.bytes()) or {}

	p2.connect('inproc://timeouttest') ?
	p1.send('but that\'s ok, we set a timeout!'.bytes()) ?

	println(p2.recv()?.bytestr())
}

fn test_pubsub(ctx &vmq.Context) ? {
	p := vmq.new_socket(ctx, vmq.SocketType.@pub) ?
	s := vmq.new_socket(ctx, vmq.SocketType.sub) ?

	p.bind('inproc://pubsubtest') ?
	s.connect('inproc://pubsubtest') ?

	s.subscribe('[topic]'.bytes()) ?

	p.send('[topic] hi world!'.bytes()) ?
	p.send('[othertopic] bye world!'.bytes()) ?
	p.send('[topic] hi (again)!'.bytes()) ?

	m1 := s.recv()?
	println(m1.bytestr())

	m2 := s.recv()?
	println(m2.bytestr())

	s.unsubscribe('[topic]'.bytes())?
	s.subscribe('[othertopic]'.bytes())?

	time.sleep(time.second)
	p.send('[topic] hi (again**2)!'.bytes())?
	p.send('[othertopic] hey world!'.bytes())?

	m3 := s.recv()?
	println(m3.bytestr())
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
	println(msg.bytestr())
}
