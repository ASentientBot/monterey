// keyboard backlight

#define BACKLIGHT_INTERVAL 1
#define BACKLIGHT_MAX 100
#define BACKLIGHT_AFTER 10

BOOL CBALCKeyboardFeatureAvailable();

BOOL fake_CBALCKeyboardFeatureAvailable()
{
	trace(@"fake_CBALCKeyboardFeatureAvailable");
	
	if(isWindowServer)
	{
		// runTask(@[@"/bin/bash",@"-c",@"ioreg -l > /tmp/ASB_ioreg_pre.txt"],nil,nil);
		
		for(NSTimeInterval wait=0;wait<BACKLIGHT_MAX;wait+=BACKLIGHT_INTERVAL)
		{
			if(CBALCKeyboardFeatureAvailable())
			{
				trace(@"backlight: als-lgp-version appeared");
				[NSThread sleepForTimeInterval:BACKLIGHT_AFTER];
				
				// runTask(@[@"/bin/bash",@"-c",@"ioreg -l > /tmp/ASB_ioreg_post.txt"],nil,nil);
				
				return true;
			}
			
			trace(@"backlight: sleeping (%lf)",wait);
			[NSThread sleepForTimeInterval:BACKLIGHT_INTERVAL];
		}
		
		trace(@"backlight: giving up");
	}
	
	trace(@"backlight: passing through");
	
	return CBALCKeyboardFeatureAvailable();
}

DYLD_INTERPOSE(fake_CBALCKeyboardFeatureAvailable,CBALCKeyboardFeatureAvailable)