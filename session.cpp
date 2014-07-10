/* 
 * File:   session.cpp
 * Author: Merlin
 * 
 * Created on 2014年7月9日, 下午10:25
 */

#include <google/protobuf/descriptor.h>
#include <google/protobuf/message.h>

#include "session.h"
#include "t.pb.h"
#include "t_service_imp.h"
session::session (tcp::socket socket)
: socket_ (move (socket)) { }

void
session::start ()
{
    do_read ();
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
                                                                bool ret=request->ParseFromArray(self->data_.begin(),length);
                                                                if(!ret)
                                                                {
                                                                    cout<<"parse error:"<<string(self->data_.begin(),length)<<endl;
                                                                }
                                                                else
                                                                {   
                                                                    service->CallMethod(method, NULL ,request, response, NULL);
                                                                }
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

