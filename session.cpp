/* 
 * File:   session.cpp
 * Author: Merlin
 * 
 * Created on 2014年7月9日, 下午10:25
 */

#include <google/protobuf/descriptor.h>
#include <google/protobuf/message.h>

#include "session.h"
#include "session_pool.h"
#include "t.pb.h"
#include "t_service_imp.h"
session::session (tcp::socket socket,session_pool& pool)
: socket_ (move (socket)),_pool(pool) { }

session::~session ()
{
	stop();
}

void
session::start ()
{
    do_read ();
}

void session::stop()
{
	socket_.close();
}

void
session::do_read ()
{
    auto self (shared_from_this ());
    socket_.async_read_some (boost::asio::buffer (data_),
                             make_custom_alloc_handler (allocator_,
                                                        [this, self](boost::system::error_code ec, size_t length)
                                                        {
                                                            if (!ec)
                                                            {
                                                                t_service_imp * service = new t_service_imp();
                                                                cout<<service->GetDescriptor ()->name ()<<endl;
                                                                const google::protobuf::MethodDescriptor* method = service->GetDescriptor ()->FindMethodByName("heartbeat");
                                                                google::protobuf::Message* request  = service->GetRequestPrototype (method).New ();
                                                                google::protobuf::Message* response = service->GetResponsePrototype(method).New();
                                                                cout<<"length:"<<length<<" data:";
																for(auto i=0;i<length;++i)
																{
																	char c = *(self->data_.data()+i);
																	cout<<std::hex<<(unsigned)c<<' ';
																}
																cout<<endl;
                                                                bool ret=request->ParseFromArray(self->data_.data(),length);
                                                                if(!ret)
                                                                {
                                                                    cout<<"parse error:"<<string(self->data_.data(),length)<<endl;
                                                                }
                                                                else
                                                                {   
                                                                    service->CallMethod(method, NULL ,request, response, NULL);
                                                                }
																delete service;
																delete method;
																delete request;
																cout<<"ByteSize:"<<response->ByteSize ()<<endl;
																response->SerializeToArray (self->data_.data(),1024);
																delete response;
                                                                do_write (length);
                                                            }
                                                        }));
}

void
session::do_write (size_t length)
{
    auto self (shared_from_this ());
    boost::asio::async_write (socket_, boost::asio::buffer (data_, length),
                              make_custom_alloc_handler (allocator_,
                                                         [this, self](boost::system::error_code ec, size_t /*length*/)
                                                         {
                                                             if (!ec)
                                                             {
                                                                 do_read ();
                                                             }
                                                         }));
}

