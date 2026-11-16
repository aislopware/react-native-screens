#pragma once

#import "RNSStackNavigationController.h"
#import "RNSStackScreenProviding.h"

@interface RNSStackOperationCoordinator : NSObject

- (void)addPushOperation:(nonnull UIView<RNSStackScreenProviding> *)screen;

- (void)addPopOperation:(nonnull UIView<RNSStackScreenProviding> *)screen;

/**
 * Hands the pending operations to the navigation controller: pops in the order of the native stack, pushes ordered
 * by the screens' React index. The caller commits the navigation controller's transaction.
 */
- (void)enqueuePendingOperationsIfNeeded:(nonnull RNSStackNavigationController *)controller
                     withRenderedScreens:(nonnull NSArray<UIView<RNSStackScreenProviding> *> *)renderedScreens;

@end
