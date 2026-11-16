#import "RNSHeaderMenuUpdateOptions.h"

#pragma mark - RNSMenuItemUpdateOptions

@implementation RNSMenuItemUpdateOptions

- (instancetype)initWithTitle:(nullable NSString *)title
                     hasTitle:(BOOL)hasTitle
                         icon:(nullable RNSHeaderIconData *)icon
                      hasIcon:(BOOL)hasIcon
               hasToggleState:(BOOL)hasToggleState
                  toggleState:(BOOL)toggleState
                     hasState:(BOOL)hasState
                        state:(UIMenuElementState)state
{
  if (self = [super init]) {
    _title = [title copy];
    _hasTitle = hasTitle;
    _icon = icon;
    _hasIcon = hasIcon;
    _hasToggleState = hasToggleState;
    _toggleState = toggleState;
    _hasState = hasState;
    _state = state;
  }
  return self;
}

+ (RNSHeaderMenuItemData *)applyOptions:(RNSMenuItemUpdateOptions *)options
                                  toMenuItem:(RNSHeaderMenuItemData *)old
{
  NSString *title = options.hasTitle ? options.title : old.title;
  RNSHeaderIconData *icon = options.hasIcon ? options.icon : old.icon;

  return [[RNSHeaderMenuItemData alloc] initWithId:old.menuElementId
                                                  title:title
                                               subtitle:old.subtitle
                                               disabled:old.disabled
                                            destructive:old.destructive
                                               itemType:old.itemType
                                                  state:options.hasState ? options.state : old.state
                                     initialToggleState:old.initialToggleState
                                     keepsMenuPresented:old.keepsMenuPresented
                                                   icon:icon];
}

@end

#pragma mark - RNSMenuUpdateOptions

@implementation RNSMenuUpdateOptions

- (instancetype)initWithTitle:(nullable NSString *)title
                     hasTitle:(BOOL)hasTitle
                         icon:(nullable RNSHeaderIconData *)icon
                      hasIcon:(BOOL)hasIcon
{
  if (self = [super init]) {
    _title = [title copy];
    _hasTitle = hasTitle;
    _icon = icon;
    _hasIcon = hasIcon;
  }
  return self;
}

+ (RNSHeaderMenuData *)applyOptions:(RNSMenuUpdateOptions *)options toMenu:(RNSHeaderMenuData *)old
{
  NSString *title = options.hasTitle ? options.title : old.title;
  RNSHeaderIconData *icon = options.hasIcon ? options.icon : old.icon;

  return [[RNSHeaderMenuData alloc] initWithId:old.menuElementId
                                         title:title
                               singleSelection:old.singleSelection
                                 displayInline:old.displayInline
                              displayAsPalette:old.displayAsPalette
                                      children:old.children
                                          icon:icon];
}

@end
