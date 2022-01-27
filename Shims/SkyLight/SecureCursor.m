// Safari extension checkboxes

@interface SLSecureCursorAssertion:SkyLightStubClass
@end

@implementation SLSecureCursorAssertion

+(instancetype)assertion
{
	trace(@"SLSecureCursorAssertion assertion returning new instance");
	return SLSecureCursorAssertion.alloc.init.autorelease;
}

-(BOOL)isValid
{
	trace(@"SLSecureCursorAssertion isValid returning true");
	return true;
}

@end

// TODO: temporary hack until i sort out NSOcclusionDetectionView

BOOL fake_canEnableExtensions()
{
	trace(@"fake_canEnableExtensions");
	
	return true;
}

void safariSetup()
{
	if([process containsString:@"Safari"])
	{
		swizzleImp(@"ExtensionsPreferences",@"canEnableExtensions",true,(IMP)fake_canEnableExtensions,NULL);
	}
}