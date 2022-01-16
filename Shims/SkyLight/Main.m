@import QuartzCore;
@import Darwin.POSIX.dlfcn;
@import Darwin.POSIX.dirent;

#import "Utils.h"

BOOL earlyBoot;

#import "Extern.h"

#import "Blurs.m"
#import "Defenestrator.m"
#import "DisplayLink.m"
#import "Dock.m"
#import "DowngradedQuartzCore.m"
#import "Glyphs.m"
#import "Grey.m"
#import "Hidd.m"
#import "MenuBar.m"
#import "NightShift.m"
#import "Occlusion.m"
#import "Photos.m"
#import "Rim.m"
#import "SecureCursor.m"
#import "Scroll.m"
#import "Session.m"
#import "Sleep.m"
#import "Todo.m"
#import "TS2.m"
#import "WindowFlags.m"
#import "Zoom.m"

#import "Plugins.m"

@interface Setup:NSObject
@end

@implementation Setup

+(void)load
{
	earlyBoot=getpid()<200;
	
	if(earlyBoot&&[NSProcessInfo.processInfo.arguments[0] isEqualToString:@"/usr/sbin/kextcache"])
	{
		trace(@"Zoe <3");
	}
	
	traceLog=true;
	tracePrint=false;
	swizzleLog=false;
	
	blursSetup();
	defenestratorSetup();
	glyphsSetup();
	hiddSetup();
	occlusionSetup();
	safariSetup();
	ts2Setup();
	
	pluginsSetup();
	
#if MAJOR == 11
	photosSetup();
#endif
}

@end