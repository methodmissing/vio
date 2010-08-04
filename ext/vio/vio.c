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

#define vio_error(err) \
  rb_raise(rb_eIOError, err);

static void 
vio_read_error()
{
    switch(errno){
       case EAGAIN: 
            vio_error("The file was marked for non-blocking I/O, and no data were ready to be read.");
       case EBADF: 
            vio_error("File descriptor is not a valid file or socket descriptor open for reading.");
       case EFAULT: 
            vio_error("Buffer points outside the allocated address space.");
       case EINTR:
            vio_error("A read from a slow device was interrupted before any data arrived by the delivery of a signal.");
       case EINVAL:
            vio_error("The pointer associated with file descriptor was negative.");
       case EIO:
            vio_error("An I/O error occurred while reading from the file system.");
       case EISDIR:
            vio_error("An attempt is made to read a directory.");
       case ENOBUFS:
            vio_error("An attempt to allocate a memory buffer fails.");
       case ENOMEM:
            vio_error("Insufficient memory is available.");
       case ENXIO:
            vio_error("An action is requested of a device that does not exist.");
    }
}

static void 
vio_write_error()
{
    switch(errno){
       case EDQUOT:
            vio_error("The user's quota of disk blocks on the file system containing the file is exhausted.");
       case EFAULT:
            vio_error("Buffer points outside the allocated address space.");
       case EWOULDBLOCK:
            vio_error("The file descriptor is for a socket, is marked O_NONBLOCK, and write would block.");
       case EDESTADDRREQ:
            vio_error("The destination is no longer available when writing to a UNIX domain datagram socket on which connect(2) had been used to set a destination address.");
       case EINVAL:
            vio_error("Iov count is less than or equal to 0, or greater than MAX_IOV");
       case ENOBUFS:
            vio_error("The mbuf pool has been completely exhausted when writing to a socket.");
    }
}

static VALUE 
vio_read(VALUE io, VALUE iov)
{
    int fd, i, size, bytes_read, cnt;
    int expected = 0;
    struct iovec iovs[IOV_MAX];
    VALUE results;
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
    /* XXX Todo: Error handling */
    lseek(fd, 0L, SEEK_SET);
    fptr->lineno = 0;
    cnt = RARRAY_LEN(iov);
    results = rb_ary_new2(cnt);
    for (i=0; i < cnt; i++) {
      VALUE size_el = RARRAY_PTR(iov)[i];
      Check_Type(size_el, T_FIXNUM);
      size = FIX2INT(size_el);
      expected = expected + size;
      iovs[i].iov_len = size;
      iovs[i].iov_base = calloc(1,size);
    }    
    retry:
      TRAP_BEG;
      bytes_read = readv(fd,iovs,cnt);
      TRAP_END;
    if (bytes_read < expected && bytes_read > 0) goto retry;
    vio_read_error();
    for (i=0; i < cnt; i++) {
      rb_ary_push(results, rb_tainted_str_new((char *)iovs[i].iov_base, iovs[i].iov_len));
    }
    return results;
}

static VALUE 
vio_write(VALUE io, VALUE iov)
{
    int i, size, bytes_written, fd, cnt;
    int expected = 0;
    VALUE results;
#ifdef RUBY19
    rb_io_t *fptr;
#else
    OpenFile *fptr;
#endif
    struct iovec iovs[IOV_MAX];
    Check_Type(iov, T_ARRAY);
    if (RARRAY_LEN(iov) == 0) rb_raise(rb_eIOError, "No buffers to write given");  
    GetOpenFile(io, fptr);
    rb_io_check_writable(fptr);
#ifdef RUBY19
    fd = fptr->fd;
#else
    fd = fileno(fptr->f);
#endif
    cnt = RARRAY_LEN(iov);
    results = rb_ary_new2(cnt);
    for (i=0; i < cnt; i++) {
      VALUE str = RARRAY_PTR(iov)[i];
      Check_Type(str, T_STRING);
      size = RSTRING_LEN(str);
      expected = expected + size;
      iovs[i].iov_len = size;
      iovs[i].iov_base = RSTRING_PTR(str);
    }    
    retry:
      TRAP_BEG;
      bytes_written = writev(fd,iovs,cnt);
      TRAP_END;
    if (bytes_written < expected && bytes_written > 0) goto retry;
    vio_write_error();
    for (i=0; i < cnt; i++) {
      rb_ary_push(results, INT2FIX(iovs[i].iov_len));
    }
    return results;
}

void Init_vio()
{
    rb_define_method(rb_cIO, "readv", vio_read, -2);
    rb_define_method(rb_cIO, "writev", vio_write, -2);
}