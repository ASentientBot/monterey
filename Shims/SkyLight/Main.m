@import QuartzCore;

#import "Utils.h"

#import "Extern.h"

#import "Blurs.m"
#import "Defenestrator.m"
#import "DisplayLink.m"
#import "Dock.m"
#import "Glyphs.m"
#import "MenuBar.m"
#import "Occlusion.m"
#import "Scroll.m"
#import "Session.m"
#import "Sleep.m"
#import "Todo.m"
#import "TS2.m"
#import "WindowFlags.m"

@interface Setup:NSObject
@end

@implementation Setup

+(void)load
{
	if(getpid()<100&&[NSProcessInfo.processInfo.arguments[0] isEqualToString:@"/usr/sbin/kextcache"])
	{
		trace(@"Zoe <3");
	}
	
	traceLog=true;
	tracePrint=false;
	swizzleLog=false;
	
	blursSetup();
	defenestratorSetup();
	glyphsSetup();
	occlusionSetup();
	ts2Setup();
}

@end