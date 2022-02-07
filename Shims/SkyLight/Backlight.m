// keyboard backlight tests

int SLSDisplayManagerRegisterPowerStateNotificationOptions(dispatch_queue_t rdi_queue,int esi,int edx,void* rcx_block)
{
	trace(@"SLSDisplayManagerRegisterPowerStateNotificationOptions %p %d %d %p %@",rdi_queue,esi,edx,rcx_block,NSThread.callStackSymbols);
	
	return 0;
}