#!/usr/bin/env python

import t_pb2
import protobuf.socketrpc.server

#class t_service_imp(t_pb2.t_service):
#	a

if __name__ == '__main__':
	server = protobuf.socketrpc.server.SocketRpcServer(10081)
	server.registerService(t_pb2.t_service())
	server.run()
