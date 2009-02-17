"""printing.pyx -- Pyrex bindings for tstools printing redirection

This is being developed on a Mac, running OS X, and also tested on my Ubuntu
system at work.

I do not expect it to build (as it stands) on Windows, as it is making
assumptions that may not follow thereon.

It is my intent to worry about Windows after it works on the platforms that
I can test most easily!
"""

# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 1.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Original Code is the MPEG TS, PS and ES tools.
#
# The Initial Developer of the Original Code is Amino Communications Ltd.
# Portions created by the Initial Developer are Copyright (C) 2008
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#   Tibs (tibs@berlios.de)
#
# ***** END LICENSE BLOCK *****

import sys
import array

cdef extern from *:
    ctypedef char* const_char_ptr "const char*"

cdef extern from "Python.h":
    # Write the output string described by format to sys.stdout. No exceptions
    # are raised, even if truncation occurs (see below).  
    #
    # format should limit the total size of the formatted output string to 1000
    # bytes or less – after 1000 bytes, the output string is truncated. In
    # particular, this means that no unrestricted “%s” formats should occur;
    # these should be limited using “%.<N>s” where <N> is a decimal number
    # calculated so that <N> plus the maximum size of other formatted text does
    # not exceed 1000 bytes. Also watch out for “%f”, which can print hundreds
    # of digits for very large numbers.
    #
    # If a problem occurs, or sys.stdout is unset, the formatted message is
    # written to the real (C level) stdout.
    void PySys_WriteStdout(const_char_ptr format, ...)

    # Unfortunately, there are two common ways of implementing a va_list,
    # and we just have to guess which is being used. For the moment, though,
    # just take advantage of the fact that the following seems to work for
    # our purposes...
    ctypedef void * va_list

    # Output not more than size bytes to str according to the format string
    # format and the variable argument list va. Unix man page vsnprintf(2).
    int PyOS_vsnprintf(char *str, int size, const_char_ptr format, va_list va)

# cdef extern from 'stdarg.h':
#     ctypedef void* va_list "va_list"

cdef extern from 'printing_fns.h':
    void print_msg(const_char_ptr text)
    void print_err(const_char_ptr text)
    void fprint_msg(const_char_ptr format, ...)
    void fprint_err(const_char_ptr format, ...)
    int redirect_output( void (*new_print_message_fn) (const_char_ptr message),
                         void (*new_print_error_fn) (const_char_ptr message),
                         void (*new_fprint_message_fn) (const_char_ptr format, va_list arg_ptr),
                         void (*new_fprint_error_fn) (const_char_ptr format, va_list arg_ptr)
                        )

cdef void our_print_msg(const_char_ptr text):
    PySys_WriteStdout('%s',text)

cdef void our_format_msg(const_char_ptr format, va_list arg_ptr):
    cdef int err
    cdef char buffer[1000]
    PyOS_vsnprintf(buffer, 1000, format, arg_ptr)
    PySys_WriteStdout('%s',buffer)

def setup_printing():
    cdef int err
    err = redirect_output(our_print_msg, our_print_msg,
                          our_format_msg, our_format_msg)
    if err == 0:
        print 'Setting output redirection OK'
    else:
        print 'Setting output redirection FAILED'

def test_printing():
    setup_printing()
    print_msg('Message\n')
    print_err('Error\n')
    fprint_msg('Message "%s"\n','Fred')
    fprint_msg('Error "%s"\n','Fred')

# ----------------------------------------------------------------------
# vim: set filetype=python expandtab shiftwidth=4:
# [X]Emacs local variables declaration - place us into python mode
# Local Variables:
# mode:python
# py-indent-offset:4
# End:
