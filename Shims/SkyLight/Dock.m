// Dock collisions

void SLSGetDockRectWithOrientation(unsigned int edi_connectionID,CGRect* rsi_rectOut,char* rdx_reasonOut,unsigned long* rcx_orientationOut)
{
	// trace(@"SLSGetDockRectWithOrientation (in) %d %@ %ld %ld",edi_connectionID,NSStringFromRect(*rsi_rectOut),*rdx_reasonOut,*rcx_orientationOut);
	
	SLSGetDockRectWithReason(edi_connectionID,rsi_rectOut,rdx_reasonOut);
	
	unsigned long pinningIgnored;
	CoreDockGetOrientationAndPinning(rcx_orientationOut,&pinningIgnored);
	
	// trace(@"SLSGetDockRectWithOrientation (out) %d %@ %ld %ld",edi_connectionID,NSStringFromRect(*rsi_rectOut),*rdx_reasonOut,*rcx_orientationOut);
}

void SLSSetDockRectWithOrientation(unsigned int edi_connectionID,unsigned int esi,unsigned int edx,CGRect stack_rect)
{
	// trace(@"SLSSetDockRectWithOrientation %d %d %d %@",edi_connectionID,esi,edx,NSStringFromRect(stack_rect));
	
	SLSSetDockRectWithReason(edi_connectionID,esi,stack_rect);
}