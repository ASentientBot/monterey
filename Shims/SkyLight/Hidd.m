// pretty much just lifted from hidd

// TODO: check signatures
void* IOHIDEventSystemCreate(CFAllocatorRef);
long IOHIDEventSystemOpen(void*,void*,void*,void*,long);
long IOHIDEventSystemSetProperty(void*,CFStringRef,void*);

// TODO: necessary?
dispatch_queue_t hiddQueue;

void hiddSetup()
{
	if([NSProcessInfo.processInfo.arguments[0] isEqualToString:@"/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/Resources/WindowServer"])
	{
		dispatch_queue_attr_t queueSettings=dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,QOS_CLASS_USER_INTERACTIVE,-1);
		hiddQueue=dispatch_queue_create(NULL,queueSettings);
		
		dispatch_async(hiddQueue,^()
		{
			void* system=IOHIDEventSystemCreate(kCFAllocatorDefault);
			
			if(!system)
			{
				trace(@"IOHIDEventSystemCreate failed, system will be unresponsive without HiddHack!");
				return;
			}
			
			trace(@"IOHIDEventSystemOpen %ld",IOHIDEventSystemOpen(system,NULL,NULL,NULL,0));
			
			io_service_t service=IORegistryEntryFromPath(kIOMainPortDefault,"IOService:/IOResources/IOHIDSystem");
			
			CFStringRef paramsKey=(CFStringRef)@"HIDParameters";
			NSDictionary* params=IORegistryEntryCreateCFProperty(service,paramsKey,kCFAllocatorDefault,0);
			// trace(@"%@ %@",paramsKey,params);
			IOHIDEventSystemSetProperty(system,paramsKey,params);
			
			IOObjectRelease(service);
			params.release;
			
			// IOHIDEventSystem not freed
		});
	}
}