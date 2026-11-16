#pragma once

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNSStackOperation : NSObject

/** The controller of the screen; a stack screen or a split screen routed to a column's stack. */
@property (nonatomic, strong, readonly) UIViewController *screenController;

- (instancetype)initWithScreenController:(nonnull UIViewController *)screenController;

@end

@interface RNSPushOperation : RNSStackOperation

@end

@interface RNSPopOperation : RNSStackOperation

@end

NS_ASSUME_NONNULL_END
