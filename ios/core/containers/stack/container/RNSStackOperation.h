#pragma once

#import <Foundation/Foundation.h>

@class RNSStackScreenController;

NS_ASSUME_NONNULL_BEGIN

@interface RNSStackOperation : NSObject

@property (nonatomic, strong, readonly) RNSStackScreenController *screenController;

- (instancetype)initWithScreenController:(nonnull RNSStackScreenController *)screenController;

@end

@interface RNSPushOperation : RNSStackOperation

/** Whether UIKit animates the push when it is the last one of its batch. */
@property (nonatomic, readonly) BOOL animated;

- (instancetype)initWithScreenController:(nonnull RNSStackScreenController *)screenController animated:(BOOL)animated;

@end

@interface RNSPopOperation : RNSStackOperation

@end

NS_ASSUME_NONNULL_END
