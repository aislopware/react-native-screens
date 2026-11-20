#pragma once

#import "RNSContainer.h"
#import "RNSContainerTransactionSupporting.h"
#include "RNSStackNavigationBarCoordinator.h"

@protocol RNSViewControllerViewLifecycleEventsObserver;
@protocol RNSViewFrameChangeDelegate;

@interface RNSStackNavigationController : UINavigationController <RNSContainer, RNSContainerTransactionSupporting>

@property (nonatomic, weak, nullable) id<RNSViewFrameChangeDelegate> navigationBarFrameChangeDelegate;

/**
 * Notified about the lifecycle events of this controller's view.
 */
@property (nonatomic, weak, nullable) id<RNSViewControllerViewLifecycleEventsObserver> viewLifecycleEventsObserver;

@property (nonatomic, readonly, nonnull) RNSStackNavigationBarCoordinator *navigationBarCoordinator;

/** Split columns use a native placeholder while empty. Standalone stacks keep their root screen by default. */
@property (nonatomic) BOOL allowsEmptyStack;

@property (nonatomic, readonly, getter=isStackEmpty) BOOL stackEmpty;

#if !TARGET_OS_TV
- (nonnull UIBarButtonItem *)toolbarIconButtonForIdentifier:(nonnull NSString *)identifier;
#endif

/** Takes the controller of a stack screen, or of a split screen routed to a column's stack. */
- (void)enqueuePushOperation:(nonnull UIViewController *)screenController animated:(BOOL)animated;

- (void)enqueuePopOperation:(nonnull UIViewController *)screenController;

@end
