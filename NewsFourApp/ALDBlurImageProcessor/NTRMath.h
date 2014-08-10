/**
 *  @file NTRMath.h
 *  
 *  @brief Contains mathematical utilities for C, C++ and ObjC
 *
 *  @author Daniel L. Alves, copyright 2011
 *
 *  @since 18/02/2011
 */

#ifndef NITRO_MATH_H
#define NITRO_MATH_H

#ifdef __cplusplus
    #include <cmath>
    #include <cfloat>
#else
    #include <math.h>
    #include <float.h>
#endif

#if !defined(NTR_INLINE)
# if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#  define NTR_INLINE static inline
# elif defined(__cplusplus)
#  define NTR_INLINE static inline
# elif defined(__GNUC__)
#  define NTR_INLINE static __inline__
# else
#  define NTR_INLINE static
# endif
#endif

#ifdef __cplusplus
namespace nitro
{
    namespace math
    {
#endif

/*******************************************************
 
 General functions
 
 *******************************************************/

/**
 *  Linear interpolation. That is, calculates a value fitted between x and  y,
 *  given a percentage of the distance traveled between them. This version is
 *  optmized for floating point values. To avoid conversions when using integer
 *  values, use lerpi.
 *
 *  @param percent How much of the distance between x and y have been traveled. 0.0f means
 *                 0%, 1.0f means 100%.
 *  @param x       The starting point of the linear interpolation
 *  @param y       The ending point of the linear interpolation
 *
 *  @return A value interpolated between x and y
 *
 *  @see lerpi
 */
NTR_INLINE float lerp( float percent, float x, float y ){ return x + ( percent * ( y - x ) ); };

/**
 *  Linear interpolation. That is, calculates a value fitted between x and y,
 *  given a percentage of the distance traveled between them. This version is
 *  optmized for integer values. To avoid conversions when using floating point
 *  values, use lerp.
 *
 *  @param percent How much of the distance between x and y have been traveled. 0 means
 *                 0%, 100 means 100%.
 *  @param x       The starting point of the linear interpolation
 *  @param y       The ending point of the linear interpolation
 *
 *  @return A value interpolated between x and y
 *
 *  @see lerp
 */
NTR_INLINE int lerpi( int percent, int x, int y ){  return x + (( percent * ( y - x )) / 100 ); };

/**
 *  Returns a value clamped between the interval [min, max]. That is, if the value is
 *  lesser than min, the result is min. If the value is greater than max, the result is
 *  max. This version is optmized for floating point values. To avoid conversions when
 *  using integer values, use clampi.
 *
 *  @param x   The value to clamp
 *  @param min The min boundary of the accepted interval
 *  @param max The max boundary of the accepted interval
 *
 *  @return A value clamped between the interval [min, max]
 *
 *  @see clampi
 */
NTR_INLINE float clamp( float x, float min, float max ){ return x <= min ? min : ( x >= max ? max : x ); };

/**
 *  Returns a value clamped between the interval [min, max]. That is, if the value is
 *  lesser than min, the result is min. If the value is greater than max, the result is
 *  max. This version is optmized for integer values. To avoid conversions when using
 *  floating point values, use clamp.
 *
 *  @param x   The value to clamp
 *  @param min The min boundary of the accepted interval
 *  @param max The max boundary of the accepted interval
 *
 *  @return A value clamped between the interval [min, max]
 *
 *  @see clamp
 */
NTR_INLINE int clampi( int x, int min, int max ){ return x <= min ? min : ( x >= max ? max : x ); };

/**
 *  Returns the luminance of a RGB color. The results will be incorrect if there are components
 *  with values less than zero or greater than one.
 *
 *  @param r The red component of the color
 *  @param g The green component of the color
 *  @param b The blue component of the color
 *
 *  @return The luminance of the color
 *
 *  @see luminancei
 */
NTR_INLINE float luminance( float r, float g, float b ) { return ( r * 0.299f ) + ( g * 0.587f ) + ( b * 0.114f ); };

/**
 *  Returns the luminance of a RGB color
 *
 *  @param r The red component of the color
 *  @param g The green component of the color
 *  @param b The blue component of the color
 *
 *  @return The luminance of the color
 *
 *  @see luminance
 */
NTR_INLINE uint8_t luminancei( uint8_t r, uint8_t g, uint8_t b ) { return ( uint8_t )((( r * 76 ) + ( g * 150 ) + ( b * 29 )) / 255 ); };

/*******************************************************
 
 Conversion functions
 
 *******************************************************/

/**
 *  Converts degrees to radians
 *
 *  @param degrees A value in degrees
 *
 *  @return A value in radians
 *
 *  @see radiansToDegrees
 */
NTR_INLINE float degreesToRadians( float degrees ){ return ( degrees * M_PI ) / 180.0f; };

/**
 *  Converts radians to degrees
 *
 *  @param radians A value in radians
 *
 *  @return A value in degrees
 *
 *  @see degreesToRadians
 */
NTR_INLINE float radiansToDegrees( float radians ){ return ( 180.0f * radians ) / M_PI; };

/*******************************************************
 
 Floating point numbers absolute error comparison utilities
 
 Although these functions are not suited for all floating point
 comparison cases, they will do fine many times.
 
 For a more in-depth discussion and other (way better) algorithms, see:
 - http://randomascii.wordpress.com/2012/02/25/comparing-floating-point-numbers-2012-edition/
 - http://randomascii.wordpress.com/category/floating-point/
 - http://www.cygnus-software.com/papers/comparingfloats/comparingfloats.htm
 
 *******************************************************/

/**
 *  Compares two floating point numbers, considering them different only if
 *  the difference between them is greater than epsilon
 *
 *  @return -1 if f1 is lesser than f2
 *  @return  0 if f1 and f2 are considered equal
 *  @return  1 if f1 is greater than f2
 *
 *  @see fcmp, feql_e, feql, fdif_e, fdif, fltn_e, fltn, fgtn_e, fgtn, fleq_e, fleq, fgeq_e, fgeq
 */
NTR_INLINE int8_t fcmp_e( float f1, float f2, float epsilon ){ return fabs( f1 - f2 ) <= epsilon ? 0 : ( f1 > f2 ? 1 : -1 ); };

/**
 *  Compares two floating point numbers, considering them different only if
 *  the difference between them is greater than FLT_EPSILON
 *
 *  @return -1 if f1 is lesser than f2
 *  @return  0 if f1 and f2 are considered equal
 *  @return  1 if f1 is greater than f2
 *
 *  @see fcmp_e, feql_e, feql, fdif_e, fdif, fltn_e, fltn, fgtn_e, fgtn, fleq_e, fleq, fgeq_e, fgeq
 */
NTR_INLINE int8_t fcmp( float f1, float f2 ){ return fcmp_e( f1, f2, FLT_EPSILON ); };

/**
 *  Returns if f1 is equal to f2. The numbers are considered different only if
 *  the difference between them is greater than epsilon
 *
 *  @see fcmp_e, fcmp, feql, fdif_e, fdif, fltn_e, fltn, fgtn_e, fgtn, fleq_e, fleq, fgeq_e, fgeq
 */
NTR_INLINE bool feql_e( float f1, float f2, float epsilon ){ return fcmp_e( f1, f2, epsilon ) == 0; };

/**
 *  Returns if f1 is equal to f2. The numbers are considered different only if
 *  the difference between them is greater than FLT_EPSILON
 *
 *  @see fcmp_e, fcmp, feql_e, fdif_e, fdif, fltn_e, fltn, fgtn_e, fgtn, fleq_e, fleq, fgeq_e, fgeq
 */
NTR_INLINE bool feql( float f1, float f2 ){ return feql_e( f1, f2, FLT_EPSILON ); };

/**
 *  Returns if f1 is different from f2. The numbers are considered different only if
 *  the difference between them is greater than epsilon
 *
 *  @see fcmp_e, fcmp, feql_e, feql, fdif, fltn_e, fltn, fgtn_e, fgtn, fleq_e, fleq, fgeq_e, fgeq
 */
NTR_INLINE bool fdif_e( float f1, float f2, float epsilon ){ return fcmp_e( f1, f2, epsilon ) != 0; };

/**
 *  Returns if f1 is different from f2. The numbers are considered different only if
 *  the difference between them is greater than FLT_EPSILON
 *
 *  @see fcmp_e, fcmp, feql_e, feql, fdif_e, fltn_e, fltn, fgtn_e, fgtn, fleq_e, fleq, fgeq_e, fgeq
 */
NTR_INLINE bool fdif( float f1, float f2 ){ return fdif_e( f1, f2, FLT_EPSILON ); };

/**
 *  Returns if f1 is lesser than f2. The numbers are considered different only if
 *  the difference between them is greater than epsilon
 *
 *  @see fcmp_e, fcmp, feql_e, feql, fdif_e, fdif, fltn, fgtn_e, fgtn, fleq_e, fleq, fgeq_e, fgeq
 */
NTR_INLINE bool fltn_e( float f1, float f2, float epsilon ){ return fcmp_e( f1, f2, epsilon ) == -1; };

/**
 *  Returns if f1 is lesser than f2. The numbers are considered different only if
 *  the difference between them is greater than FLT_EPSILON
 *
 *  @see fcmp_e, fcmp, feql_e, feql, fdif_e, fdif, fltn_e, fgtn_e, fgtn, fleq_e, fleq, fgeq_e, fgeq
 */
NTR_INLINE bool fltn( float f1, float f2 ){ return fltn_e( f1, f2, FLT_EPSILON ); };

/**
 *  Returns if f1 is greater than f2. The numbers are considered different only if
 *  the difference between them is greater than epsilon
 *
 *  @see fcmp_e, fcmp, feql_e, feql, fdif_e, fdif, fltn_e, fltn, fgtn, fleq_e, fleq, fgeq_e, fgeq
 */
NTR_INLINE bool fgtn_e( float f1, float f2, float epsilon ){ return fcmp_e( f1, f2, epsilon ) == 1; };

/**
 *  Returns if f1 is greater than f2. The numbers are considered different only if
 *  the difference between them is greater than FLT_EPSILON
 *
 *  @see fcmp_e, fcmp, feql_e, feql, fdif_e, fdif, fltn_e, fltn, fgtn_e, fleq_e, fleq, fgeq_e, fgeq
 */
NTR_INLINE bool fgtn( float f1, float f2 ){ return fgtn_e( f1, f2, FLT_EPSILON ); };

/**
 *  Returns if f1 is lesser or equal to f2. The numbers are considered different only if
 *  the difference between them is greater than epsilon
 *
 *  @see fcmp_e, fcmp, feql_e, feql, fdif_e, fdif, fltn_e, fltn, fgtn_e, fgtn, fleq, fgeq_e, fgeq
 */
NTR_INLINE bool fleq_e( float f1, float f2, float epsilon ){ return fcmp_e( f1, f2, epsilon ) <= 0; };

/**
 *  Returns if f1 is lesser or equal to f2. The numbers are considered different only if
 *  the difference between them is greater than FLT_EPSILON
 *
 *  @see fcmp_e, fcmp, feql_e, feql, fdif_e, fdif, fltn_e, fltn, fgtn_e, fgtn, fleq_e, fgeq_e, fgeq
 */
NTR_INLINE bool fleq( float f1, float f2 ){ return fleq_e( f1, f2, FLT_EPSILON ); };

/**
 *  Returns if f1 is greater or equal to f2. The numbers are considered different only if
 *  the difference between them is greater than epsilon
 *
 *  @see fcmp_e, fcmp, feql_e, feql, fdif_e, fdif, fltn_e, fltn, fgtn_e, fgtn, fleq_e, fleq, fgeq_e, fgeq
 */
NTR_INLINE bool fgeq_e( float f1, float f2, float epsilon ){ return fcmp_e( f1, f2, epsilon ) >= 0; };

/**
 *  Returns if f1 is greater or equal to f2. The numbers are considered different only if
 *  the difference between them is greater than FLT_EPSILON
 *
 *  @see fcmp_e, fcmp, feql_e, feql, fdif_e, fdif, fltn_e, fltn, fgtn_e, fgtn, fleq_e, fleq, fgeq_e
 */
NTR_INLINE bool fgeq( float f1, float f2 ){ return fgeq_e( f1, f2, FLT_EPSILON ); };
      
#ifdef __cplusplus
    } // math
} // nitro
#endif

#endif // NITRO_MATH_H
