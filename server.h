/* 
 * File:   main.cpp
 * Author: merlin
 *
 * Created on 2014年7月9日, 下午4:48
 */


#include <array>
#include <cstdlib>
#include <iostream>
#include <memory>
#include <type_traits>
#include <utility>
#include <boost/asio.hpp>
#include "session_pool.h"

using namespace std;
using boost::asio::ip::tcp;

class server {
public:

    server(boost::asio::io_service& io_service, short port);

private:

    void do_accept();

    tcp::acceptor acceptor_;
    tcp::socket socket_;
    session_pool sessions_;
    
    //t_service_imp  rpc_service_;
    
};

