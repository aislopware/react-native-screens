#import "RNSStackNavigationController.h"
#import "RNSAssert.h"
#import "RNSContainer.h"
#import "RNSLog.h"
#import "RNSParentContainerItemRegistry.h"
#import "RNSStackNavigationBar.h"
#import "RNSStackOperation.h"
#import "RNSStackScreenController.h"
#import "RNSViewControllerViewLifecycleEventsObserver.h"
#import "RNSViewFrameChangeDelegate.h"
#import "RNSDefines.h"
#import "RNSStackScreenHeaderCoordinator.h"

@interface RNSStackNavigationController ()
@property (nonatomic, readonly, getter=isStackEmpty) BOOL stackEmpty;
- (BOOL)shouldPreventNativePopToController:(UIViewController *)controller;
@end

#if !TARGET_OS_TV
@interface RNSStackPopGestureDelegate : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, weak) RNSStackNavigationController *navigationController;
@property (nonatomic, weak) id<UIGestureRecognizerDelegate> originalDelegate;
@end

@implementation RNSStackPopGestureDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  RNSStackNavigationController *navigation = self.navigationController;
  if (navigation.viewControllers.count < 2)
    return NO;
  UIViewController *destination = navigation.viewControllers[navigation.viewControllers.count - 2];
  if ([navigation shouldPreventNativePopToController:destination])
    return NO;
  if ([self.originalDelegate respondsToSelector:_cmd]) {
    return [self.originalDelegate gestureRecognizerShouldBegin:gestureRecognizer];
  }
  return YES;
}

