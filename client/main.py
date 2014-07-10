#!/usr/bin/env python

import sys
import os
import t_pb2

import protobuf
import protobuf.socketrpc
import protobuf.socketrpc.channel

# Define callback
class Callback:
	def run(self,response):
		print "Received Response: %s" % response

if __name__ == '__main__':

# Create channel
	channel = protobuf.socketrpc.channel.SocketRpcChannel('192.168.1.200',10081)
	controller = channel.newController()

# Call service
	request = t_pb2.common();
	request.user=1123
	request.device='bbb'
	print "request:%s|" % request
	s= request.SerializeToString()
	for c in s:
#print c
		print "%x" % ord(c)

	service  = t_pb2.t_service_Stub(channel)
	service.heartbeat(controller,request,Callback())

# Check success
	if controller.failed():
		print "Rpc failed %s : %s" % (controller.error,controller.reason)
