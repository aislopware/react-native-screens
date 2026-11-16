#import "RNSHeaderIconData.h"

@implementation RNSHeaderIconData

- (instancetype)initWithType:(RNSHeaderIconType)iconType
                resourceName:(nullable NSString *)resourceName
                 imageSource:(RNSHeaderIconImageSource)imageSource
{
  if (self = [super init]) {
    _iconType = iconType;
    _resourceName = [resourceName copy];
    _imageSource = imageSource;
  }
  return self;
}

@end
