// corrupted graphics in Big Sur photos

// TODO: just copied from old shims, should probably re-check

BOOL fake_deviceDisableOpenGL()
{
	return false;
}

void photosSetup()
{
	if([NSProcessInfo.processInfo.processName isEqualToString:@"Photos"])
	{
		trace(@"enabling Big Sur Photos hack");
		
		swizzleImp(@"NUGlobalSettings",@"deviceDisableOpenGL",false,(IMP)fake_deviceDisableOpenGL,NULL);
	}
}