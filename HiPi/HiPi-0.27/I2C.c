/*
 * This file was generated automatically by ExtUtils::ParseXS version 3.18 from the
 * contents of I2C.xs. Do not edit this file, edit I2C.xs instead.
 *
 *    ANY CHANGES MADE HERE WILL BE LOST!
 *
 */

///////////////////////////////////////////////////////////////////////////////////////
// File          i2c/I2C.xs
// Description:  XS module for MyPi::Device::I2C
// Created       Fri Nov 23 12:13:43 2012
// SVN Id        $Id:$
// Copyright:    Copyright (c) 2012 Mark Dootson
// Licence:      This work is free software; you can redistribute it and/or modify it 
//               under the terms of the GNU General Public License as published by the 
//               Free Software Foundation; either version 3 of the License, or any later 
//               version.
///////////////////////////////////////////////////////////////////////////////////////

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "mylib/include/ppport.h"
#include "mylib/include/local-i2c-dev.h"
#include <linux/swab.h>

#ifndef PERL_UNUSED_VAR
#  define PERL_UNUSED_VAR(var) if (0) var = var
#endif

#ifndef dVAR
#  define dVAR		dNOOP
#endif


/* This stuff is not part of the API! You have been warned. */
#ifndef PERL_VERSION_DECIMAL
#  define PERL_VERSION_DECIMAL(r,v,s) (r*1000000 + v*1000 + s)
#endif
#ifndef PERL_DECIMAL_VERSION
#  define PERL_DECIMAL_VERSION \
	  PERL_VERSION_DECIMAL(PERL_REVISION,PERL_VERSION,PERL_SUBVERSION)
#endif
#ifndef PERL_VERSION_GE
#  define PERL_VERSION_GE(r,v,s) \
	  (PERL_DECIMAL_VERSION >= PERL_VERSION_DECIMAL(r,v,s))
#endif
#ifndef PERL_VERSION_LE
#  define PERL_VERSION_LE(r,v,s) \
	  (PERL_DECIMAL_VERSION <= PERL_VERSION_DECIMAL(r,v,s))
#endif

/* XS_INTERNAL is the explicit static-linkage variant of the default
 * XS macro.
 *
 * XS_EXTERNAL is the same as XS_INTERNAL except it does not include
 * "STATIC", ie. it exports XSUB symbols. You probably don't want that
 * for anything but the BOOT XSUB.
 *
 * See XSUB.h in core!
 */


/* TODO: This might be compatible further back than 5.10.0. */
#if PERL_VERSION_GE(5, 10, 0) && PERL_VERSION_LE(5, 15, 1)
#  undef XS_EXTERNAL
#  undef XS_INTERNAL
#  if defined(__CYGWIN__) && defined(USE_DYNAMIC_LOADING)
#    define XS_EXTERNAL(name) __declspec(dllexport) XSPROTO(name)
#    define XS_INTERNAL(name) STATIC XSPROTO(name)
#  endif
#  if defined(__SYMBIAN32__)
#    define XS_EXTERNAL(name) EXPORT_C XSPROTO(name)
#    define XS_INTERNAL(name) EXPORT_C STATIC XSPROTO(name)
#  endif
#  ifndef XS_EXTERNAL
#    if defined(HASATTRIBUTE_UNUSED) && !defined(__cplusplus)
#      define XS_EXTERNAL(name) void name(pTHX_ CV* cv __attribute__unused__)
#      define XS_INTERNAL(name) STATIC void name(pTHX_ CV* cv __attribute__unused__)
#    else
#      ifdef __cplusplus
#        define XS_EXTERNAL(name) extern "C" XSPROTO(name)
#        define XS_INTERNAL(name) static XSPROTO(name)
#      else
#        define XS_EXTERNAL(name) XSPROTO(name)
#        define XS_INTERNAL(name) STATIC XSPROTO(name)
#      endif
#    endif
#  endif
#endif

/* perl >= 5.10.0 && perl <= 5.15.1 */


/* The XS_EXTERNAL macro is used for functions that must not be static
 * like the boot XSUB of a module. If perl didn't have an XS_EXTERNAL
 * macro defined, the best we can do is assume XS is the same.
 * Dito for XS_INTERNAL.
 */
#ifndef XS_EXTERNAL
#  define XS_EXTERNAL(name) XS(name)
#endif
#ifndef XS_INTERNAL
#  define XS_INTERNAL(name) XS(name)
#endif

