#import "FlglPlugin.h"
#if __has_include(<flgl/flgl-Swift.h>)
#import <flgl/flgl-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flgl-Swift.h"
#endif

@implementation FlglPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlglPlugin registerWithRegistrar:registrar];
}
@end
