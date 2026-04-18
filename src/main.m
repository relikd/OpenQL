#import <Cocoa/Cocoa.h>

@interface Delegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
@property BOOL separate;
@end

int main(int argc, const char * argv[]) {
	Delegate *delegate = [[Delegate alloc] init];
	NSApplication.sharedApplication.delegate = delegate;
	return NSApplicationMain(argc, argv);
}

@implementation Delegate
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
	self.separate = [NSUserDefaults.standardUserDefaults boolForKey:@"separate"];
}
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	NSMenu *m = [NSMenu new];
	m.delegate = self;
	[m addItemWithTitle:@"Multiple previews open in separate windows" action:@selector(togglePref) keyEquivalent:@""].tag = 302;
	[m addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
	
	NSMenu *mainMenu = [NSMenu new];
	NSMenuItem *sub = [mainMenu addItemWithTitle:@"App" action:nil keyEquivalent:@""];
	[sub setSubmenu:m];
	NSApplication.sharedApplication.mainMenu = mainMenu;
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
	NSMenuItem *mi = [menu itemWithTag:302];
	if (!mi) { return; }
	mi.state = self.separate ? NSControlStateValueOn : NSControlStateValueOff;
}

- (void)togglePref {
	self.separate = !self.separate;
	[NSUserDefaults.standardUserDefaults setBool:self.separate forKey:@"separate"];
}

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls {
	NSMutableArray<NSString*> *paths = [NSMutableArray arrayWithCapacity:urls.count];
	for (NSURL *url in urls) {
		if (self.separate) {
			[self preview:@[url.path]];
		} else {
			[paths addObject:url.path];
		}
	}
	if (!self.separate) {
		[self preview:paths];
	}
	sleep(1); // otherwise, app quits, focus returns to Finder, and only then preview opens (behind Finder window)
	exit(EXIT_SUCCESS);
}

- (void)preview:(NSArray<NSString*>*)files {
	//system([NSString stringWithFormat:@"qlmanage -p %@", [files componentsJoinedByString:@" "]].cString);
	NSTask *p = [NSTask new];
	p.executableURL = [NSURL fileURLWithPath:@"/usr/bin/qlmanage"];
	p.arguments = [@[@"-p"] arrayByAddingObjectsFromArray:files];
	[p launchAndReturnError:nil];
}
@end
