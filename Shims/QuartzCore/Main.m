// TODO: re-test all now that we're downgrading to Mojave
// TODO: refactor into several files like SL shims

#import "Utils.h"

@interface CAPresentationModifierGroup(Shim)
@end

@implementation CAPresentationModifierGroup(Shim)

-(void)flushWithTransaction
{
	[self flush];
}

@end

BOOL brightnessHack;

// animations
// exploit existing key/value storage on CATransaction

int transBoolCount=0;
NSString* transFakeKey(int key)
{
	return [NSString stringWithFormat:@"fake%d",key];
}

@interface CATransaction(Shim)
@end

@implementation CATransaction(Shim)

+(void)setBoolValue:(BOOL)value forKey:(int)key
{
	[self setValue:[NSNumber numberWithBool:value] forKey:transFakeKey(key)];
}

+(BOOL)boolValueForKey:(int)key
{
	// MinhTon's fix for brightness slider on MacBook5,1
	// TODO: a mystery
	
	if(brightnessHack)
	{
		return false;
	}
	
	BOOL result=((NSNumber*)[self valueForKey:transFakeKey(key)]).boolValue;
	
	return result;
}

+(int)registerBoolKey
{
	transBoolCount++;
	
	return transBoolCount;
}

@end

// weird crash

BOOL (*real_ACHFP)(CATransaction*,SEL,void*,int);
BOOL fake_ACHFP(CATransaction* self,SEL sel,void* rdx_block,int rcx_phase)
{
	// causes a hard crash in real function
	// silently return instead
	
	if(rcx_phase==5||rcx_phase==0xffffffff)
	{
		return true;
	}
	
	real_ACHFP(self,sel,rdx_block,rcx_phase);
	
	// always return success
	
	return true;
}

// WindowServer crash due to sidebar glyphs

@interface CAFilter:NSObject
-(NSString*)name;
@end

void (*real_SCF)(CALayer*,SEL,NSObject*);
void fake_SCF(CALayer* self,SEL sel,NSObject* filter)
{
	if(filter&&[filter isKindOfClass:CAFilter.class]&&[((CAFilter*)filter).name isEqualToString:@"vibrantColorMatrixSourceOver"])
	{
		// TODO: fixes glyphs in dark mode but not light, investigate further
		
		/*NSValue* matrix=[filter valueForKey:kCAFilterInputColorMatrix];
		
		CAFilter* newFilter=[CAFilter filterWithType:kCAFilterColorMatrix];
		[newFilter setValue:matrix forKey:kCAFilterInputColorMatrix];
		self.filters=@[newFilter];*/
		
		filter=nil;
	}
	
	real_SCF(self,sel,filter);
}

// SiriNCService not appearing

@interface CAFenceHandle(shim)<NSSecureCoding>
@end

@implementation CAFenceHandle(shim)

+(instancetype)newFenceFromDefaultServer
{
	return CAFenceHandle.alloc.init;
}

+(BOOL)supportsSecureCoding
{
	return true;
}

-(instancetype)initWithCoder:(NSCoder*)coder
{
	self=self.init;
	return self;
}

-(void)encodeWithCoder:(NSCoder*)coder
{
}

@end

// private, can't use a category to add missing symbols
// TODO: generate via Stubber, make public, or SOMETHING better than this...

void doNothing()
{
}

void fixCAContextImpl()
{
	Class CAContextImpl=NSClassFromString(@"CAContextImpl");
	class_addMethod(CAContextImpl,@selector(addFence:),(IMP)doNothing,"v@:@");
	class_addMethod(CAContextImpl,@selector(transferSlot:toContextWithId:),(IMP)doNothing,"v@:@@");
}

// TODO: check necessary

@interface CALayer(Shim)
@end

@implementation CALayer(Shim)

-(void)setUnsafeUnretainedDelegate:(id)rdx
{
	[self setDelegate:rdx];
}

-(id)unsafeUnretainedDelegate
{
	return [self delegate];
}

@end

__attribute__((constructor))
void load()
{
	swizzleLog=false;
	traceLog=true;
	
	swizzleImp(@"CATransaction",@"addCommitHandler:forPhase:",false,(IMP)fake_ACHFP,(IMP*)&real_ACHFP);
	swizzleImp(@"CALayer",@"setCompositingFilter:",true,(IMP)fake_SCF,(IMP*)&real_SCF);
	
	fixCAContextImpl();
	
	brightnessHack=[NSProcessInfo.processInfo.arguments[0] isEqualToString:@"/System/Library/CoreServices/ControlCenter.app/Contents/MacOS/ControlCenter"];
}