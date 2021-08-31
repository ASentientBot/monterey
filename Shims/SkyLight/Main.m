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
#import "WindowFlags.m"

@interface Setup:NSObject
@end

@implementation Setup

+(void)load
{
	if(getpid()<100&&[NSProcessInfo.processInfo.processName containsString:@"kextcache"])
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
}

@end