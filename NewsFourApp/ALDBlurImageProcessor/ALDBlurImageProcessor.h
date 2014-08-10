//
//  ALDBlurImageProcessor.h
//  ALDBlurImageProcessor
//
//  Created by Daniel L. Alves on 13/03/14.
//  Copyright (c) 2014 Daniel L. Alves. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The userInfo dictionary contains information about the new blurred image. Use the key ALDBlurImageProcessorImageReadyNotificationBlurrredImageKey
 *  to get it.
 */
FOUNDATION_EXPORT NSString * const ALDBlurImageProcessorImageReadyNotification;

/**
 *  The key for an UIImage object, which is the new allocated blurred image.
 */
FOUNDATION_EXPORT NSString * const ALDBlurImageProcessorImageReadyNotificationBlurrredImageKey;

/**
 *  The userInfo dictionary contains information about the blur processing error. Use the key ALDBlurImageProcessorImageProcessingErrorNotificationErrorCodeKey
 *  to get it.
 */
FOUNDATION_EXPORT NSString * const ALDBlurImageProcessorImageProcessingErrorNotification;

/**
 *  The key for a NSNumber object, which boxes a vImage_Error error code.
 */
FOUNDATION_EXPORT NSString * const ALDBlurImageProcessorImageProcessingErrorNotificationErrorCodeKey;



@class ALDBlurImageProcessor;

/**
 *  The methods declared by the ALDBlurImageProcessorDelegate protocol allow the adopting delegate to respond to messages from the ALDBlurImageProcessor class.
 */
@protocol ALDBlurImageProcessorDelegate< NSObject >

    @optional
        /**
         *  Tells the delegate when a blur processing error has occurred.
         *
         *  @param blurImageProcessor The object which generated the call.
         *  @param errorCode          A NSNumber object boxing a vImage_Error error code.
         */
        -( void )onALDBlurImageProcessor:( ALDBlurImageProcessor * )blurImageProcessor blurProcessingErrorCode:( NSNumber * )errorCode;

        /**
         *  Tells the delegate when a new blurred image has been generated.
         *
         *  @param blurImageProcessor The object which generated the call.
         *  @param image              The new allocated blurred image.
         */
        -( void )onALDBlurImageProcessor:( ALDBlurImageProcessor * )blurImageProcessor newBlurrredImage:( UIImage * )image;
@end



/**
 *  ALDBlurImageProcessor offers a very easy and practical way to generate blurred images in real time. After an image
 *  is specified to be targeted by it, every new blur operation will create a new allocated image. Varying the value of 
 *  radiuses and iterations, its possible to create many different results and even animations.
 *
 *  Blur operations can be synchronous and asynchronous. Synchronous operations run on the thread/operation queue from which they
 *  were called. Each ALDBlurImageProcessor object has its own processing queue to run asynchronous operations, so it it easy to 
 *  manage them. Besides that, all delegate callbacks, notifications and blocks are called/fired on the same thread/operation queue
 *  from which the async blur processing operation was called. So there's no need to worry about using new blurred images directly
 *  into the user interface if you fired the operations from the main thread/operation queue.
 *
 *  ALDBlurImageProcessor tries to achieve a good balance between memory and performance. It listens to
 *  UIApplicationDidReceiveMemoryWarningNotification notifications to clean temporary internal buffers on low memory conditions. In
 *  addition to that, it has an intelligent cache system: every blurredimage keeps cached while it is still living in the outside app.
 *  So, if you call another blur operation with the same radius and iterations paramneters on the same original image, no processing occurs.
 *  When the outside app stops referencing the blurred image, it is automatically removed from the cache, so there is no memory waste.
 */
@interface ALDBlurImageProcessor : NSObject

/**
 *  The image which will be targeted by blur operations. This can be changed after
 *  the object has been created with no side effects.
 */
@property( nonatomic, readwrite, strong )UIImage *imageToProcess;

/**
 *  The delegate of the ALDBlurImageProcessor object. The delegate must adopt the ALDBlurImageProcessorDelegate protocol.
 */
@property( nonatomic, readwrite, weak )id< ALDBlurImageProcessorDelegate > delegate;

/**
 *  Initializes and returns a newly allocated ALDBlurImageProcessor object targeting the specified image.
 *
 *  @param image The image which will be targeted by blur operations.
 *
 *  @return An initialized ALDBlurImageProcessor object or nil if the object couldn't be created.
 */
-( instancetype )initWithImage:( UIImage * )image;

