#pragma once

#import "RNSContainer.h"
#import "RNSContainerTransactionSupporting.h"
#include "RNSStackNavigationBarCoordinator.h"

@class RNSStackScreenController;
@protocol RNSStackPopGestureObserver;
@protocol RNSViewControllerViewLifecycleEventsObserver;
@protocol RNSViewFrameChangeDelegate;

@interface RNSStackNavigationController : UINavigationController <RNSContainer, RNSContainerTransactionSupporting>

@property (nonatomic, weak, nullable) id<RNSViewFrameChangeDelegate> navigationBarFrameChangeDelegate;

/**
 * Notified about the lifecycle events of this controller's view.
 */
@property (nonatomic, weak, nullable) id<RNSViewControllerViewLifecycleEventsObserver> viewLifecycleEventsObserver;

@property (nonatomic, readonly, nonnull) RNSStackNavigationBarCoordinator *navigationBarCoordinator;

/** Notified when the user starts swiping a screen back. */
@property (nonatomic, weak, nullable) id<RNSStackPopGestureObserver> popGestureObserver;

/** A stack that navigates a Split column shows a native placeholder while empty. Other stacks keep their root. */
@property (nonatomic) BOOL allowsEmptyStack;

#if !TARGET_OS_TV
- (nonnull UIBarButtonItem *)toolbarIconButtonForIdentifier:(nonnull NSString *)identifier;
#endif

- (void)enqueuePushOperation:(nonnull RNSStackScreenController *)screenController animated:(BOOL)animated;

- (void)enqueuePopOperation:(nonnull RNSStackScreenController *)screenController;

@end

@protocol RNSStackPopGestureObserver <NSObject>

/**
 * A recognized back swipe consumes the press under it, also when the pop is cancelled later.
 */
- (void)stackNavigationController:(nonnull RNSStackNavigationController *)controller
               didBeginPopGesture:(nonnull UIGestureRecognizer *)gestureRecognizer;

@end
