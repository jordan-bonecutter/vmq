/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <stdio.h>
#include <stdlib.h>
#include <czmq.h>
#include <string.h>

int vmq_socktype(const char *type) {
  if(strcmp(type, "PUB") == 0) {
    return ZMQ_PUB;
  } else if(strcmp(type, "SUB") == 0) {
    return ZMQ_SUB;
  } else if(strcmp(type, "XPUB") == 0) {
    return ZMQ_XPUB;
  } else if(strcmp(type, "XSUB") == 0) {
    return ZMQ_XSUB;
  } else if(strcmp(type, "PUSH") == 0) {
    return ZMQ_PUSH;
  } else if(strcmp(type, "PULL") == 0) {
    return ZMQ_PULL;
  } else if(strcmp(type, "PAIR") == 0) {
    return ZMQ_PAIR;
  } else if(strcmp(type, "STREAM") == 0) {
    return ZMQ_STREAM;
  } else if(strcmp(type, "REQ") == 0) {
    return ZMQ_REQ;
  } else if(strcmp(type, "REP") == 0) {
    return ZMQ_REP;
  } else if(strcmp(type, "DEALER") == 0) {
    return ZMQ_DEALER;
  } else if(strcmp(type, "ROUTER") == 0) {
    return ZMQ_ROUTER;
  }

  return -1;
}

// I know, I know... they're not all here. Implement them and PR!
int vmq_sockopt(const char *opt) {
  if(strcmp(opt, "CURVE_PUBLICKEY") == 0) {
    return ZMQ_CURVE_PUBLICKEY;
  } else if(strcmp(opt, "CURVE_SECRETKEY") == 0) {
    return ZMQ_CURVE_SECRETKEY;
  } else if(strcmp(opt, "CURVE_SERVER") == 0) {
    return ZMQ_CURVE_SERVER;
  } else if(strcmp(opt, "CURVE_SERVERKEY") == 0) {
    return ZMQ_CURVE_SERVERKEY;
  } else if(strcmp(opt, "PLAIN_PASSWORD") == 0) {
    return ZMQ_PLAIN_PASSWORD;
  } else if(strcmp(opt, "PLAIN_SERVER") == 0) {
    return ZMQ_PLAIN_SERVER;
  } else if(strcmp(opt, "PLAIN_USERNAME") == 0) {
    return ZMQ_PLAIN_USERNAME;
  } else if(strcmp(opt, "SUBSCRIBE") == 0) {
    return ZMQ_SUBSCRIBE;
  } else if(strcmp(opt, "UNSUBSCRIBE") == 0) {
    return ZMQ_UNSUBSCRIBE;
  }

  return -1;
}

void *vmq_make_message() {
  return malloc(sizeof(zmq_msg_t));
}

