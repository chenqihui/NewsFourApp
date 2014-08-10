//
//  ALDBlurImageProcessor.m
//  ALDBlurImageProcessor
//
//  Created by Daniel L. Alves on 13/03/14.
//  Copyright (c) 2014 Daniel L. Alves. All rights reserved.
//

#import "ALDBlurImageProcessor.h"

// ios
#import <Accelerate/Accelerate.h>

#pragma mark - Macros

// Just to get compilation errors and to be refactoring compliant. But this way we can't concat strings at compilation time =/
#define EVAL_AND_STRINGIFY(x) (x ? __STRING(x) : __STRING(x))

#pragma mark - Notification Consts

NSString * const ALDBlurImageProcessorImageReadyNotification = @"ald.blur-image-processor.image-ready";
NSString * const ALDBlurImageProcessorImageReadyNotificationBlurrredImageKey = @"ald.blur-image-processor.image-ready.blurred-image";

NSString * const ALDBlurImageProcessorImageProcessingErrorNotification = @"ald.blur-image-processor.image-processing-error";
NSString * const ALDBlurImageProcessorImageProcessingErrorNotificationErrorCodeKey = @"ald.blur-image-processor.image-processing-error.error-code-key";

#pragma mark - Class Extension

@interface ALDBlurImageProcessor()
{
    NSOperationQueue *imageBlurProcessingQueue;
    
    vImage_Buffer originalImageBuffer;
    vImage_Buffer processedImageBuffer;
    vImage_Buffer tempImageBuffer;
    
    NSBlockOperation *lastOperation;
}
@end

#pragma mark - Implementation

@implementation ALDBlurImageProcessor

#pragma mark - Accessors

-( void )setImageToProcess:( UIImage * )newImageToProcess
{
    @synchronized( self )
    {
        if( newImageToProcess != _imageToProcess )
        {
            _imageToProcess = newImageToProcess;
            [self initBlurProcessingBuffers];
        }
    }
}

#pragma mark - Ctors & Dtor

-( id )init
{
    self = [super init];
    if( self )
    {
        memset( &originalImageBuffer, 0, sizeof( vImage_Buffer ));
        memset( &processedImageBuffer, 0, sizeof( vImage_Buffer ));
        memset( &tempImageBuffer, 0, sizeof( vImage_Buffer ));
        
        imageBlurProcessingQueue = [NSOperationQueue new];
		imageBlurProcessingQueue.name = [NSString stringWithFormat: @"NTBlurImageProcessorProcessingQueue (%@)", self];
        
        // We need blur operations to run in the same order they were queued. Afterall, if
        // we are generating many blurred versions of the same image, we want to return
        // them in order
		imageBlurProcessingQueue.maxConcurrentOperationCount = 1;
        
        [self startListeningToMemoryWarnings];
    }
    return self;
}

-( instancetype )initWithImage:( UIImage * )image
{
    self = [self init];
    if( self )
        self.imageToProcess = image;

    return self;
}

-( void )dealloc
{
    [self stopListeningToMemoryWarnings];
    
    [self cancelAsyncBlurOperations];
    [self freeBlurProcessingBuffers];
}

#pragma mark - UIApplication Notifications Management

-( void )startListeningToMemoryWarnings
{
    [self stopListeningToMemoryWarnings];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( onMemoryWarning )
                                                 name: UIApplicationDidReceiveMemoryWarningNotification
                                               object: [UIApplication sharedApplication]];
}

-( void )stopListeningToMemoryWarnings
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIApplicationDidReceiveMemoryWarningNotification
                                                  object: [UIApplication sharedApplication]];
}

#pragma mark - Memory Management

-( void )onMemoryWarning
{
    [self freeTempBuffer];
}

-( void )freeBlurProcessingBuffers
{
    @synchronized( self )
    {
        if( originalImageBuffer.data )
        {
            free( originalImageBuffer.data );
            originalImageBuffer.data = nil;
        }
        
        if( processedImageBuffer.data )
        {
            free( processedImageBuffer.data );
            processedImageBuffer.data = nil;
        }
        
        [self freeTempBuffer];
    }
}

