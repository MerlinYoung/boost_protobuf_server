/* 
 * File:   session.h
 * Author: Merlin
 *
 * Created on 2014年7月9日, 下午10:25
 */

#ifndef SESSION_H
#define	SESSION_H

// Class to manage the memory to be used for handler-based custom allocation.
// It contains a single block of memory which may be returned for allocation
// requests. If the memory is in use when an allocation request is made, the
// allocator delegates allocation to the global heap.
#include <array>
#include <cstdlib>
#include <iostream>
#include <memory>
#include <type_traits>
#include <utility>
#include <memory>
#include <boost/asio.hpp>
using namespace std;
using boost::asio::ip::tcp;
class handler_allocator {
public:

    handler_allocator()
    : in_use_(false) {
    }

    handler_allocator(const handler_allocator&) = delete;
    handler_allocator& operator=(const handler_allocator&) = delete;

    void* allocate(size_t size) {
        if (!in_use_ && size < sizeof (storage_)) {
            in_use_ = true;
            return &storage_;
        } else {
            return ::operator new(size);
        }
    }

    void deallocate(void* pointer) {
        if (pointer == &storage_) {
            in_use_ = false;
        } else {
            ::operator delete(pointer);
        }
    }

private:
    // Storage space used for handler-based custom memory allocation.
    typename aligned_storage<1024>::type storage_;

    // Whether the handler-based custom allocation storage has been used.
    bool in_use_;
};

// Wrapper class template for handler objects to allow handler memory
// allocation to be customised. Calls to operator() are forwarded to the
// encapsulated handler.

template <typename Handler>
class custom_alloc_handler {
public:

    custom_alloc_handler(handler_allocator& a, Handler h)
    : allocator_(a),
    handler_(h) {
    }

    template <typename ...Args>
    void operator()(Args&&... args) {
        handler_(forward<Args>(args)...);
    }

    friend void* asio_handler_allocate(size_t size,
            custom_alloc_handler<Handler>* this_handler) {
        return this_handler->allocator_.allocate(size);
    }

    friend void asio_handler_deallocate(void* pointer, size_t /*size*/,
            custom_alloc_handler<Handler>* this_handler) {
        this_handler->allocator_.deallocate(pointer);
    }

private:
    handler_allocator& allocator_;
    Handler handler_;
};

// Helper function to wrap a handler object to add custom allocation.

template <typename Handler>
inline custom_alloc_handler<Handler> make_custom_alloc_handler(
        handler_allocator& a, Handler h) {
    return custom_alloc_handler<Handler>(a, h);
}
class session_pool;
class session
: public enable_shared_from_this<session> {
public:

    session(tcp::socket socket,session_pool& pool);
    ~session();

    void start() ;
    void stop();

private:

    void do_read() ;

    void do_write(size_t length) ;

    // The socket used to communicate with the client.
    tcp::socket socket_;

    // Buffer used to store data received from the client.
    array<char, 1024> data_;

    // The allocator to use for handler-based custom memory allocation.
    handler_allocator allocator_;
    
    session_pool& _pool;
};

typedef shared_ptr<session> session_ptr;
#endif	/* SESSION_H */