/* Now, finally, after all this mess, we want an ExtUtils::ParseXS
 * internal macro that we're free to redefine for varying linkage due
 * to the EXPORT_XSUB_SYMBOLS XS keyword. This is internal, use
 * XS_EXTERNAL(name) or XS_INTERNAL(name) in your code if you need to!
 */

#undef XS_EUPXS
#if defined(PERL_EUPXS_ALWAYS_EXPORT)
#  define XS_EUPXS(name) XS_EXTERNAL(name)
#else
   /* default to internal */
#  define XS_EUPXS(name) XS_INTERNAL(name)
#endif

#ifndef PERL_ARGS_ASSERT_CROAK_XS_USAGE
#define PERL_ARGS_ASSERT_CROAK_XS_USAGE assert(cv); assert(params)

/* prototype to pass -Wmissing-prototypes */
STATIC void
S_croak_xs_usage(pTHX_ const CV *const cv, const char *const params);

STATIC void
S_croak_xs_usage(pTHX_ const CV *const cv, const char *const params)
{
    const GV *const gv = CvGV(cv);

    PERL_ARGS_ASSERT_CROAK_XS_USAGE;

    if (gv) {
        const char *const gvname = GvNAME(gv);
        const HV *const stash = GvSTASH(gv);
        const char *const hvname = stash ? HvNAME(stash) : NULL;

        if (hvname)
            Perl_croak(aTHX_ "Usage: %s::%s(%s)", hvname, gvname, params);
        else
            Perl_croak(aTHX_ "Usage: %s(%s)", gvname, params);
    } else {
        /* Pants. I don't think that it should be possible to get here. */
        Perl_croak(aTHX_ "Usage: CODE(0x%"UVxf")(%s)", PTR2UV(cv), params);
    }
}
#undef  PERL_ARGS_ASSERT_CROAK_XS_USAGE

#ifdef PERL_IMPLICIT_CONTEXT
#define croak_xs_usage(a,b)    S_croak_xs_usage(aTHX_ a,b)
#else
#define croak_xs_usage        S_croak_xs_usage
#endif

#endif

/* NOTE: the prototype of newXSproto() is different in versions of perls,
 * so we define a portable version of newXSproto()
 */