-( void )freeTempBuffer
{
    @synchronized( self )
    {
        if( tempImageBuffer.data )
        {
            free( tempImageBuffer.data );
            tempImageBuffer.data = nil;
        }
    }
}

-( void )initBlurProcessingBuffers
{
    @synchronized( self )
    {
        [self freeBlurProcessingBuffers];
        
        if( !_imageToProcess )
            return;
        
        CGImageRef imageRef = _imageToProcess.CGImage;
        [self initBlurProcessingBuffer: &originalImageBuffer forImage: imageRef];
        [self initBlurProcessingBuffer: &processedImageBuffer forImage: imageRef];
        [self initBlurProcessingBuffer: &tempImageBuffer forImage: imageRef];
        
        CFDataRef dataSource = CGDataProviderCopyData( CGImageGetDataProvider( imageRef ));
        memcpy( originalImageBuffer.data, CFDataGetBytePtr( dataSource ), originalImageBuffer.rowBytes * originalImageBuffer.height );
        memcpy( processedImageBuffer.data, CFDataGetBytePtr( dataSource ), processedImageBuffer.rowBytes * processedImageBuffer.height );
        CFRelease( dataSource );
    }
}

-( void )initBlurProcessingBuffer:( vImage_Buffer * )buffer forImage:( CGImageRef )image
{
    buffer->width = CGImageGetWidth( image );
    buffer->height = CGImageGetHeight( image );
    buffer->rowBytes = CGImageGetBytesPerRow( image );
    buffer->data = malloc( buffer->rowBytes * buffer->height );
}

#pragma mark - Blur Processing

-( UIImage * )blurImage:( UIImage * )originalImage
             withRadius:( uint32_t )radius
             iterations:( uint8_t )iterations
              errorCode:( out NSNumber ** )errorCode;
{
    @synchronized( self )
    {
        UIImage * cachedImage = [ALDBlurImageProcessor cachedBlurredImageForImage: _imageToProcess radius: radius iterations: iterations];
        if( cachedImage )
            return cachedImage;
        
        if( !_imageToProcess )
            return nil;
        
        vImage_Buffer finalImageBuffer;
        if( iterations == 0 || radius == 0 )
            return _imageToProcess;

        // Maybe we have freed memory on a memory warning notification, so we need to check it
        if( !tempImageBuffer.data )
            tempImageBuffer.data = malloc( tempImageBuffer.rowBytes * tempImageBuffer.height );
        
        // If we couldn't allocate memory, we'll be sorry, but we'll return the last image we generated
        // If we never generated a blurred image, that will be the original image
        if( tempImageBuffer.data )
        {
            // Radius must be an odd integer, or we'll get a kvImageInvalidKernelSize error. See
            // vImageBoxConvolve_ARGB8888 documentation for a better discussion
            uint32_t finalRadius = ( uint32_t )( radius * originalImage.scale );
            if(( finalRadius & 1 ) == 0 )
                ++finalRadius;
            
            // We must never lose the original image, so we can generated any number of blurred versions
            // out of it. This is why we copy its data to tempImageBuffer before proceeding
            memcpy( tempImageBuffer.data, originalImageBuffer.data, originalImageBuffer.rowBytes * originalImageBuffer.height );

            // The reason of the loop below is that many convolve iterations generate a better blurred image
            // than applying a greater convolve radius
            for( uint16_t i = 0 ; i < iterations ; ++i )
            {
                vImage_Error error = vImageBoxConvolve_ARGB8888( &tempImageBuffer, &processedImageBuffer, NULL, 0, 0, finalRadius, finalRadius, NULL, kvImageEdgeExtend );
                if( error != kvImageNoError )
                {
                    if( errorCode )
                        *errorCode = @(error);
                    
                    break;
                }

                void *temp = tempImageBuffer.data;
                tempImageBuffer.data = processedImageBuffer.data;
                processedImageBuffer.data = temp;
            }
            
            // The last processed image is being hold by tempImageBuffer. So let's fix it
            // by swaping buffers again
            void *temp = tempImageBuffer.data;
            tempImageBuffer.data = processedImageBuffer.data;
            processedImageBuffer.data = temp;
        }
        
        finalImageBuffer = processedImageBuffer;
        
        CGContextRef finalImageContext = CGBitmapContextCreate( finalImageBuffer.data,
                                                                finalImageBuffer.width,
                                                                finalImageBuffer.height,
                                                                8,
                                                                finalImageBuffer.rowBytes,
                                                                CGImageGetColorSpace( originalImage.CGImage ),
                                                                CGImageGetBitmapInfo( originalImage.CGImage ));
        
        // TODO : Here we could call a delegate with the context, so we could do a post process. Or
        // we could receive a block to do the same
        // ...
        
        CGImageRef finalImageRef = CGBitmapContextCreateImage( finalImageContext );
        UIImage *finalImage = [UIImage imageWithCGImage: finalImageRef scale: originalImage.scale orientation: originalImage.imageOrientation];
        CGImageRelease( finalImageRef );
        CGContextRelease( finalImageContext );
        
        [ALDBlurImageProcessor cacheBlurredImage: finalImage forImage: _imageToProcess radius: radius iterations: iterations];
        
        return finalImage;
    }
}

