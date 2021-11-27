// Monterey display timing

// does more harm than good on 12.1 -- thanks EduCovas for pointing this out!

// CoreVideo uses a fallback when unable to load symbols
// no/stub SLSDisplayGetCurrentVBLDelta

// AppKit +[NSDisplayTiming displayTimingForScreenNumber:targetUpdateInterval:]
// returns early if structOut is null
// otherwise crashes with assertions on structOut members
char** SLSDisplayGetTiming(char** rdi_structOut,unsigned long rsi,unsigned int edi_screenID)
{
	// trace(@"SLSDisplayGetTiming %@",NSThread.callStackSymbols);
	
	*rdi_structOut=NULL;
	return rdi_structOut;
}