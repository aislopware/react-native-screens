#pragma once

#import <Foundation/Foundation.h>

#import "RNSHeaderIconData.h"
#import "RNSHeaderMenuData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Typed options for menu item updates.
 * `has*` flags distinguish "no change" (key absent) from "reset" (key present, null value).
 */
@interface RNSMenuItemUpdateOptions : NSObject

@property (nonatomic, readonly) BOOL hasTitle;
@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, readonly) BOOL hasIcon;
@property (nonatomic, strong, readonly, nullable) RNSHeaderIconData *icon;
@property (nonatomic, readonly) BOOL hasToggleState;
@property (nonatomic, readonly) BOOL toggleState;
@property (nonatomic, readonly) BOOL hasState;
@property (nonatomic, readonly) UIMenuElementState state;

- (instancetype)initWithTitle:(nullable NSString *)title
                     hasTitle:(BOOL)hasTitle
                         icon:(nullable RNSHeaderIconData *)icon
                      hasIcon:(BOOL)hasIcon
               hasToggleState:(BOOL)hasToggleState
                  toggleState:(BOOL)toggleState
                     hasState:(BOOL)hasState
                        state:(UIMenuElementState)state;

+ (RNSHeaderMenuItemData *)applyOptions:(RNSMenuItemUpdateOptions *)options toMenuItem:(RNSHeaderMenuItemData *)old;

@end

/**
 * Typed options for submenu updates.
 * `has*` flags distinguish "no change" (key absent) from "reset" (key present, null value).
 */
@interface RNSMenuUpdateOptions : NSObject

@property (nonatomic, readonly) BOOL hasTitle;
@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, readonly) BOOL hasIcon;
@property (nonatomic, strong, readonly, nullable) RNSHeaderIconData *icon;

- (instancetype)initWithTitle:(nullable NSString *)title
                     hasTitle:(BOOL)hasTitle
                         icon:(nullable RNSHeaderIconData *)icon
                      hasIcon:(BOOL)hasIcon;

+ (RNSHeaderMenuData *)applyOptions:(RNSMenuUpdateOptions *)options toMenu:(RNSHeaderMenuData *)old;

@end

NS_ASSUME_NONNULL_END
