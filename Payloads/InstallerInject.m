// formerly Hax.dylib

#import "Utils.h"

BOOL patchPreBless(NSString* mount)
{
	trace(@"patching %@",mount);
	
	NSString* mainScript=[NSString stringWithContentsOfFile:@"/Volumes/Image Volume/InstallerPost.bash" encoding:NSUTF8StringEncoding error:nil];
	NSString* finalScript=[NSString stringWithFormat:@"cd '%@'; %@",mount,mainScript];
	NSArray<NSString*>* command=@[@"/bin/bash",@"-e",@"-c",finalScript];
	
	NSString* output;
	if(runTask(command,nil,&output))
	{
		trace(@"script error %@",output);
		return false;
	}
	
	return true;
}

@interface OSISTarget:NSObject
@property(retain) NSString* mountPoint;
@end

@interface OSISServer:NSObject
@property(retain) OSISTarget* preparedTarget;
@end


BOOL fake_doNotSealSystem(id self,SEL selector)
{
	return true;
}

BOOL fake__queue_isDeviceSupported(id self,SEL selector,id rdx)
{
	return true;
}

void (*real_setHasPreparedSuccessfully)(id,SEL,BOOL);
void fake_setHasPreparedSuccessfully(OSISServer* self,SEL selector,BOOL value)
{
	if(value)
	{
		NSString* mount=self.preparedTarget.mountPoint;
		value=patchPreBless(mount);
	}
	
	real_setHasPreparedSuccessfully(self,selector,value);
}

@interface Inject:NSObject
@end
@implementation Inject
+(void)load
{
	traceLog=true;
	
	NSString* processName=NSProcessInfo.processInfo.processName;
	
	if([processName containsString:@"osinstallersetupd"])
	{
		trace(@"loading hacks for osinstallersetupd");
		
		swizzleImp(@"OSISCustomizationController",@"doNotSealSystem",true,(IMP)fake_doNotSealSystem,NULL);
		swizzleImp(@"BIBuildInformation",@"_queue_isDeviceSupported:",true,(IMP)fake__queue_isDeviceSupported,NULL);
		
		swizzleImp(@"OSISServer",@"setHasPreparedSuccessfully:",true,(IMP)fake_setHasPreparedSuccessfully,(IMP*)&real_setHasPreparedSuccessfully);
	}
}
@end