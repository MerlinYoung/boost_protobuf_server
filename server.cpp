/* 
 * File:   server.cpp
 * Author: merlin
 *
 * Created on 2014年7月9日, 下午4:48
 */

#include "server.h"
#include "session.h"
server::server (boost::asio::io_service& io_service, short port)
: acceptor_ (io_service, tcp::endpoint (tcp::v4 (), port)),
socket_ (io_service)
{
	do_accept ();
}

void
server::do_accept ()
{
	acceptor_.async_accept (socket_,
							[this](boost::system::error_code ec)
							{
								if (!ec)
								  {
									make_shared<session>(move (socket_))->start ();
								  }

								do_accept ();
							});
}

