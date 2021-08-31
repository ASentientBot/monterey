// Monterey display timing

// CoreVideo fallback when unable to load symbols
// TODO: update Stubber to avoid hacks like this
// SLSDisplayGetCurrentVBLDelta(

// AppKit +[NSDisplayTiming displayTimingForScreenNumber:targetUpdateInterval:]
// returns early if structOut is null
// otherwise crashes with assertions on structOut members
char** SLSDisplayGetTiming(char** rdi_structOut,unsigned long rsi,unsigned int edi_screenID)
{
	trace(@"SLSDisplayGetTiming");
	
	*rdi_structOut=NULL;
	return rdi_structOut;
}