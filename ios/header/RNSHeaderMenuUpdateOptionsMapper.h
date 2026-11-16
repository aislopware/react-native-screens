#pragma once

#import <Foundation/Foundation.h>

#import "RNSHeaderMenuUpdateOptions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Parses the `setMenuItemOptions` / `setMenuOptions` command dictionaries into typed update options.
 * `has*` flags distinguish "no change" (key absent) from "reset" (key present, null value).
 */
@interface RNSHeaderMenuUpdateOptionsMapper : NSObject

+ (RNSMenuItemUpdateOptions *)menuItemUpdateOptionsFromDictionary:(NSDictionary *)dict;

+ (RNSMenuUpdateOptions *)menuUpdateOptionsFromDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