-( UIImage * )syncBlurWithRadius:( uint32_t )radius
                      iterations:( uint8_t )iterations
                       errorCode:( out NSNumber * __autoreleasing * )errorCode
{
    if( !_imageToProcess )
        [NSException raise: NSInvalidArgumentException format: @"%s must not be nil", EVAL_AND_STRINGIFY(_imageToProcess)];
    
    return [self blurImage: _imageToProcess
                withRadius: radius
                iterations: iterations
                 errorCode: errorCode];
}

-( void )asyncBlurWithRadius:( uint32_t )radius
                  iterations:( uint8_t )iterations
{
    [self asyncBlurWithRadius: radius
                   iterations: iterations
       cancelingLastOperation: NO
                 successBlock: nil
                   errorBlock: nil];
}

-( void )asyncBlurWithRadius:( uint32_t )radius
                  iterations:( uint8_t )iterations
      cancelingLastOperation:( BOOL )cancelLastOperation
{
    [self asyncBlurWithRadius: radius
                   iterations: iterations
       cancelingLastOperation: cancelLastOperation
                 successBlock: nil
                   errorBlock: nil];
}

-( void )asyncBlurWithRadius:( uint32_t )radius
                  iterations:( uint8_t )iterations
             successBlock:( void(^)( UIImage *blurredImage ) )successBlock
               errorBlock:( void(^)( NSNumber *errorCode ) )errorBlock;
{
    [self asyncBlurWithRadius: radius
                   iterations: iterations
       cancelingLastOperation: NO
                 successBlock: successBlock
                   errorBlock: errorBlock];
}