/**
 *  Generates a new allocated blurred image synchronously. This method does not call the delegate or fire notifications.
 *
 *  @param radius             The radius of the blur, specifying how many pixels will be considered when generating the output pixel
 *                            value. For algorithm reasons, this must be an odd number. If you pass an even number, it will be increased
 *                            by 1. If radius is equal to zero, no blur will happen and the original image will be passed as the result.
 *
 *  @param iterations         The number of times radius will be applied to the image. The higher iterations is, the slower
 *                            the output will be generated. Varying the number of iterations, combined with a static value of
 *                            radius, typically create a smoother blurred image than just increasing the radius value. If iterations
 *                            is equal to zero, no blur will happen and the original image will be passed as the result.
 *
 *  @param errorCode          On output, a NSNumber object boxing a vImage_Error error code.
 *
 *  @return A new allocated blurred image
 *
 *  @throws NSInvalidArgumentException if imageToProcess is nil
 *
 *  @see asyncBlurWithRadius:iterations:
 *  @see asyncBlurWithRadius:iterations:successBlock:errorBlock:
 *  @see asyncBlurWithRadius:iterations:cancelingLastOperation:
 *  @see asyncBlurWithRadius:iterations:cancelingLastOperation:successBlock:errorBlock:
 */
-( UIImage * )syncBlurWithRadius:( uint32_t )radius
                      iterations:( uint8_t )iterations
                       errorCode:( out NSNumber ** )errorCode;

/**
 *  This is the same as calling asyncBlurWithRadius:iterations:cancelingLastOperation: with
 *  cancelingLastOperation equal to NO.
 *
 *  @param radius             The radius of the blur, specifying how many pixels will be considered when generating the output pixel
 *                            value. For algorithm reasons, this must be an odd number. If you pass an even number, it will be increased
 *                            by 1. If radius is equal to zero, no blur will happen and the original image will be passed as the result.
 *
 *  @param iterations         The number of times radius will be applied to the image. The higher iterations is, the slower
 *                            the output will be generated. Varying the number of iterations, combined with a static value of
 *                            radius, typically create a smoother blurred image than just increasing the radius value. If iterations
 *                            is equal to zero, no blur will happen and the original image will be passed as the result.
 *
 *  @throws NSInvalidArgumentException if imageToProcess is nil
 *
 *  @see syncBlurWithRadius:iterations:errorCode:
 *  @see asyncBlurWithRadius:iterations:successBlock:errorBlock:
 *  @see asyncBlurWithRadius:iterations:cancelingLastOperation:
 *  @see asyncBlurWithRadius:iterations:cancelingLastOperation:successBlock:errorBlock:
 *  @see cancelAsyncBlurOperations
 */
-( void )asyncBlurWithRadius:( uint32_t )radius
                  iterations:( uint8_t )iterations;

/**
 *  This is the same as calling asyncBlurWithRadius:iterations:cancelingLastOperation:successBlock:errorBlock: with
 *  cancelingLastOperation equal to NO.
 *
 *  @param radius             The radius of the blur, specifying how many pixels will be considered when generating the output pixel
 *                            value. For algorithm reasons, this must be an odd number. If you pass an even number, it will be increased
 *                            by 1. If radius is equal to zero, no blur will happen and the original image will be passed as the result.
 *
 *  @param iterations         The number of times radius will be applied to the image. The higher iterations is, the slower
 *                            the output will be generated. Varying the number of iterations, combined with a static value of
 *                            radius, typically create a smoother blurred image than just increasing the radius value. If iterations
 *                            is equal to zero, no blur will happen and the original image will be passed as the result.
 *
 *  @param successBlock        The callback block called when a new blurred image has been generated. It will never be called
 *                             simultaneously with errorBlock.
 *
 *  @param errorBlock          The callback block called when a blur processing error has occurred. It will never be called
 *                             simultaneously with successBlock.
 *
 *  @throws NSInvalidArgumentException if imageToProcess is nil
 *
 *  @see syncBlurWithRadius:iterations:errorCode:
 *  @see asyncBlurWithRadius:iterations:
 *  @see asyncBlurWithRadius:iterations:cancelingLastOperation:
 *  @see asyncBlurWithRadius:iterations:cancelingLastOperation:successBlock:errorBlock:
 *  @see cancelAsyncBlurOperations
 */
-( void )asyncBlurWithRadius:( uint32_t )radius
                  iterations:( uint8_t )iterations
                successBlock:( void(^)( UIImage *blurredImage ) )successBlock
                  errorBlock:( void(^)( NSNumber *errorCode ) )errorBlock;

