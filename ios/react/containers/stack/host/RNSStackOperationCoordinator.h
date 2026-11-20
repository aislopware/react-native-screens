#pragma once

#import "RNSStackNavigationController.h"
#import "RNSStackScreenComponentView.h"

@interface RNSStackOperationCoordinator : NSObject

- (void)addPushOperation:(nonnull RNSStackScreenComponentView *)screen;

- (void)addPopOperation:(nonnull RNSStackScreenComponentView *)screen;

/**
 * Hands the pending operations to the navigation controller: pops in the order of the native stack, pushes ordered
 * by the screens' React index. The caller commits the navigation controller's transaction.
 */
- (void)enqueuePendingOperationsIfNeeded:(nonnull RNSStackNavigationController *)controller
                     withRenderedScreens:(nonnull NSMutableArray<RNSStackScreenComponentView *> *)renderedScreens;

@end
