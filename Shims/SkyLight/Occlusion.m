// WebKit animations, requestAnimationFrame, Activity Monitor table

// TODO: actually fix occlusion notifications

unsigned long fake_occlusionState()
{
	trace(@"fake_occlusionState");
	
	// NSWindowOcclusionStateVisible (can't link AppKit)
	return 2;
}

void occlusionSetup()
{
	swizzleImp(@"NSWindow",@"occlusionState",true,(IMP)fake_occlusionState,NULL);
}