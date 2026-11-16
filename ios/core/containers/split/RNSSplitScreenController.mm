#import "RNSSplitScreenController.h"

#import "RNSAssert.h"
#import "RNSContainerItemSupport.h"
#import "RNSHeaderCoordinator.h"
#import "RNSSplitHostController.h"

@implementation RNSSplitScreenController {
  UIView<RNSStackScreenProviding> *_screenView;
  RNSContainerItemSupport *_containerItemSupport;
}

- (instancetype)initWithScreenView:(UIView<RNSStackScreenProviding> *)screenView
{
  if (self = [super init]) {
    _screenView = screenView;
    _containerItemSupport = [RNSContainerItemSupport new];
    _headerCoordinator = [[RNSHeaderCoordinator alloc] initWithScreenController:self];
#if !TARGET_OS_TV
    // Navigation bar prefers large titles, so opt out unless a header config or navigation item customizer sets a mode.
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
#endif // !TARGET_OS_TV
  }

  return self;
}

// Register nested stacks so column navigation can consult their removal guards.
- (void)registerNestedContainer:(id<RNSContainer>)container
{
  [_containerItemSupport registerNestedContainer:container];
}

- (void)unregisterNestedContainer:(id<RNSContainer>)container
{
  [_containerItemSupport unregisterNestedContainer:container];
}

- (nullable id<RNSContainer>)resolveNestedContainer
{
  return [_containerItemSupport resolveNestedContainer];
}

- (nullable UIScrollView *)findContentScrollView
{
  return [_containerItemSupport findContentScrollViewWithCachedScrollView:nil
                                                            heuristicRoot:_screenView];
}

/**
 * @brief Returns the SplitHost controller the column is installed in.
 *
 * @return `splitViewController` if it is a RNSSplitHostController, otherwise nil (e.g. for the inspector presented as
 * a modal, outside the split hierarchy).
 */
- (nullable RNSSplitHostController *)findSplitHostController
{
  if ([self.splitViewController isKindOfClass:RNSSplitHostController.class]) {
    return (RNSSplitHostController *)self.splitViewController;
  }

  return nil;
}

- (BOOL)isInSplitHostSubtree
{
  return [self.splitViewController isKindOfClass:RNSSplitHostController.class];
}

#pragma mark - Signals

#pragma mark - Layout

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  // For modals, which are presented outside the SplitHost subtree (and RN hierarchy),
  // we're attaching our touch handler and we don't need to apply any offset corrections,
  // because it's positioned relatively to the column view
  if (![self isInSplitHostSubtree]) {
    // A screen leaving its column has no navigation controller anymore; its frame is meaningless then.
    if (self.navigationController == nil) {
      return;
    }
    [_delegate splitScreenController:self didChangeColumnFrame:self.view.frame];
    return;
  }

  UIView *ancestorView = [self findSplitHostController].view;
  RNSAssert(ancestorView != nil, @"[RNScreens] Expected to find RNSSplitHost component for RNSSplitScreen component");

  [self reportColumnFrameInContextOfView:ancestorView];
}

- (void)columnPositioningDidChangeInSplitViewController:(UISplitViewController *)splitViewController
{
  [self reportColumnFrameInContextOfView:splitViewController.view];
}

- (void)reportColumnFrameInContextOfView:(UIView *)ancestorView
{
  // The column frame is the navigation controller's view frame, not the screen's: UIKit animates the screen view
  // during push and pop transitions, the column stays put.
  UIView *columnView = self.navigationController.view ?: self.view;
  CGRect frame = [columnView convertRect:columnView.bounds toView:ancestorView];
  [_delegate splitScreenController:self didChangeColumnFrame:frame];
}

#pragma mark - Events

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  // Without a header config the column keeps the system navigation bar, so the coordinator is not consulted.
  if (_screenView.headerConfig != nil) {
    [_headerCoordinator updateNavigationBarVisibilityAnimated:animated];
#if !TARGET_OS_TV
    [_headerCoordinator updateBackButtonMenuEnabled];
#endif // !TARGET_OS_TV
  }
  [_delegate splitScreenControllerWillAppear:self];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  if (_screenView.headerConfig != nil) {
    [_headerCoordinator restoreDetachedTitleView];
  }
  [_delegate splitScreenControllerDidAppear:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [_delegate splitScreenControllerWillDisappear:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [_delegate splitScreenControllerDidDisappear:self];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
  [super didMoveToParentViewController:parent];

  if (parent != nil) {
    return;
  }

#if !TARGET_OS_TV
  [_headerCoordinator clearAppliedBackButtonConfig];
#endif // !TARGET_OS_TV

  // A screen React still expects on the stack left it natively (e.g. the back button); a detached one was popped on
  // React's request.
  BOOL isNativeDismiss = _screenView.activityMode == RNSStackScreenActivityModeAttached;
  [_delegate splitScreenController:self didDismissNatively:isNativeDismiss];
}

@end
