// TODO: reimplement print-to-file
// TODO: reimplement indentation and custom prefixes
// and then update other code to use it

BOOL traceLog=false;
BOOL tracePrint=true;

void trace(NSString* format,...)
{
	va_list argList;
	va_start(argList,format);
	NSString* message=[NSString.alloc initWithFormat:format arguments:argList];
	va_end(argList);
	
	if(traceLog)
	{
		NSLog(@"ASB: %@",message);
	}
	
	if(tracePrint)
	{
		printf("\e[35m%s\e[0m\n",message.UTF8String);
		fflush(stdout);
	}
	
	message.release;
}