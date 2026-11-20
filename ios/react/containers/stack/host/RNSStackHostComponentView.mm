#import "RNSStackHostComponentView.h"

#import <React/RCTConversions.h>
#import <React/RCTMountingTransactionObserving.h>
#import <React/UIView+React.h>
#import <react/renderer/components/rnscreens/EventEmitters.h>
#import <react/renderer/components/rnscreens/Props.h>
#import <react/renderer/components/rnscreens/RCTComponentViewHelpers.h>
#import <react/renderer/components/rnscreens/RNSStackHostComponentDescriptor.h>
#import "RNSDefines.h"
#import "RNSLog.h"
#import <React/RCTSurfaceTouchHandler.h>

#import "RCTSurfaceTouchHandler+RNSUtility.h"
#import "RNSContainerHelpers.h"
#import "RNSStackHeaderConfigComponentView.h"
#import "RNSStackNavigationController.h"
#import "RNSStackOperationCoordinator.h"
#import "RNSStackScreenComponentView.h"

namespace react = facebook::react;

@interface RNSStackHostComponentView () <RCTMountingTransactionObserving, RNSStackPopGestureObserver>
@end

@implementation RNSStackHostComponentView {
  RNSStackOperationCoordinator *_Nonnull _stackOperationCoordinator;
  NSMutableArray<RNSStackScreenComponentView *> *_Nonnull _renderedScreens;
  BOOL _didSetHeadlessModeEnabled;
  BOOL _isWaitingForTransition;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self initState];
  }
  return self;
}

- (void)initState
{
  static const auto defaultProps = std::make_shared<const react::RNSStackHostProps>();
  _props = defaultProps;

  _stackNavigationController = [RNSStackNavigationController new];
  _stackNavigationController.popGestureObserver = self;
  _stackOperationCoordinator = [RNSStackOperationCoordinator new];
  _renderedScreens = [NSMutableArray new];
}

#pragma mark - UIKit Callbacks

- (void)didMoveToWindow
{
  RNSLogD(@"[RNScreens] StackHost [%ld] attached to window", self.tag);
  // In headless mode the host does not show the stack itself.
  if (_headlessModeEnabled) {
    if (self.window != nil) {
      RNSLogE(
          @"[RNScreens] Stack.Host is rendered in a Split.Column or a Split.Inspector, but it is not its direct and "
          @"only child, so the stack is not shown. Set disableStackIntegration on the column or the inspector to "
          @"nest the stack as plain content.");
    }
    return;
  }
  if (self.window != nil && _stackNavigationController.parentViewController == nil) {
    BOOL mountResult = [RNSContainerHelpers addChildViewController:_stackNavigationController
                                          toViewControllerManaging:self.reactSuperview
                                                 withContainerView:self];
    if (mountResult) {
      [self setupViewConstraintsForController:_stackNavigationController];
    }
  }
}

// By default, the header buttons that are not inside the native hit area
// cannot be clicked, so we check it by ourselves
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  if (CGRectContainsPoint(_stackNavigationController.navigationBar.frame, point)) {
    RNSStackHeaderConfigComponentView *headerConfig = [self requireTopScreenHeaderConfig];
    CGPoint convertedPoint = [self convertPoint:point toView:headerConfig];
    UIView *headerHitTestResult = [headerConfig hitTest:convertedPoint withEvent:event];
    if (headerHitTestResult != nil) {
      return headerHitTestResult;
    }
  }
  return [super hitTest:point withEvent:event];
}

#pragma mark - Communication with StackScreen

- (void)stackScreenChangedActivityMode:(nonnull RNSStackScreenComponentView *)stackScreen
{
  RCTAssert(stackScreen != nil, @"[RNScreens] Expected non nill stackScreen");
  switch (stackScreen.activityMode) {
    case RNSStackScreenActivityModeAttached:
      [_stackOperationCoordinator addPushOperation:stackScreen];
      break;
    case RNSStackScreenActivityModeDetached:
      // The React update acknowledging a completed native pop must not pop again.
      if (!stackScreen.isNativelyDismissed) {
        [_stackOperationCoordinator addPopOperation:stackScreen];
      }
      break;
    default:
      RCTAssert(NO, @"[RNScreens] Unexpected value of activityMode: %d", stackScreen.activityMode);
      return;
  }
}

#pragma mark - RCTComponentViewProtocol

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  RCTAssert([childComponentView isKindOfClass:RNSStackScreenComponentView.class],
            @"[RNScreens] Attempt to mount child of unsupported type: %@, expected %@",
            childComponentView.class,
            RNSStackScreenComponentView.class);

  auto *childScreen = static_cast<RNSStackScreenComponentView *>(childComponentView);
  childScreen.stackHost = self;
  [_renderedScreens insertObject:childScreen atIndex:index];
  [self addPushOperationIfNeeded:childScreen];
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  RCTAssert([childComponentView isKindOfClass:RNSStackScreenComponentView.class],
            @"[RNScreens] Attempt to unmount child of unsupported type: %@, expected %@",
            childComponentView.class,
            RNSStackScreenComponentView.class);

  auto *childScreen = static_cast<RNSStackScreenComponentView *>(childComponentView);
  [_renderedScreens removeObject:childScreen];
  childScreen.stackHost = nil;
  [self addPopOperationIfNeeded:childScreen];
}

- (void)addPopOperationIfNeeded:(nonnull RNSStackScreenComponentView *)stackScreen
{
  if (stackScreen.activityMode == RNSStackScreenActivityModeAttached && !stackScreen.isNativelyDismissed) {
    // This shouldn't happen in typical scenarios but it can happen with fast-refresh.
    [_stackOperationCoordinator addPopOperation:stackScreen];
  } else {
    RNSLogD(@"[RNScreens] ignoring pop operation of %@, already not attached or natively dismissed",
            stackScreen.screenKey);
  }
}

