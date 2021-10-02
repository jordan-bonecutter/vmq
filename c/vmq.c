/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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

int vmq_sockopt(const char *opt) {
  if(strcmp(opt, "AFFINITY") == 0) {
    return ZMQ_AFFINITY;
  } else if (strcmp(opt, "BACKLOG")) {
    return ZMQ_BACKLOG;
  } else if (strcmp(opt, "BINDTODEVICE")) {
    return ZMQ_BINDTODEVICE;
  } else if (strcmp(opt, "CONNECT_ROUTING_ID")) {
    return ZMQ_CONNECT_ROUTING_ID;
  } else if (strcmp(opt, "CONFLATE")) {
    return ZMQ_CONFLATE;
  } else if (strcmp(opt, "CONNECT_TIMEOUT")) {
    return ZMQ_CONNECT_TIMEOUT;
  } else if (strcmp(opt, "CURVE_PUBLICKEY")) {
    return ZMQ_CURVE_PUBLICKEY;
  } else if (strcmp(opt, "CURVE_SECRETKEY")) {
    return ZMQ_CURVE_SECRETKEY;
  } else if (strcmp(opt, "CURVE_SERVER")) {
    return ZMQ_CURVE_SERVER;
  } else if (strcmp(opt, "GSSAPI_PLAINTEXT")) {
    return ZMQ_GSSAPI_PLAINTEXT;
  } else if (strcmp(opt, "GSSAPI_PRINCIPAL")) {
    return ZMQ_GSSAPI_PRINCIPAL;
  } else if (strcmp(opt, "GSSAPI_SERVER")) {
    return ZMQ_GSSAPI_SERVER;
  }
}

