#pragma once

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RNSHeaderIconType) {
  RNSHeaderIconTypeSfSymbol,
  RNSHeaderIconTypeXcasset,
  RNSHeaderIconTypeImageSource,
  RNSHeaderIconTypeTemplateSource,
};

/**
 * Image source of `RNSHeaderIconTypeImageSource` / `RNSHeaderIconTypeTemplateSource` icons.
 */
typedef struct {
  /**
   * Loaded through `RNSImageLoading`. Opaque to `core`.
   */
  __strong id _Nullable source;

  /**
   * Size and scale the source declares, used for a placeholder until the image loads. Zero when not declared.
   */
  CGSize size;
  CGFloat scale;
} RNSHeaderIconImageSource;

@interface RNSHeaderIconData : NSObject

@property (nonatomic, readonly) RNSHeaderIconType iconType;
@property (nonatomic, copy, readonly, nullable) NSString *resourceName;

@property (nonatomic, readonly) RNSHeaderIconImageSource imageSource;

@property (nonatomic, strong, nullable) UIImage *resolvedImage;

- (instancetype)initWithType:(RNSHeaderIconType)iconType
                resourceName:(nullable NSString *)resourceName
                 imageSource:(RNSHeaderIconImageSource)imageSource;

@end

NS_ASSUME_NONNULL_END
