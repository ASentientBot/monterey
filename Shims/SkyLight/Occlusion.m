// WebKit, Activity Monitor refresh based on window visibility

void (*real_setWindowNumber)(id self,SEL selector,unsigned long windowID);

void fake_setWindowNumber(id self,SEL selector,unsigned long windowID)
{
	real_setWindowNumber(self,selector,windowID);
	
	if(windowID!=-1)
	{
		trace(@"fake_setWindowNumber fixing occlusion detection");
		
		SLSPackagesEnableWindowOcclusionNotifications(SLSMainConnectionID(),windowID,1,0);
	}
}

void occlusionSetup()
{
	swizzleImp(@"NSWindow",@"_setWindowNumber:",true,(IMP)fake_setWindowNumber,(IMP*)&real_setWindowNumber);
}