- (BOOL)respondsToSelector:(SEL)selector
{
  return [super respondsToSelector:selector] || [self.originalDelegate respondsToSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
  return self.originalDelegate;
}
@end
#endif

@implementation RNSStackNavigationController {
  NSMutableArray<RNSPushOperation *> *_Nonnull _pendingPushOperations;
  NSMutableArray<RNSPopOperation *> *_Nonnull _pendingPopOperations;
  RNSParentContainerItemRegistry *_Nonnull _parentContainerRegistry;
  UIViewController *_emptyStackController;
  BOOL _performingReactUpdate;
#if !TARGET_OS_TV
  RNSStackPopGestureDelegate *_edgePopDelegate;
  NSMutableDictionary<NSString *, UIBarButtonItem *> *_toolbarIconButtons;
#if RNS_IPHONE_OS_VERSION_AVAILABLE(26_0)
  RNSStackPopGestureDelegate *_contentPopDelegate;
#endif
#endif
}

- (instancetype)init
{
#if !TARGET_OS_TV
  self = [super initWithNavigationBarClass:RNSStackNavigationBar.class toolbarClass:nil];
#else // !TARGET_OS_TV
  self = [super init];
#endif // !TARGET_OS_TV
  if (self != nil) {
    _navigationBarCoordinator = [RNSStackNavigationBarCoordinator new];
    [_navigationBarCoordinator initializeNavigationBarOfNavigationController:self];
    [self initState];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
#if !TARGET_OS_TV
  _edgePopDelegate = [RNSStackPopGestureDelegate new];
  _edgePopDelegate.navigationController = self;
  _edgePopDelegate.originalDelegate = self.interactivePopGestureRecognizer.delegate;
  self.interactivePopGestureRecognizer.delegate = _edgePopDelegate;
  [self.interactivePopGestureRecognizer addTarget:self action:@selector(popGestureDidChange:)];
#if RNS_IPHONE_OS_VERSION_AVAILABLE(26_0)
  if (@available(iOS 26.0, *)) {
    _contentPopDelegate = [RNSStackPopGestureDelegate new];
    _contentPopDelegate.navigationController = self;
    _contentPopDelegate.originalDelegate = self.interactiveContentPopGestureRecognizer.delegate;
    self.interactiveContentPopGestureRecognizer.delegate = _contentPopDelegate;
    [self.interactiveContentPopGestureRecognizer addTarget:self action:@selector(popGestureDidChange:)];
  }
#endif
#endif
}

#if !TARGET_OS_TV
- (void)popGestureDidChange:(UIGestureRecognizer *)gestureRecognizer
{
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    [_popGestureObserver stackNavigationController:self didBeginPopGesture:gestureRecognizer];
  }
}
#endif

// A parent column can be popped while its nested stack owns the guarded route.
- (RNSStackScreenController *)screenPreventingNativeDismissInController:(UIViewController *)controller
{
  if (![controller isKindOfClass:RNSStackScreenController.class]) {
    return nil;
  }
  auto screenController = static_cast<RNSStackScreenController *>(controller);
  if (screenController.configProvider.preventsNativeDismiss) {
    return screenController;
  }
  id<RNSContainer> nested = [screenController resolveNestedContainer];
  if ([nested isKindOfClass:UINavigationController.class]) {
    return [self screenPreventingNativeDismissInController:((UINavigationController *)nested).topViewController];
  }
  return nil;
}

- (BOOL)shouldPreventNativePopToController:(UIViewController *)controller
{
  if (_performingReactUpdate)
    return NO;
  NSUInteger destinationIndex = [self.viewControllers indexOfObject:controller];
  if (destinationIndex == NSNotFound)
    return NO;
  for (NSUInteger index = self.viewControllers.count; index > destinationIndex + 1; index--) {
    RNSStackScreenController *screenController =
        [self screenPreventingNativeDismissInController:self.viewControllers[index - 1]];
    if (screenController != nil) {
      [screenController.delegate stackScreenControllerDidPreventNativeDismiss:screenController];
      return YES;
    }
  }
  return NO;
}

- (void)prepareToolbarForController:(UIViewController *)controller
{
#if !TARGET_OS_TV
  if ([controller isKindOfClass:RNSStackScreenController.class]) {
    [static_cast<RNSStackScreenController *>(controller).headerCoordinator
        applyToolbarItemsInNavigationController:self];
  }
#endif
}

- (void)pushViewController:(UIViewController *)controller animated:(BOOL)animated
{
  [self prepareToolbarForController:controller];
  [super pushViewController:controller animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
  if (self.viewControllers.count > 1 &&
      [self shouldPreventNativePopToController:self.viewControllers[self.viewControllers.count - 2]])
    return nil;
  if (self.viewControllers.count > 1) {
    [self prepareToolbarForController:self.viewControllers[self.viewControllers.count - 2]];
  }
  return [super popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)controller animated:(BOOL)animated
{
  if ([self shouldPreventNativePopToController:controller])
    return nil;
  [self prepareToolbarForController:controller];
  return [super popToViewController:controller animated:animated];
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
  if ([self shouldPreventNativePopToController:self.viewControllers.firstObject])
    return nil;
  [self prepareToolbarForController:self.viewControllers.firstObject];
  return [super popToRootViewControllerAnimated:animated];
}

- (void)initState
{
  _pendingPushOperations = [NSMutableArray array];
  _pendingPopOperations = [NSMutableArray array];
  _parentContainerRegistry = [RNSParentContainerItemRegistry new];
}

#if !TARGET_OS_TV
- (UIBarButtonItem *)toolbarIconButtonForIdentifier:(NSString *)identifier
{
  if (_toolbarIconButtons == nil) {
    _toolbarIconButtons = [NSMutableDictionary new];
  }
  UIBarButtonItem *button = _toolbarIconButtons[identifier];
  if (button == nil) {
    button = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    _toolbarIconButtons[identifier] = button;
  }
  return button;
}
#endif

- (void)setAllowsEmptyStack:(BOOL)allowsEmptyStack
{
  _allowsEmptyStack = allowsEmptyStack;
  if (allowsEmptyStack) {
    if (_emptyStackController == nil) {
      _emptyStackController = [UIViewController new];
    }
    if (self.viewControllers.count == 0) {
      [self setViewControllers:@[ _emptyStackController ] animated:NO];
    }
  } else if (self.topViewController == _emptyStackController) {
    [self setViewControllers:@[] animated:NO];
  }
}

- (BOOL)isStackEmpty
{
  return self.viewControllers.count == 0 || self.topViewController == _emptyStackController;
}

#pragma mark-- Layout

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  [_navigationBarFrameChangeDelegate viewFrameDidChange:self.navigationBar];
  [_viewFrameChangeDelegate viewFrameDidChange:self.view];
}

#pragma mark - View lifecycle events

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [_viewLifecycleEventsObserver viewControllerViewWillAppear:self];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [_viewLifecycleEventsObserver viewControllerViewDidAppear:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [_viewLifecycleEventsObserver viewControllerViewWillDisappear:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [_viewLifecycleEventsObserver viewControllerViewDidDisappear:self];
}

#pragma mark - RNSContainer

- (nullable UIScrollView *)resolveCurrentContentScrollView
{
  // We assume `topViewController` corresponds to the currently presented screen.
  UIViewController *topController = self.topViewController;
  if (![topController isKindOfClass:RNSStackScreenController.class]) {
    return nil;
  }
  return [static_cast<RNSStackScreenController *>(topController) findContentScrollView];
}

- (void)attachToParentContainerItem
{
  [_parentContainerRegistry attachContainer:self];
}

- (void)detachFromParentContainerItem
{
  [_parentContainerRegistry detachContainer:self];
}

#pragma mark - View controller containment

- (void)didMoveToParentViewController:(UIViewController *)parent
{
  [super didMoveToParentViewController:parent];

  if (parent != nil) {
    [self attachToParentContainerItem];
  } else {
    [self detachFromParentContainerItem];
  }
}

- (BOOL)hasPendingOperations
{
  return _pendingPushOperations.count > 0 || _pendingPopOperations.count > 0;
}

- (void)enqueuePushOperation:(nonnull RNSStackScreenController *)screenController animated:(BOOL)animated
{
  RNSPushOperation *operation = [[RNSPushOperation alloc] initWithScreenController:screenController animated:animated];
  [_pendingPushOperations addObject:operation];
}

- (void)enqueuePopOperation:(nonnull RNSStackScreenController *)screenController
{
  RNSPopOperation *operation = [[RNSPopOperation alloc] initWithScreenController:screenController];
  [_pendingPopOperations addObject:operation];
}

#pragma mark - RNSContainerTransactionSupporting

- (void)beginTransaction
{
  // noop
}

- (void)commitTransaction
{
  // NOTE: We consider UINavigationController.viewControllers to be part of
  // the internal state of our stack implementation and expect it to be
  // *synchronously* updated by UIKit while we perform our pop and push operations
  //
  // The assertions below work under this assumption

  if (![self hasPendingOperations]) {
    return;
  }

  _performingReactUpdate = YES;
  if (_pendingPopOperations.count > 0 && _pendingPushOperations.count > 0) {
    // One React replacement must be one UIKit transition. Starting a push while
    // the final pop animates can leave the old screen visible with the new stack.
    NSMutableArray<UIViewController *> *controllers = [self.viewControllers mutableCopy];
    for (RNSPopOperation *op in _pendingPopOperations) {
      RNSAssert(self.allowsEmptyStack ? controllers.count > 0 : controllers.count > 1,
                @"[RNScreens] Attempt to pop last screen from the stack");
      RNSAssert(controllers.lastObject == op.screenController, @"[RNScreens] Attempt to pop non-top screen");
      [controllers removeLastObject];
    }
    if (controllers.count > 0 && controllers.lastObject == _emptyStackController) {
      [controllers removeLastObject];
    }
    for (RNSPushOperation *op in _pendingPushOperations) {
      [controllers addObject:op.screenController];
    }
    [self prepareToolbarForController:controllers.lastObject];
    [self setViewControllers:controllers animated:_pendingPushOperations.lastObject.animated];
  } else {
    for ([[maybe_unused]] RNSPopOperation *op in _pendingPopOperations) {
      RNSAssert(self.allowsEmptyStack ? !self.isStackEmpty : [self.viewControllers count] > 1,
                @"[RNScreens] Attempt to pop last screen from the stack");
      RNSAssert(self.topViewController == static_cast<UIViewController *>(op.screenController),
                @"[RNScreens] Attempt to pop non-top screen");
      if (self.allowsEmptyStack && self.viewControllers.count == 1) {
        // UIKit cannot show an empty nested navigation controller when the split is collapsed.
        [self setViewControllers:@[ _emptyStackController ] animated:NO];
      } else {
        // Intermediate pops must finish synchronously before starting the final transition.
        [self popViewControllerAnimated:op == _pendingPopOperations.lastObject];
      }
    }

    for (RNSPushOperation *op in _pendingPushOperations) {
      if (self.allowsEmptyStack && self.isStackEmpty) {
        // The first screen is the root, so the placeholder must not appear in its back stack.
        [self setViewControllers:@[ op.screenController ] animated:NO];
      } else {
        [self pushViewController:op.screenController
                        animated:op == _pendingPushOperations.lastObject && op.animated];
      }
    }
  }

  RNSAssert(self.allowsEmptyStack || [self.viewControllers count] > 0,
            @"[RNScreens] Stack should never be empty after updates");

  _performingReactUpdate = NO;
  [self dumpStackModel];

  [_pendingPopOperations removeAllObjects];
  [_pendingPushOperations removeAllObjects];
}

#pragma mark - Debug

- (void)dumpStackModel
{
#ifdef RNS_DEBUG_LOGGING
  RNSLogD(@"[RNScreens] StackContainer [%ld] MODEL BEGIN", self.view.tag);
  for (UIViewController *viewController in self.viewControllers) {
    if (viewController == _emptyStackController) {
      continue;
    }
    RNSLogD(@"[RNScreens] %@", static_cast<RNSStackScreenController *>(viewController).configProvider.screenKey);
  }
#endif // RNS_DEBUG_LOGGING
}

@end
