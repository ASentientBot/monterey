// transparent grey blurs

void (*real_setScale)(id,SEL,double);

void fake_setScale(id self,SEL selector,double value)
{
	value=MAX(value,0.25);
	
	real_setScale(self,selector,value);
}

// dropdowns and sidebars

BOOL blurBetaValue;
dispatch_once_t blurBetaOnce;
BOOL blurBeta()
{
	dispatch_once(&blurBetaOnce,^()
	{
		blurBetaValue=[NSUserDefaults.standardUserDefaults boolForKey:@"ASB_BlurBeta"];
		
		// TODO: this
		
		if(blurBetaValue&&[@[@"/System/Library/CoreServices/screencaptureui.app/Contents/MacOS/screencaptureui",@"/System/Library/CoreServices/ControlCenter.app/Contents/MacOS/ControlCenter",@"/System/Library/CoreServices/NotificationCenter.app/Contents/MacOS/NotificationCenter"] containsObject:NSProcessInfo.processInfo.arguments[0]])
		{
			trace(@"blacklisted from blur fixes");
			
			blurBetaValue=false;
		}
		
		trace(@"ASB_BlurBeta %d",blurBetaValue);
	});
	
	return blurBetaValue;
}

double blurOverrideValue;
dispatch_once_t blurOverrideOnce;
double blurOverride()
{
	dispatch_once(&blurOverrideOnce,^()
	{
		blurOverrideValue=[NSUserDefaults.standardUserDefaults doubleForKey:@"ASB_BlurOverride"];
		
		trace(@"ASB_BlurOverride %lf",blurOverrideValue);
	});
	
	return blurOverrideValue;
}

// TODO: another dumb not-linking-AppKit workaround

@interface CAFilterLite:NSObject

@property(assign) NSString* name;

@end

void (*real_setFilters)(id,SEL,NSArray*);

void fake_setFilters(id self,SEL selector,NSArray* filters)
{
	if(!blurBeta())
	{
		real_setFilters(self,selector,filters);
		return;
	}
	
	NSMutableArray* newFilters=NSMutableArray.alloc.init;
	
	for(CAFilterLite* filter in filters)
	{
		NSString* name=[filter name];
		
		// trace(@"%@ %@ %@",filter,[filter inputKeys],[filter outputKeys]);
		
		if([name isEqualToString:@"sdrNormalize"]||[name isEqualToString:@"colorSaturate"])
		{
			continue;
		}
		
		// TODO: changing gaussianblur2 radius doesn't seem to work
		
		if([name isEqualToString:@"gaussianBlur"]||[name isEqualToString:@"gaussianBlur2"])
		{
			if(blurOverride()>0)
			{
				[filter setValue:[NSNumber numberWithDouble:blurOverride()] forKey:@"inputRadius"];
			}
		}
		
		[newFilters addObject:filter];
	}
	
	real_setFilters(self,selector,newFilters);
	
	newFilters.release;
}

void blursSetup()
{
	swizzleImp(@"CABackdropLayer",@"setScale:",true,(IMP)fake_setScale,(IMP*)&real_setScale);
	swizzleImp(@"CABackdropLayer",@"setFilters:",true,(IMP)fake_setFilters,(IMP*)&real_setFilters);
}