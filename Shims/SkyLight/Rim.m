// window borders

const double RIM_DEFAULT=0.2;

BOOL rimBetaValue;
dispatch_once_t rimBetaOnce;
BOOL rimBeta()
{
	dispatch_once(&rimBetaOnce,^()
	{
		rimBetaValue=[NSUserDefaults.standardUserDefaults boolForKey:@"ASB_RimBeta"];
		
		trace(@"ASB_RimBeta %d",rimBetaValue);
	});
	
	return rimBetaValue;
}

double rimOverrideValue;
dispatch_once_t rimOverrideOnce;
double rimOverride()
{
	dispatch_once(&rimOverrideOnce,^()
	{
		rimOverrideValue=[NSUserDefaults.standardUserDefaults doubleForKey:@"ASB_RimOverride"];
		
		trace(@"ASB_RimOverride %lf",rimOverrideValue);
	});
	
	return rimOverrideValue;
}

// TODO: refine

BOOL hasShadow(NSDictionary* properties)
{
	for(NSString* key in @[@"com.apple.WindowShadowDensity",@"com.apple.WindowShadowDensityActive",@"com.apple.WindowShadowDensityInactive"])
	{
		NSNumber* value=properties[key];
		if(value&&value.doubleValue!=0)
		{
			return true;
		}
	}
	
	return false;
}

void SLSWindowSetShadowProperties(unsigned int edi_windowID,NSDictionary* rsi_properties)
{
	trace(@"SLSWindowSetShadowProperties in %d %@",edi_windowID,rsi_properties);
	
	if(!rimBeta()||!hasShadow(rsi_properties))
	{
		trace(@"SLSWindowSetShadowProperties passthrough");
		
		SLSWindowSetShadowPropertie$(edi_windowID,rsi_properties);
		return;
	}
	
	trace(@"SLSWindowSetShadowProperties override");
	
	// hide rim
	
	NSMutableDictionary* newProperties=rsi_properties.mutableCopy;
	
	newProperties[@"com.apple.WindowShadowRimDensityActive"]=@0;
	newProperties[@"com.apple.WindowShadowRimDensityInactive"]=@0;
	
	SLSWindowSetShadowPropertie$(edi_windowID,newProperties);
	
	newProperties.release;
	
	// fake rim
	
	double lightness=RIM_DEFAULT;
	if(rimOverride()>0&&rimOverride()<=1)
	{
		lightness=rimOverride();
	}
	
	CALayer* layer=wrapperForWindow(edi_windowID).context.layer;
	layer.borderWidth=1;
	CGColorRef color=CGColorCreateGenericRGB(lightness,lightness,lightness,1.0);
	layer.borderColor=color;
	CFRelease(color);
}