-( void )asyncBlurWithRadius:( uint32_t )radius
                  iterations:( uint8_t )iterations
      cancelingLastOperation:( BOOL )cancelLastOperation
                successBlock:( void(^)( UIImage *blurredImage ) )successBlock
                  errorBlock:( void(^)( NSNumber *errorCode ) )errorBlock;
{
    if( !_imageToProcess )
        [NSException raise: NSInvalidArgumentException format: @"%s must not be nil", EVAL_AND_STRINGIFY(_imageToProcess)];
    
    if( cancelLastOperation )
        [lastOperation cancel];

    NSOperationQueue *callingQueue = [NSOperationQueue currentQueue];
    if( !callingQueue )
        callingQueue = [NSOperationQueue mainQueue];
    
    NSBlockOperation *blurOperation = [[NSBlockOperation alloc] init];

    __weak NSBlockOperation *weakOperation = blurOperation;
    __weak ALDBlurImageProcessor *weakSelf = self;
    
    [blurOperation addExecutionBlock:^{

        NSNumber *errorCode;
        UIImage *blurredImage = [weakSelf blurImage: _imageToProcess
                                         withRadius: radius
                                         iterations: iterations
                                          errorCode: &errorCode];
        
        NSBlockOperation *notificationOperation = [[NSBlockOperation alloc] init];
        [notificationOperation addExecutionBlock: ^{
            
            if( !weakOperation || weakOperation.isCancelled )
                return;
            
            if( errorCode )
            {
                if( [weakSelf.delegate respondsToSelector: @selector( onALDBlurImageProcessor:blurProcessingErrorCode: )] )
                    [weakSelf.delegate onALDBlurImageProcessor: weakSelf blurProcessingErrorCode: errorCode ];
                
                if( errorBlock )
                    errorBlock( errorCode );
                
                [[NSNotificationCenter defaultCenter] postNotificationName: ALDBlurImageProcessorImageProcessingErrorNotification
                                                                    object: weakSelf
                                                                  userInfo: @{ ALDBlurImageProcessorImageProcessingErrorNotificationErrorCodeKey: errorCode }];
                
            }
            else
            {
                if( [weakSelf.delegate respondsToSelector: @selector( onALDBlurImageProcessor:newBlurrredImage: )] )
                    [weakSelf.delegate onALDBlurImageProcessor: weakSelf newBlurrredImage: blurredImage];
                
                if( successBlock )
                    successBlock( blurredImage );
                
                [[NSNotificationCenter defaultCenter] postNotificationName: ALDBlurImageProcessorImageReadyNotification
                                                                    object: weakSelf
                                                                  userInfo: @{ ALDBlurImageProcessorImageReadyNotificationBlurrredImageKey: blurredImage }];
            }
        }];
        
        [callingQueue addOperation: notificationOperation];
    }];
    
    // TODO : These 2 NSBlockOperation properties, queuePriority and threadPriority, could
    // be parameterized
    blurOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
    blurOperation.threadPriority = 1.0f;
    
    [imageBlurProcessingQueue addOperation: blurOperation];
    
    lastOperation = blurOperation;
}

#pragma mark - NSOperationQueue Management

-( void )cancelAsyncBlurOperations
{
    [imageBlurProcessingQueue cancelAllOperations];
}

#pragma mark - Class methods

+( NSString * )blurredImagesCacheKeyForImage:( UIImage * )image
                                      radius:( uint32_t )radius
                                  iterations:( uint8_t )iterations
{
    return [NSString stringWithFormat: @"%p-%d-%d", image, radius, iterations];
}

+( NSMapTable * )blurredImagesCache
{
    @synchronized( self )
    {
        static NSMapTable *blurredImagesCache = nil;
        if( !blurredImagesCache )
            blurredImagesCache = [NSMapTable strongToWeakObjectsMapTable];
        
        return blurredImagesCache;
    }
}

+( UIImage * )cachedBlurredImageForImage:( UIImage * )image
                                  radius:( uint32_t )radius
                              iterations:( uint8_t )iterations
{
    // We don't cache original images
    if( radius == 0 || iterations == 0 )
        return nil;
    
    @synchronized( self )
    {
        NSString *cacheKey = [ALDBlurImageProcessor blurredImagesCacheKeyForImage: image
                                                                           radius: radius
                                                                       iterations: iterations];
        
        return [[ALDBlurImageProcessor blurredImagesCache] objectForKey: cacheKey];
    }
}

+( void )cacheBlurredImage:( UIImage * )blurredImage
                  forImage:( UIImage * )image
                    radius:( uint32_t )radius
                iterations:( uint8_t )iterations
{
    // We don't want to cache original images
    if( radius == 0 || iterations == 0 )
        return;
    
    @synchronized( self )
    {
        NSString *cacheKey = [ALDBlurImageProcessor blurredImagesCacheKeyForImage: image
                                                                           radius: radius
                                                                       iterations: iterations];
        
        [[ALDBlurImageProcessor blurredImagesCache] setObject: blurredImage forKey: cacheKey];
    }
}

@end












































