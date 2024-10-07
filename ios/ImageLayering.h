
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNImageLayeringSpec.h"

@interface ImageLayering : NSObject <NativeImageLayeringSpec>
#else
#import <React/RCTBridgeModule.h>

@interface ImageLayering : NSObject <RCTBridgeModule>
#endif

@end
