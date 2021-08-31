// display sleep
// from reversed Monterey SkyLight

dispatch_once_t displaySleepOnce;
io_registry_entry_t displaySleepEntry;

unsigned int SLSDisplayManagerRequestDisplaysIdle()
{
	trace(@"SLSDisplayManagerRequestDisplaysIdle");
	
	dispatch_once(&displaySleepOnce,^()
	{
		displaySleepEntry=IORegistryEntryFromPath(kIOMainPortDefault,"IOService:/IOResources/IODisplayWrangler");
	});
	
	IORegistryEntrySetCFProperty(displaySleepEntry,(CFStringRef)@"IORequestIdle",@true);
	
	return 0x3ec;
}

// sleep wake notifications

dispatch_once_t displayNotifyOnce;
NSMutableArray<dispatch_queue_t>* displayNotifyQueues;
NSMutableArray<NSNumber*>* displayNotifyTypes;
NSMutableArray<dispatch_block_t>* displayNotifyBlocks;

void displayNotifyCommon(unsigned int type)
{
	trace(@"displayNotifyCommon %d",type);
	
	for(unsigned int index=0;index<displayNotifyQueues.count;index++)
	{
		if(displayNotifyTypes[index].intValue==type)
		{
			trace(@"calling block");
			dispatch_async(displayNotifyQueues[index],displayNotifyBlocks[index]);
		}
	}

}

void displaySleepCallback()
{
	displayNotifyCommon(3);
}

void displayWakeCallback()
{
	displayNotifyCommon(2);
}

unsigned int SLSDisplayManagerRegisterPowerStateNotification(dispatch_queue_t rdi_queue,unsigned int esi,unsigned int edx_type,dispatch_block_t rcx_block)
{
	trace(@"SLSDisplayManagerRegisterPowerStateNotification (new way) %d",edx_type);
	
	dispatch_once(&displayNotifyOnce,^()
	{
		displayNotifyQueues=NSMutableArray.alloc.init;
		displayNotifyTypes=NSMutableArray.alloc.init;
		displayNotifyBlocks=NSMutableArray.alloc.init;
		
		unsigned int connection=SLSMainConnectionID();
		
		// kCGSDisplayWillSleep
		SLSRegisterConnectionNotifyProc(connection,displaySleepCallback,0x66,nil);
		
		// kCGSDisplayDidWake
		SLSRegisterConnectionNotifyProc(connection,displayWakeCallback,0x67,nil);
	});
	
	[displayNotifyQueues addObject:rdi_queue];
	[displayNotifyTypes addObject:[NSNumber numberWithInt:edx_type]];
	
	// TODO: confirm this is how blocks work
	dispatch_block_t heapBlock=Block_copy(rcx_block);
	[displayNotifyBlocks addObject:heapBlock];
	Block_release(heapBlock);
	
	return 0;
}

// TODO: implement SLSDisplayManagerUnregisterPowerStateNotification