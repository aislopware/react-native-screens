#pragma once

#import "RNSReactBaseView.h"
#import "RNSSafeAreaProviding.h"
#import "RNSStackScreenComponentEventEmitter.h"
#import "RNSStackScreenProviding.h"

NS_ASSUME_NONNULL_BEGIN

@class RNSStackScreenController;
@class RNSStackHostComponentView;
@class RNSHeaderConfigComponentView;

@interface RNSStackScreenComponentView : RNSReactBaseView <RNSStackScreenProviding, RNSSafeAreaProviding>

@property (nonatomic, weak, readwrite, nullable) RNSStackHostComponentView *stackHost;
@property (nonatomic, weak, readonly, nullable) RNSHeaderConfigComponentView *headerConfig;
@property (nonatomic, strong, readonly, nonnull) RNSStackScreenController *controller;
@property (nonatomic, readonly) BOOL isNativelyDismissed;
@property (nonatomic, readonly) BOOL preventNativeDismiss;

@end

#pragma mark - Props

@interface RNSStackScreenComponentView ()

@property (nonatomic, strong, readonly, nullable) NSString *screenKey;
@property (nonatomic, readonly) RNSStackScreenActivityMode activityMode;

@end

#pragma mark - Events

@interface RNSStackScreenComponentView ()

/**
 * Use returned object to emit appropriate React Events to Element Tree.
 */
- (nonnull RNSStackScreenComponentEventEmitter *)reactEventEmitter;

@end

NS_ASSUME_NONNULL_END
