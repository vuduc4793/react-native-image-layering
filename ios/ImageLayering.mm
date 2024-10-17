#import "ImageLayering.h"

@implementation ImageLayering
RCT_EXPORT_MODULE()

// Example method
// See // https://reactnative.dev/docs/native-modules-ios

RCT_EXPORT_METHOD(multiply:(double)a
                  b:(double)b
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    NSNumber *result = @(a * b);

    resolve(result);
}

RCT_EXPORT_METHOD(imageLayering:(NSString*)layer_one
                  layer_two:(NSString*)layer_two
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [self mergeImagesAndSaveWithInput:layer_one overlayImageInput:layer_two resolve: resolve reject: reject];
}


- (void)mergeImagesAndSaveWithInput:(NSString *)image1Input
                  overlayImageInput:(NSString *)image2Input
                            resolve:(RCTPromiseResolveBlock)resolve
                             reject:(RCTPromiseRejectBlock)reject{
    UIImage *image1 = [self getImageFromInput:image1Input];
    UIImage *image2 = [self getImageFromInput:image2Input];
    
    if (image1 != nil && image2 != nil) {
        [self mergeImagesAndSave:image1 overlayImage:image2 resolve: resolve reject: reject];
    } else {
        reject(@"INPUT_ERROR", @"Input image invalid", nil);
    }
}

- (UIImage *)getImageFromInput:(NSString *)imageInput {
    UIImage *image = nil;
    
    if ([imageInput hasPrefix:@"data:image"]) {
        NSRange commaRange = [imageInput rangeOfString:@","];
        if (commaRange.location != NSNotFound) {
            NSString *base64String = [imageInput substringFromIndex:commaRange.location + 1];
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
            image = [UIImage imageWithData:imageData];
        }
    } else {
        image = [UIImage imageWithContentsOfFile:imageInput];
    }
    
    return image;
}

- (void)mergeImagesAndSave:(UIImage *)image1 overlayImage:(UIImage *)image2 
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject {
    
    CGSize resizedSize = CGSizeMake(image2.size.width / 3, image2.size.height / 3);
    UIGraphicsBeginImageContextWithOptions(resizedSize, NO, 0.0);
    
    [image1 drawInRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height)];
    [image2 drawInRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *combinedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (combinedImage != nil) {
        NSData *imageData = UIImagePNGRepresentation(combinedImage);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSUUID *uuid = [NSUUID UUID];
        NSString *fileName = [uuid UUIDString];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[fileName stringByAppendingString:@".png"]];
        
        [imageData writeToFile:filePath atomically:YES];
        NSDictionary *outputImageInfo = @{
                @"filePath": filePath,
                @"width": @(combinedImage.size.width),
                @"height": @(combinedImage.size.height)
            };
        resolve(outputImageInfo);
        NSLog(@"Saved Image: %@", filePath);
    } else {
        reject(@"COMBINE_ERROR", @"Combine image error", nil);
    }
}

@end
