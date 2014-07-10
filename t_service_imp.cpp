/* 
 * File:   t_service_imp.cpp
 * Author: merlin
 * 
 * Created on 2014年7月10日, 下午2:13
 */

#include <google/protobuf/stubs/common.h>
#include <iostream>
#include "t_service_imp.h"
using namespace std;
t_service_imp::t_service_imp () { }


t_service_imp::~t_service_imp () { }

void t_service_imp::heartbeat(::google::protobuf::RpcController* controller,
                       const ::t::common* request,
                       ::t::ret* response,
                       ::google::protobuf::Closure* done)
{
    cout<<"device:"<<request->device ()<<"  user:"<<request->user ()<<endl;
    response->set_stat(1);
    if(NULL != done)
        done->Run ();
}