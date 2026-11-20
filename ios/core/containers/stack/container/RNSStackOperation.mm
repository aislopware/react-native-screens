#import "RNSStackOperation.h"
#import "RNSAssert.h"

@implementation RNSStackOperation

- (instancetype)initWithScreenController:(nonnull RNSStackScreenController *)screenController
{
  RNSAssert(screenController != nil, @"[RNScreens] Expected nonnull screenController!");
  if (self = [super init]) {
    _screenController = screenController;
  }
  return self;
}

@end

@implementation RNSPushOperation

- (instancetype)initWithScreenController:(nonnull RNSStackScreenController *)screenController animated:(BOOL)animated
{
  if (self = [super initWithScreenController:screenController]) {
    _animated = animated;
  }
  return self;
}

@end

@implementation RNSPopOperation
@end
