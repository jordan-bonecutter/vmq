#pkgconfig libzmq
#flag @VMODROOT/c/vmq_bridge.o
#include <czmq.h>
#include <errno.h>
#include <string.h>

fn C.vmq_socktype(&char) int
fn C.zmq_ctx_new() voidptr
fn C.zmq_ctx_destroy(voidptr)
fn C.zmq_socket(voidptr, int) voidptr
fn C.zmq_close(voidptr)
fn C.zmq_send(voidptr, voidptr, u64, int)
fn C.zmq_bind(voidptr, &char) int
fn C.zmq_connect(voidptr, &char) int
fn C.zmq_setsockopt(voidptr, int, voidptr, usize) int
fn C.strerror(int) &char

struct Context {
	ctx voidptr
}

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

struct Socket {
	sock voidptr
}

fn new_context() &Context {
	return &Context{
		ctx: C.zmq_ctx_new()
	}
}

fn (ctx &Context) free() {
	C.zmq_ctx_destroy(ctx.ctx)
}

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

fn (s Socket) send(payload []byte) {
	c_payload := unsafe { &byte(&payload[0]) }
	C.zmq_send(s.sock, c_payload, u64(payload.len), 0)
}

fn (s Socket) set_affinity(affinity u64) ? {
	C.set_sockopt(s.sock, )
}

fn main() {
	c := new_context()
	s := new_socket(c, SocketType.@pub) or {
		panic('Couldn\'t create socket!')
	}
	s.bind("tcp://127.0.0.1:4044") or {
		panic(err)
	}
	s.send("hello!".bytes())
}

