/* 
 * File:   t_service_imp.h
 * Author: merlin
 *
 * Created on 2014年7月10日, 下午2:13
 */

#ifndef T_SERVICE_IMP_H
#define	T_SERVICE_IMP_H

#include "t.pb.h"

class t_service_imp:public t::t_service
{
public:
	t_service_imp();
	t_service_imp(const t_service_imp& orig)=delete;
	virtual ~t_service_imp();
	void heartbeat(::google::protobuf::RpcController* controller,
                       const ::t::common* request,
                       ::t::ret* response,
                       ::google::protobuf::Closure* done);
private:

};

#endif	/* T_SERVICE_IMP_H */

