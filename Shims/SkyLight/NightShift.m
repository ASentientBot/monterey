// enable Night Shift

// TODO: enable in prefpane too

NSString* ASI_CopyComputerModelName(int edi_includeNumbers);

NSString* fake_CCMN(int edi_includeNumbers)
{
	if([@[@"/usr/libexec/corebrightnessd",@"/System/Library/CoreServices/ControlCenter.app/Contents/MacOS/ControlCenter"] containsObject:process])
	{
		return @"MacBook420,69".retain;
	}
	
	return ASI_CopyComputerModelName(edi_includeNumbers);
}

DYLD_INTERPOSE(fake_CCMN,ASI_CopyComputerModelName)