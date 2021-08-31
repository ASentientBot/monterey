// fix blurs in Dock, Control Center, Notification Center, loginwindow, Finder title bar, etc.

void (*real_setScale)(id,SEL,double);

void fake_setScale(id self,SEL selector,double value)
{
	// TODO: a mystery
	value=MAX(value,0.25);
	
	real_setScale(self,selector,value);
}

void blursSetup()
{
	swizzleImp(@"CABackdropLayer",@"setScale:",true,(IMP)fake_setScale,(IMP*)&real_setScale);
}