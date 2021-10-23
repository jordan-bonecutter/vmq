#pkgconfig libzmq
#flag @VMODROOT/c/vmq_bridge.o
#include <czmq.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

// Helper fn's for the wrapping
fn C.vmq_socktype(&char) int
fn C.vmq_new_message() voidptr

// Native ZMQ fn's
fn C.zmq_ctx_new() voidptr
fn C.zmq_ctx_destroy(voidptr)
fn C.zmq_socket(voidptr, int) voidptr
fn C.zmq_close(voidptr)
fn C.zmq_send(voidptr, voidptr, u64, int) int
fn C.zmq_recv(voidptr, voidptr, usize, int) int
fn C.zmq_msg_init(voidptr) int
fn C.zmq_msg_recv(voidptr, voidptr, int) int
fn C.zmq_msg_size(voidptr) usize
fn C.zmq_msg_data(voidptr) &byte
fn C.zmq_bind(voidptr, &char) int
fn C.zmq_connect(voidptr, &char) int
fn C.zmq_setsockopt(voidptr, int, voidptr, usize) int
fn C.zmq_msg_close(voidptr)

// Error handling
fn C.strerror(int) &char

// Wrap ZMQ Context
struct Context {
	ctx voidptr
}

fn new_context() &Context {
	return &Context{
		ctx: C.zmq_ctx_new()
	}
}

fn (ctx &Context) free() {
	C.zmq_ctx_destroy(ctx.ctx)
}

// Wrap message
struct Message {
	msg voidptr
}

fn new_message() &Message {
	return &Message{
		msg: C.vmq_new_message()
	}
}

fn (m &Message) free() {
	C.zmq_msg_close(m.msg)
	unsafe{ free(m.msg) }
}

// All ZMQ socket types
enum SocketType {
	@pub
	sub
	xpub
	xsub
	push
	pull
	pair
	stream
	req
	rep
	dealer
	router
}

// Socket struct
struct Socket {
	sock voidptr
}

// Create a new typed socket
fn new_socket(ctx &Context, t SocketType) ?&Socket {
	mut z_sock_type := int(0)

	match t {
		.@pub { z_sock_type = C.vmq_socktype(c'PUB') }
		.sub { z_sock_type = C.vmq_socktype(c'SUB') }
		.xpub { z_sock_type = C.vmq_socktype(c'XPUB') }
		.xsub { z_sock_type = C.vmq_socktype(c'XSUB') }
		.push { z_sock_type = C.vmq_socktype(c'PUSH') }
		.pull { z_sock_type = C.vmq_socktype(c'PULL') }
		.pair { z_sock_type = C.vmq_socktype(c'PAIR') }
		.stream { z_sock_type = C.vmq_socktype(c'STREAM') }
		.req { z_sock_type = C.vmq_socktype(c'req') }
		.rep { z_sock_type = C.vmq_socktype(c'rep') }
		.dealer { z_sock_type = C.vmq_socktype(c'dealer') }
		.router { z_sock_type = C.vmq_socktype(c'router') }
	}

	if z_sock_type == -1 {
		return error('Unrecognized socket type!')
	}

	return &Socket{
		sock: C.zmq_socket(ctx.ctx, z_sock_type)
	}
}

fn (s &Socket) free() {
	C.zmq_close(s.sock)
}

fn (s Socket) bind(addr string) ? {
	rc := C.zmq_bind(s.sock, &char(addr.str) )
	if rc != 0 {
		err_str := C.strerror(C.errno)
		return error(unsafe { cstring_to_vstring(err_str) })
	}
}

fn (s Socket) connect(addr string) ? {
	rc := C.zmq_connect(s.sock, &char(addr.str) )
	if rc != 0 {
		err_str := C.strerror(C.errno)
		return error(unsafe { cstring_to_vstring(err_str) })
	}
}

fn (s Socket) send(payload []byte) ? {
	c_payload := payload.data
	rc := C.zmq_send(s.sock, c_payload, u64(payload.len), 0)
	if rc == -1 {
		return error(unsafe{ cstring_to_vstring(C.strerror(C.errno)) })
	}
}

fn (s Socket) recv_buf(buf []byte) ? {
	rc := C.zmq_recv(s.sock, buf.data, buf.len, 0)
	if rc == -1 {
		return error(unsafe{ cstring_to_vstring(C.strerror(C.errno)) })
	}
}

fn (s Socket) recv() ?[]byte {
	msg := new_message()
	C.zmq_msg_init(msg.msg)
	rc := C.zmq_msg_recv(msg.msg, s.sock, 0)
	if rc == -1 {
		return error(unsafe{ cstring_to_vstring(C.strerror(C.errno)) })
	}
	size := C.zmq_msg_size(msg.msg)
	data := C.zmq_msg_data(msg.msg)
	buf := []byte{len: int(size)}
	for i, _ in buf {
		unsafe{ buf[i] = data[i] }
	}

	return buf
}

fn main() {
	c := new_context()
	push := new_socket(c, SocketType.push)?
	push.bind("inproc://test")?

	pull := new_socket(c, SocketType.pull)?
	pull.connect("inproc://test")?

	push.send("hello!".bytes())?

	my_buf := pull.recv()?

	println(string(my_buf))
}