- (void)updateProps:(const facebook::react::Props::Shared &)props
           oldProps:(const facebook::react::Props::Shared &)oldProps
{
  const auto &oldComponentProps = *std::static_pointer_cast<const react::RNSStackHostProps>(_props);
  const auto &newComponentProps = *std::static_pointer_cast<const react::RNSStackHostProps>(props);

  if (oldComponentProps.headlessModeEnabled != newComponentProps.headlessModeEnabled) {
    if (_didSetHeadlessModeEnabled) {
      RNSLogW(@"[RNScreens] Changing the headless mode of Stack.Host at runtime is not supported");
    } else {
      _headlessModeEnabled = newComponentProps.headlessModeEnabled;
      // A Split column stays installed while none of its screens is attached.
      _stackNavigationController.allowsEmptyStack = _headlessModeEnabled;
    }
  }
  _didSetHeadlessModeEnabled = YES;

  [super updateProps:props oldProps:oldProps];
}

+ (react::ComponentDescriptorProvider)componentDescriptorProvider
{
  return react::concreteComponentDescriptorProvider<react::RNSStackHostComponentDescriptor>();
}

+ (BOOL)shouldBeRecycled
{
  // There won't be tens of instances of this component usually & it's easier for now.
  // We could consider enabling it someday though.
  return NO;
}

#pragma mark - Utils

- (void)addPushOperationIfNeeded:(nonnull RNSStackScreenComponentView *)stackScreen
{
  if (stackScreen.activityMode == RNSStackScreenActivityModeAttached) {
    [_stackOperationCoordinator addPushOperation:stackScreen];
  }
}

- (void)setupViewConstraintsForController:(nonnull UIViewController *)controller
{
  // Enable auto-layout to ensure valid size of stack controller view.
  controller.view.translatesAutoresizingMaskIntoConstraints = NO;
  [NSLayoutConstraint activateConstraints:@[
    [controller.view.topAnchor constraintEqualToAnchor:self.topAnchor],
    [controller.view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    [controller.view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
    [controller.view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
  ]];
}

- (RNSStackHeaderConfigComponentView *)requireTopScreenHeaderConfig
{
  RCTAssert([_stackNavigationController.topViewController.view isKindOfClass:[RNSStackScreenComponentView class]],
            @"[RNScreens] Expected top screen to be a react component view of type RNSStackScreenComponentView");
  auto screenView = (RNSStackScreenComponentView *)_stackNavigationController.topViewController.view;

  return screenView.headerConfig;
}

#pragma mark - RNSStackPopGestureObserver

- (void)stackNavigationController:(RNSStackNavigationController *)controller
               didBeginPopGesture:(UIGestureRecognizer *)gestureRecognizer
{
  // The nearest touch handler is the one of the root view, of a sheet or of a Split column.
  for (UIView *view = gestureRecognizer.view; view != nil; view = view.superview) {
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
      if ([recognizer isKindOfClass:RCTSurfaceTouchHandler.class]) {
        [static_cast<RCTSurfaceTouchHandler *>(recognizer) rnscreens_cancelTouches];
        return;
      }
    }
  }
}

#pragma mark - RCTMountingTransactionObserving

- (void)mountingTransactionWillMount:(const facebook::react::MountingTransaction &)transaction
                withSurfaceTelemetry:(const facebook::react::SurfaceTelemetry &)surfaceTelemetry
{
  [_stackNavigationController beginTransaction];
}

- (void)mountingTransactionDidMount:(const facebook::react::MountingTransaction &)transaction
               withSurfaceTelemetry:(const facebook::react::SurfaceTelemetry &)surfaceTelemetry
{
  // The screens are translated to operations now: an unmounted screen gives its controller up before a deferred
  // commit runs.
  [_stackOperationCoordinator enqueuePendingOperationsIfNeeded:_stackNavigationController
                                           withRenderedScreens:_renderedScreens];
  [self commitTransactionWhenSplitIsIdle];
}

- (void)commitTransactionWhenSplitIsIdle
{
  if (_isWaitingForTransition) {
    return;
  }

  // A Split that was just asked to show a column has its transition pending, before the navigation controllers of
  // its columns take part in it.
  id<UIViewControllerTransitionCoordinator> coordinator = _stackNavigationController.transitionCoordinator
      ?: _stackNavigationController.splitViewController.transitionCoordinator;
  if (_headlessModeEnabled && coordinator != nil) {
    // UIKit can ignore pops while the Split is showing or hiding the column, and the column change when a pop
    // lands first.
    _isWaitingForTransition = YES;
    __weak RNSStackHostComponentView *weakSelf = self;
    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                     RNSStackHostComponentView *strongSelf = weakSelf;
                                     if (strongSelf != nil) {
                                       strongSelf->_isWaitingForTransition = NO;
                                       [strongSelf commitTransactionWhenSplitIsIdle];
                                     }
                                   });
                                 }];
    return;
  }

  [_stackNavigationController commitTransaction];
}

#pragma mark - Dynamic frameworks support

// Needed because of this: https://github.com/facebook/react-native/pull/37274
#ifdef RCT_DYNAMIC_FRAMEWORKS
+ (void)load
{
  [super load];
}
#endif // RCT_DYNAMIC_FRAMEWORKS

@end

Class<RCTComponentViewProtocol> RNSStackHostCls(void)
{
  return RNSStackHostComponentView.class;
}
