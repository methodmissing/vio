#include "ruby.h"

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
}

static VALUE 
vio_write(VALUE io, VALUE iov)
{
}

void Init_vio()
{
    rb_define_method(rb_cIO, "readv", vio_read, 1);
    rb_define_method(rb_cIO, "writev", vio_write, 1);
}