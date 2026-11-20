#pragma once

#import <UIKit/UIKit.h>
#import "RNSDefines.h"

/**
 * What a search bar rendered in a stack header provides to the header coordinator.
 */
@protocol RNSStackHeaderSearchBarProviding <NSObject>

@property (nonatomic, readonly) UISearchController *controller;
@property (nonatomic, readonly) BOOL hideWhenScrolling;
@property (nonatomic, readonly) BOOL allowToolbarIntegration;

#if RNS_IPHONE_OS_VERSION_AVAILABLE(16_0) && !TARGET_OS_TV
- (UINavigationItemSearchBarPlacement)placementAsUINavigationItemSearchBarPlacement API_AVAILABLE(ios(16.0))
    API_UNAVAILABLE(tvos, watchos);
#endif // Check for iOS >= 16 && !TARGET_OS_TV

@end
