#include "ruby.h"
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

#ifndef RSTRING_PTR
#define RSTRING_PTR(obj) RSTRING(obj)->ptr
#endif
 
#ifndef RSTRING_LEN
#define RSTRING_LEN(obj) RSTRING(obj)->len
#endif

#ifndef RARRAY_PTR
#define RARRAY_PTR(obj) RARRAY(obj)->ptr
#endif
 
#ifndef RARRAY_LEN
#define RARRAY_LEN(obj) RARRAY(obj)->len
#endif

#ifdef RUBY19
  #include "ruby/io.h" 
  #define TRAP_BEG
  #define TRAP_END
#else
  #include "rubysig.h"
  #include "rubyio.h"
#endif

static VALUE 
vio_read(VALUE io, VALUE iov)
{
    Check_Type(iov, T_ARRAY);
    int fd;
#ifdef RUBY19
    rb_io_t *fptr;
#else
    OpenFile *fptr;
#endif
    if (RARRAY_LEN(iov) == 0) rb_raise(rb_eIOError, "No buffer offsets given");  
    GetOpenFile(io, fptr);
    rb_io_check_readable(fptr);
#ifdef RUBY19
     fd = fptr->fd;
#else
     fd = fileno(fptr->f);
#endif
    struct iovec iovs[IOV_MAX];
    int i, size, bytes_read;
    int expected = 0;
    int cnt = RARRAY_LEN(iov);
    VALUE results = rb_ary_new2(cnt);
    for (i=0; i < cnt; i++) {
      size = FIX2INT(RARRAY_PTR(iov)[i]);
      expected = expected + size;
      iovs[i].iov_len = size;
      iovs[i].iov_base = malloc(size);
    }    
    bytes_read = readv(fd,iovs,cnt);
    if (bytes_read < expected) rb_raise(rb_eIOError, "Vectored I/O read failure!");
    for (i=0; i < cnt; i++) {
      rb_ary_push(results, rb_tainted_str_new((char *)iovs[i].iov_base, iovs[i].iov_len));
    }
    return results;
}

static VALUE 
vio_write(VALUE io, VALUE iov)
{
   Check_Type(iov, T_ARRAY);
#ifdef RUBY19
    rb_io_t *fptr;
#else
    OpenFile *fptr;
#endif
    GetOpenFile(io, fptr);
    rb_io_check_writable(fptr);
    return Qnil;
}

void Init_vio()
{
    rb_define_method(rb_cIO, "readv", vio_read, 1);
    rb_define_method(rb_cIO, "writev", vio_write, 1);
}