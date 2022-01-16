// enable Night Shift

// TODO: if possible, implement as a plugin instead

NSString* ASI_CopyComputerModelName(int edi_includeNumbers);

NSString* fake_CCMN(int edi_includeNumbers)
{
	NSString* process=NSProcessInfo.processInfo.arguments[0];
	if([@[@"/usr/libexec/corebrightnessd",@"/System/Library/CoreServices/ControlCenter.app/Contents/MacOS/ControlCenter"] containsObject:process])
	{
		trace(@"fake_CCMN lying");
		
		return @"MacBook420,69".retain;
	}
	
	return ASI_CopyComputerModelName(edi_includeNumbers);
}

DYLD_INTERPOSE(fake_CCMN,ASI_CopyComputerModelName)