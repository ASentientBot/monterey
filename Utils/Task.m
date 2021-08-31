int runTask(NSArray<NSString*>* command,NSString* workingPath,NSString** output)
{
	NSTask* task=NSTask.alloc.init;
	task.executableURL=[NSURL fileURLWithPath:command[0]];
	task.arguments=[command subarrayWithRange:NSMakeRange(1,command.count-1)];
	
	NSPipe* outPipe=NSPipe.pipe;
	NSPipe* errPipe=NSPipe.pipe;
	task.standardOutput=outPipe;
	task.standardError=errPipe;
	
	if(workingPath)
	{
		task.currentDirectoryURL=[NSURL fileURLWithPath:workingPath isDirectory:true];
	}
	
	NSError* error=nil;
	[task launchAndReturnError:&error];
	if(error)
	{
		@throw error;
	}
	
	NSMutableData* data=NSMutableData.alloc.init;
	while(task.running)
	{
		[data appendData:outPipe.fileHandleForReading.readDataToEndOfFile];
		[data appendData:errPipe.fileHandleForReading.readDataToEndOfFile];
	}
	
	if(output)
	{
		*output=[NSString.alloc initWithData:data encoding:NSUTF8StringEncoding].autorelease;
	}
	
	int result=task.terminationStatus;
	
	task.release;
	data.release;
	
	return result;
}