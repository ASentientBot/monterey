#import "Utils.h"
@import QuartzCore;

// from old SL shim - Blurs.m
// with downgraded QuartzCore, no longer needed for grey blurs
// but EduCovas noticed this greatly reduces flickering

void (*real_setScale)(id,SEL,double);

void fake_setScale(id self,SEL selector,double value)
{
	value=MAX(value,1);
	
	real_setScale(self,selector,value);
}

void blursSetup()
{
	swizzleImp(@"CABackdropLayer",@"setScale:",true,(IMP)fake_setScale,(IMP*)&real_setScale);
}

// from old SL shim - DowngradedQuartzCore.m

@interface CAPresentationModifierGroup:NSObject
-(void)flush;
@end

@interface CAPresentationModifierGroup(Shim)
@end

@implementation CAPresentationModifierGroup(Shim)

-(void)setUpdatesAsynchronously:(BOOL)flag
{
}

-(void)flushWithTransaction
{
	self.flush;
}

@end

// from EduCovas, modified

@interface CABackdropLayer:NSObject
@end

@interface CABackdropLayer(Shim)
@end

@implementation CABackdropLayer(Shim)

-(void)setAllowsSubstituteColor:(BOOL)flag
{
}

-(void)setGroupNamespace:(id)rdx
{
}

@end

int transBoolCount=0;
NSString* transFakeKey(int key)
{
	return [NSString stringWithFormat:@"fake%d",key];
}

@interface CATransaction(Shim)
@end

@implementation CATransaction(Shim)

+(void)startFrameWithReason:(id)rdx beginTime:(id)rcx commitDeadline:(id)r8
{
}

+(void)finishFrameWithToken:(id)rdx
{
}

+(void)setFrameStallSkipRequest:(id)rdx
{
}

+(void)setFrameInputTime:(id)rdx withToken:(id)rcx
{
}

// fix animations - ASB

+(void)setBoolValue:(BOOL)value forKey:(int)key
{
	// trace(@"CATransaction setBoolValue: %d forKey: %d",value,key);
	
	[self setValue:[NSNumber numberWithBool:value] forKey:transFakeKey(key)];
}

+(BOOL)boolValueForKey:(int)key
{
	BOOL result=((NSNumber*)[self valueForKey:transFakeKey(key)]).boolValue;
	
	// trace(@"CATransaction boolValueForKey: %ld - %d",key,result);
	
	return result;
}

+(int)registerBoolKey
{
	// trace(@"CATransaction registerBoolKey");
	
	transBoolCount++;
	
	return transBoolCount;
}

@end

// prevent Catalyst crash - ASB

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

// prevent WindowServer crash due to Finder glyphs - ASB

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

@interface CAFenceHandle:QuartzCoreStubClass<NSSecureCoding>
@end

@implementation CAFenceHandle

+(instancetype)newFenceFromDefaultServer
{
	// trace(@"CAFenceHandle newFenceFromDefaultServer");
	
	return CAFenceHandle.alloc.init;
}

+(BOOL)supportsSecureCoding
{
	// trace(@"CAFenceHandle supportsSecureCoding");
	return true;
}

-(instancetype)initWithCoder:(NSCoder*)coder
{
	// trace(@"CAFenceHandle initWithCoder:");
	self=self.init;
	return self;
}

-(void)encodeWithCoder:(NSCoder*)coder
{
	// trace(@"CAFenceHandle encodeWithCoder");
}

@end

// private, can't use a category

void doNothing()
{
}

void fixCAContextImpl()
{
	// TODO: make a utility function like swizzleImp
	
	Class CAContextImpl=NSClassFromString(@"CAContextImpl");
	class_addMethod(CAContextImpl,@selector(addFence:),(IMP)doNothing,"v@:@");
	class_addMethod(CAContextImpl,@selector(transferSlot:toContextWithId:),(IMP)doNothing,"v@:@@");
}

@interface Load:NSObject
@end

@implementation Load

+(void)load
{
	swizzleLog=false;
	traceLog=true;
	
	swizzleImp(@"CATransaction",@"addCommitHandler:forPhase:",false,(IMP)fake_ACHFP,(IMP*)&real_ACHFP);
	swizzleImp(@"CALayer",@"setCompositingFilter:",true,(IMP)fake_SCF,(IMP*)&real_SCF);
	
	fixCAContextImpl();
	blursSetup();
}

@end