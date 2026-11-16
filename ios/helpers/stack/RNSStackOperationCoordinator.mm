#import "RNSStackOperationCoordinator.h"
#import "RNSStackNavigationController.h"
#import "RNSStackScreenProviding.h"

@implementation RNSStackOperationCoordinator {
  NSMutableArray<UIView<RNSStackScreenProviding> *> *_Nonnull _pendingPushScreens;
  NSMutableArray<UIView<RNSStackScreenProviding> *> *_Nonnull _pendingPopScreens;
}

- (instancetype)init
{
  if (self = [super init]) {
    [self initState];
  }
  return self;
}

- (void)initState
{
  _pendingPushScreens = [NSMutableArray array];
  _pendingPopScreens = [NSMutableArray array];
}

- (BOOL)hasPendingOperations
{
  return _pendingPushScreens.count > 0 || _pendingPopScreens.count > 0;
}

- (void)addPushOperation:(nonnull UIView<RNSStackScreenProviding> *)stackScreen
{
  [_pendingPushScreens addObject:stackScreen];
}

- (void)addPopOperation:(nonnull UIView<RNSStackScreenProviding> *)stackScreen
{
  [_pendingPopScreens addObject:stackScreen];
}

- (void)enqueuePendingOperationsIfNeeded:(nonnull RNSStackNavigationController *)controller
                     withRenderedScreens:(nonnull NSArray<UIView<RNSStackScreenProviding> *> *)renderedScreens
{
  if (![self hasPendingOperations]) {
    return;
  }

  // Unmounted screens are no longer in renderedScreens. Their pop order still follows the native stack.
  auto orderedPops =
      [_pendingPopScreens sortedArrayUsingComparator:^NSComparisonResult(
                              UIView<RNSStackScreenProviding> *screen1, UIView<RNSStackScreenProviding> *screen2) {
        return [@([controller.viewControllers indexOfObject:screen1.controller])
            compare:@([controller.viewControllers indexOfObject:screen2.controller])];
      }];
  auto popScreens = [[orderedPops reverseObjectEnumerator] allObjects];

  for (UIView<RNSStackScreenProviding> *screen in popScreens) {
    [controller enqueuePopOperation:screen.controller];
  }

  auto pushScreens = [self orderedScreens:_pendingPushScreens withIndicesFrom:renderedScreens];

  for (UIView<RNSStackScreenProviding> *screen in pushScreens) {
    [controller enqueuePushOperation:screen.controller];
  }

  [_pendingPopScreens removeAllObjects];
  [_pendingPushScreens removeAllObjects];
}

- (NSArray<UIView<RNSStackScreenProviding> *> *)
     orderedScreens:(nonnull NSArray<UIView<RNSStackScreenProviding> *> *)screens
    withIndicesFrom:(nonnull NSArray<UIView<RNSStackScreenProviding> *> *)renderedScreens
{
  return [screens sortedArrayUsingComparator:^NSComparisonResult(
                      UIView<RNSStackScreenProviding> *screen1, UIView<RNSStackScreenProviding> *screen2) {
    return [@([renderedScreens indexOfObject:screen1]) compare:@([renderedScreens indexOfObject:screen2])];
  }];
}

@end
