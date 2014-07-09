/* 
 * File:   main.cpp
 * Author: merlin
 *
 * Created on 2014年7月9日, 下午4:48
 */


#include <iostream>
#include <boost/asio.hpp>
#include "server.h"

using namespace std;

int main(int argc, char* argv[])
{
	try
	{
		if (argc != 2)
		{
			cerr << "Usage: server <port>"<<endl;
			return 1;
		}

		boost::asio::io_service io_service;
		server s(io_service, atoi(argv[1]));
		io_service.run();
	}
	catch (exception& e)
	{
		cerr << "Exception: " << e.what() << endl;
	}

	return 0;

}
