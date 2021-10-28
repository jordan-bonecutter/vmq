module vmq

#pkgconfig libzmq
#flag @VMODROOT/c/vmq_bridge.o
#flag -I @VMODROOT/c
#include <vmq.h>
#include <czmq.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

// Helper fn's for the wrapping
fn C.vmq_socktype(&char) int
fn C.vmq_sockopt(&char) int
fn C.vmq_make_message() voidptr

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
fn C.zmq_curve_keypair(&char, &char) int

// Error handling
fn C.strerror(int) &char

// Wrap ZMQ Context
pub struct Context {
	ctx voidptr
}

// Create a new context
pub fn new_context() &Context {
	return &Context{
		ctx: C.zmq_ctx_new()
	}
}

// Free data associated with a context
fn (ctx &Context) free() {
	C.zmq_ctx_destroy(ctx.ctx)
}

// Wrap message
struct Message {
	msg voidptr
}

// Create a new message
fn new_message() &Message {
	return &Message{
		msg: C.vmq_make_message()
	}
}

// Free data associated with a message
fn (m &Message) free() {
	C.zmq_msg_close(m.msg)
	unsafe { free(m.msg) }
}

// All ZMQ socket types
pub enum SocketType {
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
pub struct Socket {
	sock voidptr
}

// Create a new typed socket
pub fn new_socket(ctx &Context, t SocketType) ?&Socket {
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

// Free data associated with a socket
fn (s &Socket) free() {
	C.zmq_close(s.sock)
}

// Bind to an address
pub fn (s Socket) bind(addr string) ? {
	rc := C.zmq_bind(s.sock, &char(addr.str))
	if rc != 0 {
		err_str := C.strerror(C.errno)
		return error(unsafe { cstring_to_vstring(err_str) })
	}
}

// Connect to an address
pub fn (s Socket) connect(addr string) ? {
	rc := C.zmq_connect(s.sock, &char(addr.str))
	if rc != 0 {
		err_str := C.strerror(C.errno)
		return error(unsafe { cstring_to_vstring(err_str) })
	}
}

// Send the payload on a socket
pub fn (s Socket) send(payload []byte) ? {
	c_payload := payload.data
	rc := C.zmq_send(s.sock, c_payload, u64(payload.len), 0)
	if rc == -1 {
		return error(unsafe { cstring_to_vstring(C.strerror(C.errno)) })
	}
}

// Receive up to buf.len bytes from a socket
pub fn (s Socket) recv_buf(buf []byte) ?int {
	rc := C.zmq_recv(s.sock, buf.data, buf.len, 0)
	if rc == -1 {
		return error(unsafe { cstring_to_vstring(C.strerror(C.errno)) })
	}
	return rc
}

// Receive an entire message from a socket
// The returned array contains the message
pub fn (s Socket) recv() ?[]byte {
	msg := new_message()
	C.zmq_msg_init(msg.msg)
	rc := C.zmq_msg_recv(msg.msg, s.sock, 0)
	if rc == -1 {
		return error(unsafe { cstring_to_vstring(C.strerror(C.errno)) })
	}
	size := C.zmq_msg_size(msg.msg)
	data := C.zmq_msg_data(msg.msg)
	buf := []byte{len: int(size)}
	for i, _ in buf {
		unsafe {
			buf[i] = data[i]
		}
	}

	return buf
}

// Setup the socket for curve encryted communication
pub fn (s Socket) setup_curve(publickey string, secretkey string) ? {
	if publickey.len != 40 || secretkey.len != 40 {
		return error('Key length must be 40!')
	}

	if C.zmq_setsockopt(s.sock, C.vmq_sockopt(c'CURVE_PUBLICKEY'), &char(publickey.str),
		41) == -1 {
		return error(unsafe { cstring_to_vstring(C.strerror(C.errno)) })
	}

	if C.zmq_setsockopt(s.sock, C.vmq_sockopt(c'CURVE_SECRETKEY'), &char(secretkey.str),
		41) == -1 {
		return error(unsafe { cstring_to_vstring(C.strerror(C.errno)) })
	}
}

// Set the socket to act as a curve server
pub fn (s Socket) set_curve_server() ? {
	option := int(1)
	if C.zmq_setsockopt(s.sock, C.vmq_sockopt(c'CURVE_SERVER'), &option, sizeof(option)) == -1 {
		return error(unsafe { cstring_to_vstring(C.strerror(C.errno)) })
	}
}

pub fn (s Socket) set_curve_serverkey(serverkey string) ? {
	if serverkey.len != 40 {
		return error('Key length must be 40!')
	}

	if C.zmq_setsockopt(s.sock, C.vmq_sockopt(c'CURVE_SERVERKEY'), &char(serverkey.str),
		41) == -1 {
		return error(unsafe { cstring_to_vstring(C.strerror(C.errno)) })
	}
}

// Generate a z85 encoded curve keypair
pub fn curve_keypair() ?(string, string) {
	pub_buf := []byte{len: 41}
	sec_buf := []byte{len: 41}

	if C.zmq_curve_keypair(&char(pub_buf.data), &char(sec_buf.data)) == -1 {
		return error('ZMQ was not built with cryptographic support!')
	}

	return string(pub_buf), string(sec_buf)
}