/**
 *  Queues an asynchronous blur operation, targeting imageToProcess, on this object operation queue. When the new 
 *  blurred image is ready, or when an error occurs, calls the delegate and fires the respective notification, both on
 *  the thread/operation queue from which the async blur operation was fired.
 *
 *  @param radius              The radius of the blur, specifying how many pixels will be considered when generating the output pixel
 *                             value. For algorithm reasons, this must be an odd number. If you pass an even number, it will be increased
 *                             by 1. If radius is equal to zero, no blur will happen and the original image will be passed as the result.
 *
 *  @param iterations          The number of times radius will be applied to the image. The higher iterations is, the slower
 *                             the output will be generated. Varying the number of iterations, combined with a static value of
 *                             radius, typically create a smoother blurred image than just increasing the radius value. If iterations
 *                             is equal to zero, no blur will happen and the original image will be passed as the result.
 *
 *  @param cancelLastOperation YES if the last queued asynchronous blur operation should be canceled. NO otherwise. If there is
 *                             no asynchronous blur operation queued or all of them have already been processed, cancelLastOperation
 *                             is ignored. This parameter is useful when there's a need to opt between generating all blur operations 
 *                             ouputs or just having the last blur operation output as fast as possible.
 *
 *  @throws NSInvalidArgumentException if imageToProcess is nil
 *
 *  @see syncBlurWithRadius:iterations:errorCode:
 *  @see asyncBlurWithRadius:iterations:
 *  @see asyncBlurWithRadius:iterations:successBlock:errorBlock:
 *  @see asyncBlurWithRadius:iterations:cancelingLastOperation:successBlock:errorBlock:
 *  @see cancelAsyncBlurOperations
 */
-( void )asyncBlurWithRadius:( uint32_t )radius
                  iterations:( uint8_t )iterations
      cancelingLastOperation:( BOOL )cancelLastOperation;

/**
 *  Queues an asynchronous blur operation, targeting imageToProcess, on this object operation queue. When the new
 *  blurred image is ready, or when an error occurs, calls the delegate, the respective block and fires the respective
 *  notification, all three operations on the thread/operation queue from which the async blur operation was fired.
 *
 *  @param radius              The radius of the blur, specifying how many pixels will be considered when generating the output pixel
 *                             value. For algorithm reasons, this must be an odd number. If you pass an even number, it will be increased
 *                             by 1. If radius is equal to zero, no blur will happen and the original image will be passed as the result.
 *
 *  @param iterations          The number of times radius will be applied to the image. The higher iterations is, the slower
 *                             the output will be generated. Varying the number of iterations, combined with a static value of
 *                             radius, typically create a smoother blurred image than just increasing the radius value. If iterations
 *                             is equal to zero, no blur will happen and the original image will be passed as the result.
 *
 *  @param cancelLastOperation YES if the last queued asynchronous blur operation should be canceled. NO otherwise. If there is
 *                             no asynchronous blur operation queued or all of them have already been processed, cancelLastOperation
 *                             is ignored. This parameter is useful when there's a need to opt between generating all blur operations
 *                             ouputs or just having the last blur operation output as fast as possible.
 *
 *  @param successBlock        The callback block called when a new blurred image has been generated. It will never be called
 *                             simultaneously with errorBlock.
 *
 *  @param errorBlock          The callback block called when a blur processing error has occurred. It will never be called
 *                             simultaneously with successBlock.
 *
 *  @throws NSInvalidArgumentException if imageToProcess is nil
 *
 *  @see syncBlurWithRadius:iterations:errorCode:
 *  @see asyncBlurWithRadius:iterations:
 *  @see asyncBlurWithRadius:iterations:successBlock:errorBlock:
 *  @see asyncBlurWithRadius:iterations:cancelingLastOperation:
 *  @see cancelAsyncBlurOperations
 */
-( void )asyncBlurWithRadius:( uint32_t )radius
                  iterations:( uint8_t )iterations
      cancelingLastOperation:( BOOL )cancelLastOperation
                successBlock:( void(^)( UIImage *blurredImage ) )successBlock
                  errorBlock:( void(^)( NSNumber *errorCode ) )errorBlock;

/**
 *  Cancels all asynchronous blur operations queued in this object processing queue.
 *
 *  @see asyncBlurWithRadius:iterations:
 *  @see asyncBlurWithRadius:iterations:successBlock:errorBlock:
 *  @see asyncBlurWithRadius:iterations:cancelingLastOperation:
 *  @see asyncBlurWithRadius:iterations:cancelingLastOperation:successBlock:errorBlock:
 */
-( void )cancelAsyncBlurOperations;

@end