#ifdef newXS_flags
#define newXSproto_portable(name, c_impl, file, proto) newXS_flags(name, c_impl, file, proto, 0)
#else
#define newXSproto_portable(name, c_impl, file, proto) (PL_Sv=(SV*)newXS(name, c_impl, file), sv_setpv(PL_Sv, proto), (CV*)PL_Sv)
#endif /* !defined(newXS_flags) */


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_quick); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_quick)
{
    dVAR; dXSARGS;
    if (items != 2)
       croak_xs_usage(cv,  "file, value");
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	value = (__u8)SvUV(ST(1))
;
	__s32	RETVAL;
	dXSTARG;
    RETVAL = i2c_smbus_write_quick(file, value);

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_byte); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_byte)
{
    dVAR; dXSARGS;
    if (items != 1)
       croak_xs_usage(cv,  "file");
    {
	int	file = (int)SvIV(ST(0))
;
	__s32	RETVAL;
	dXSTARG;
    RETVAL = i2c_smbus_read_byte( file );

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_byte); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_byte)
{
    dVAR; dXSARGS;
    if (items != 2)
       croak_xs_usage(cv,  "file, value");
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	value = (__u8)SvUV(ST(1))
;
	__s32	RETVAL;
	dXSTARG;
    RETVAL = i2c_smbus_write_byte( file, value );

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_byte_data); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_byte_data)
{
    dVAR; dXSARGS;
    if (items != 2)
       croak_xs_usage(cv,  "file, command");
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	command = (__u8)SvUV(ST(1))
;
	__s32	RETVAL;
	dXSTARG;
    RETVAL = i2c_smbus_read_byte_data(file, command );

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_byte_data); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_byte_data)
{
    dVAR; dXSARGS;
    if (items != 3)
       croak_xs_usage(cv,  "file, command, value");
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	command = (__u8)SvUV(ST(1))
;
	__u8	value = (__u8)SvUV(ST(2))
;
	__s32	RETVAL;
	dXSTARG;
    RETVAL = i2c_smbus_write_byte_data(file, command, value );

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_word_data); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_word_data)
{
    dVAR; dXSARGS;
    if (items != 2)
       croak_xs_usage(cv,  "file, command");
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	command = (__u8)SvUV(ST(1))
;
	__s32	RETVAL;
	dXSTARG;
    RETVAL = i2c_smbus_read_word_data(file, command );

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_word_data); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_word_data)
{
    dVAR; dXSARGS;
    if (items != 3)
       croak_xs_usage(cv,  "file, command, value");
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	command = (__u8)SvUV(ST(1))
;
	__u16	value = (unsigned short)SvUV(ST(2))
;
	__s32	RETVAL;
	dXSTARG;
    RETVAL = i2c_smbus_write_word_data(file, command, value );

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_word_swapped); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_word_swapped)
{
    dVAR; dXSARGS;
    if (items != 2)
       croak_xs_usage(cv,  "file, command");
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	command = (__u8)SvUV(ST(1))
;
	__s32	RETVAL;
	dXSTARG;
    __s32 rval = i2c_smbus_read_word_data(file, command );
    RETVAL = (rval < 0) ? rval : __swab16(rval);

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_word_swapped); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_word_swapped)
{
    dVAR; dXSARGS;
    if (items != 3)
       croak_xs_usage(cv,  "file, command, value");
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	command = (__u8)SvUV(ST(1))
;
	__u16	value = (unsigned short)SvUV(ST(2))
;
	__s32	RETVAL;
	dXSTARG;
    RETVAL = i2c_smbus_write_word_data(file, command, __swab16(value) );

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_process_call); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_process_call)
{
    dVAR; dXSARGS;
    if (items != 3)
       croak_xs_usage(cv,  "file, command, value");
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	command = (__u8)SvUV(ST(1))
;
	__u16	value = (unsigned short)SvUV(ST(2))
;
	__s32	RETVAL;
	dXSTARG;
    RETVAL = i2c_smbus_process_call(file, command, value );

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_block_data); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_block_data)
{
    dVAR; dXSARGS;
    if (items != 2)
       croak_xs_usage(cv,  "file, command");
    PERL_UNUSED_VAR(ax); /* -Wall */
    SP -= items;
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	command = (__u8)SvUV(ST(1))
;
    int i;
    __u8 buf[32];
    int result = i2c_smbus_read_block_data(file, command, buf);
    if (result < 0) {
        EXTEND( SP, 1 );
        PUSHs(  &PL_sv_undef );
    } else {
        EXTEND( SP, (IV)result );
        for( i = 0; i < result; ++i )
        {
            SV* var = sv_newmortal();
            sv_setuv( var, (UV)buf[i] );
            PUSHs( var );
        }
    }
	PUTBACK;
	return;
    }
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_i2c_block_data); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_read_i2c_block_data)
{
    dVAR; dXSARGS;
    if (items != 3)
       croak_xs_usage(cv,  "file, command, len");
    PERL_UNUSED_VAR(ax); /* -Wall */
    SP -= items;
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	command = (__u8)SvUV(ST(1))
;
	__u8	len = (__u8)SvUV(ST(2))
;
    int i;
    __u8 *buffer;
    buffer = malloc(len * sizeof(__u8));
    int result = i2c_smbus_read_i2c_block_data(file, command, len, buffer);
    if (result < 0) {
        EXTEND( SP, 1 );
        PUSHs(  &PL_sv_undef );
    } else {
        EXTEND( SP, (IV)result );
        for( i = 0; i < result; ++i )
        {
            SV* var = sv_newmortal();
            sv_setuv( var, (UV)buffer[i] );
            PUSHs( var );
        }
    }
    free( buffer );
	PUTBACK;
	return;
    }
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_block_data); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_block_data)
{
    dVAR; dXSARGS;
    if (items != 3)
       croak_xs_usage(cv,  "file, command, dataarray");
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	command = (__u8)SvUV(ST(1))
;
	SV*	dataarray = ST(2)
;
	__s32	RETVAL;
	dXSTARG;
    STRLEN len;
    AV*  av;
    __u8 *buffer;
    int  i;

    if( !SvROK( dataarray ) || ( SvTYPE( (SV*) ( av = (AV*) SvRV( dataarray ) ) ) != SVt_PVAV ) )
    {
        croak( "the data array is not an array reference" );
        return;
    }

    len = av_len( av ) + 1;

    buffer = malloc(len * sizeof(__u8));

    for( i = 0; i < (int)len; ++i )
        buffer[i] = (__u8)SvUV(*av_fetch( av, i, 0 ));

    RETVAL = i2c_smbus_write_block_data(file, command, len, buffer);

    free( buffer);

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_i2c_block_data); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C_i2c_smbus_write_i2c_block_data)
{
    dVAR; dXSARGS;
    if (items != 3)
       croak_xs_usage(cv,  "file, command, dataarray");
    {
	int	file = (int)SvIV(ST(0))
;
	__u8	command = (__u8)SvUV(ST(1))
;
	SV*	dataarray = ST(2)
;
	__s32	RETVAL;
	dXSTARG;
    STRLEN len;
    AV*    av;
    __u8   *buffer;
    int    i;

    if( !SvROK( dataarray ) || ( SvTYPE( (SV*) ( av = (AV*) SvRV( dataarray ) ) ) != SVt_PVAV ) )
    {
        croak( "the data array is not an array reference" );
        return;
    }

    len = av_len( av ) + 1;

    buffer = malloc(len * sizeof(__u8));

    for( i = 0; i < (int)len; ++i )
        buffer[i] = (__u8)SvUV(*av_fetch( av, i, 0 ));

    RETVAL = i2c_smbus_write_i2c_block_data(file, command, len, buffer);

    free( buffer );

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C__i2c_write); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C__i2c_write)
{
    dVAR; dXSARGS;
    if (items != 4)
       croak_xs_usage(cv,  "file, address, wbuf, wlen");
    {
	int	RETVAL;
	dXSTARG;
	int	file = (int)SvIV(ST(0))
;
	__u16	address = (unsigned short)SvUV(ST(1))
;
	unsigned char *	wbuf = (unsigned char *)SvPV_nolen(ST(2))
;
	__u16	wlen = (unsigned short)SvUV(ST(3))
;
    int ret;
    struct i2c_rdwr_ioctl_data i2c_data;
    struct i2c_msg msg[1];
    i2c_data.msgs = msg;
    i2c_data.nmsgs = 1;             // use one message structure

    i2c_data.msgs[0].addr = address;
    i2c_data.msgs[0].flags = 0;     // don't need flags
    i2c_data.msgs[0].len = wlen;
    i2c_data.msgs[0].buf = (__u8 *)wbuf;

    ret = ioctl(file, I2C_RDWR, &i2c_data);

    if (ret < 0) {
        RETVAL = ret;
    } else {
        RETVAL = 0;
    }
	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C__i2c_read); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C__i2c_read)
{
    dVAR; dXSARGS;
    if (items != 4)
       croak_xs_usage(cv,  "file, address, rbuf, rlen");
    {
	int	RETVAL;
	dXSTARG;
	int	file = (int)SvIV(ST(0))
;
	__u16	address = (unsigned short)SvUV(ST(1))
;
	unsigned char *	rbuf = (unsigned char *)SvPV_nolen(ST(2))
;
	__u16	rlen = (unsigned short)SvUV(ST(3))
;
    int ret;
    struct i2c_rdwr_ioctl_data  i2c_data;
    struct i2c_msg  msg[1];

    i2c_data.msgs = msg;
    i2c_data.nmsgs = 1;   
    i2c_data.msgs[0].addr = address;
    i2c_data.msgs[0].flags = I2C_M_RD; 
    i2c_data.msgs[0].len = rlen;
    i2c_data.msgs[0].buf = (__u8 *)rbuf;

    ret = ioctl(file, I2C_RDWR, &i2c_data);

    if (ret < 0) {
        RETVAL = ret;
    } else {
        RETVAL = 0;
    }

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_HiPi__Device__I2C__i2c_read_register); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_HiPi__Device__I2C__i2c_read_register)
{
    dVAR; dXSARGS;
    if (items != 5)
       croak_xs_usage(cv,  "file, address, wbuf, rbuf, rlen");
    {
	int	RETVAL;
	dXSTARG;
	int	file = (int)SvIV(ST(0))
;
	__u16	address = (unsigned short)SvUV(ST(1))
;
	unsigned char *	wbuf = (unsigned char *)SvPV_nolen(ST(2))
;
	unsigned char *	rbuf = (unsigned char *)SvPV_nolen(ST(3))
;
	__u16	rlen = (unsigned short)SvUV(ST(4))
;
    int ret;
    struct i2c_rdwr_ioctl_data  i2c_data;
    struct i2c_msg  msg[2];

    i2c_data.msgs = msg;
    i2c_data.nmsgs = 2;

    i2c_data.msgs[0].addr = address;
    i2c_data.msgs[0].flags = 0; 
    i2c_data.msgs[0].len = 1;
    i2c_data.msgs[0].buf = (__u8 *)wbuf;

    i2c_data.msgs[1].addr = address;
    i2c_data.msgs[1].flags = I2C_M_RD; 
    i2c_data.msgs[1].len = rlen;
    i2c_data.msgs[1].buf = (__u8 *)rbuf;

    ret = ioctl(file, I2C_RDWR, &i2c_data);

    if (ret < 0) {
        RETVAL = ret;
    } else {
        RETVAL = 0;
    }

	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}

#ifdef __cplusplus
extern "C"
#endif
XS_EXTERNAL(boot_HiPi__Device__I2C); /* prototype to pass -Wmissing-prototypes */
XS_EXTERNAL(boot_HiPi__Device__I2C)
{
    dVAR; dXSARGS;
#if (PERL_REVISION == 5 && PERL_VERSION < 9)
    char* file = __FILE__;
#else
    const char* file = __FILE__;
#endif

    PERL_UNUSED_VAR(cv); /* -W */
    PERL_UNUSED_VAR(items); /* -W */
#ifdef XS_APIVERSION_BOOTCHECK
    XS_APIVERSION_BOOTCHECK;
#endif
    XS_VERSION_BOOTCHECK;

        newXS("HiPi::Device::I2C::i2c_smbus_write_quick", XS_HiPi__Device__I2C_i2c_smbus_write_quick, file);
        newXS("HiPi::Device::I2C::i2c_smbus_read_byte", XS_HiPi__Device__I2C_i2c_smbus_read_byte, file);
        newXS("HiPi::Device::I2C::i2c_smbus_write_byte", XS_HiPi__Device__I2C_i2c_smbus_write_byte, file);
        newXS("HiPi::Device::I2C::i2c_smbus_read_byte_data", XS_HiPi__Device__I2C_i2c_smbus_read_byte_data, file);
        newXS("HiPi::Device::I2C::i2c_smbus_write_byte_data", XS_HiPi__Device__I2C_i2c_smbus_write_byte_data, file);
        newXS("HiPi::Device::I2C::i2c_smbus_read_word_data", XS_HiPi__Device__I2C_i2c_smbus_read_word_data, file);
        newXS("HiPi::Device::I2C::i2c_smbus_write_word_data", XS_HiPi__Device__I2C_i2c_smbus_write_word_data, file);
        newXS("HiPi::Device::I2C::i2c_smbus_read_word_swapped", XS_HiPi__Device__I2C_i2c_smbus_read_word_swapped, file);
        newXS("HiPi::Device::I2C::i2c_smbus_write_word_swapped", XS_HiPi__Device__I2C_i2c_smbus_write_word_swapped, file);
        newXS("HiPi::Device::I2C::i2c_smbus_process_call", XS_HiPi__Device__I2C_i2c_smbus_process_call, file);
        newXS("HiPi::Device::I2C::i2c_smbus_read_block_data", XS_HiPi__Device__I2C_i2c_smbus_read_block_data, file);
        newXS("HiPi::Device::I2C::i2c_smbus_read_i2c_block_data", XS_HiPi__Device__I2C_i2c_smbus_read_i2c_block_data, file);
        newXS("HiPi::Device::I2C::i2c_smbus_write_block_data", XS_HiPi__Device__I2C_i2c_smbus_write_block_data, file);
        newXS("HiPi::Device::I2C::i2c_smbus_write_i2c_block_data", XS_HiPi__Device__I2C_i2c_smbus_write_i2c_block_data, file);
        newXS("HiPi::Device::I2C::_i2c_write", XS_HiPi__Device__I2C__i2c_write, file);
        newXS("HiPi::Device::I2C::_i2c_read", XS_HiPi__Device__I2C__i2c_read, file);
        newXS("HiPi::Device::I2C::_i2c_read_register", XS_HiPi__Device__I2C__i2c_read_register, file);
#if (PERL_REVISION == 5 && PERL_VERSION >= 9)
  if (PL_unitcheckav)
       call_list(PL_scopestack_ix, PL_unitcheckav);
#endif
    XSRETURN_YES;
}

