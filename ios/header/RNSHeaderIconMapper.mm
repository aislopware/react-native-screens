#import "RNSHeaderIconMapper.h"

static RNSHeaderIconImageSource RNSHeaderIconImageSourceFromDictionary(NSDictionary *source)
{
  return RNSHeaderIconImageSource{
      .source = source,
      .size = CGSizeMake([source[@"width"] doubleValue], [source[@"height"] doubleValue]),
      .scale = [source[@"scale"] doubleValue],
  };
}

@implementation RNSHeaderIconMapper

+ (nullable RNSHeaderIconData *)iconFromDictionary:(nullable id)dictionary
{
  if (![dictionary isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  NSDictionary *dict = (NSDictionary *)dictionary;

  NSString *type = dict[@"type"];
  if (![type isKindOfClass:[NSString class]]) {
    return nil;
  }

  if ([type isEqualToString:@"sfSymbol"]) {
    return [[RNSHeaderIconData alloc] initWithType:RNSHeaderIconTypeSfSymbol
                                      resourceName:dict[@"name"]
                                       imageSource:RNSHeaderIconImageSource{}];
  }

  if ([type isEqualToString:@"xcasset"]) {
    return [[RNSHeaderIconData alloc] initWithType:RNSHeaderIconTypeXcasset
                                      resourceName:dict[@"name"]
                                       imageSource:RNSHeaderIconImageSource{}];
  }

  if ([type isEqualToString:@"imageSource"]) {
    NSDictionary *source = dict[@"imageSource"];
    if (![source isKindOfClass:[NSDictionary class]]) {
      return nil;
    }
    return [[RNSHeaderIconData alloc] initWithType:RNSHeaderIconTypeImageSource
                                      resourceName:nil
                                       imageSource:RNSHeaderIconImageSourceFromDictionary(source)];
  }

  if ([type isEqualToString:@"templateSource"]) {
    NSDictionary *source = dict[@"templateSource"];
    if (![source isKindOfClass:[NSDictionary class]]) {
      return nil;
    }
    return [[RNSHeaderIconData alloc] initWithType:RNSHeaderIconTypeTemplateSource
                                      resourceName:nil
                                       imageSource:RNSHeaderIconImageSourceFromDictionary(source)];
  }

  return nil;
}

@end
