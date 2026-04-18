#import <Cocoa/Cocoa.h>

@interface Delegate : NSObject <NSApplicationDelegate>
@end

int main(int argc, const char * argv[]) {
	NSMenu *m = [NSMenu new];
	NSMenuItem *sub = [m addItemWithTitle:@"App" action:nil keyEquivalent:@""];
	[sub setSubmenu:[NSMenu new]];
	[sub.submenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
	NSApplication.sharedApplication.mainMenu = m;
	Delegate *delegate = [[Delegate alloc] init];
	NSApplication.sharedApplication.delegate = delegate;
	return NSApplicationMain(argc, argv);
}

@implementation Delegate
- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls {
	for (NSURL *url in urls) {
		NSTask *p = [NSTask new];
		p.launchPath = @"/usr/bin/qlmanage";
		p.arguments = @[@"-p", url.path];
		[p launch];
	}
	exit(EXIT_SUCCESS);
}
@end
