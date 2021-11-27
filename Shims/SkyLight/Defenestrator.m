// window backing surfaces

@interface ContextWrapper:NSObject

@property unsigned int connectionID;
@property unsigned int windowID;
@property unsigned int surfaceID;
@property(assign) CAContext* context;
@property(assign) char* backdrop;

@end

NSMutableDictionary<NSNumber*,ContextWrapper*>* contextWrappers;

ContextWrapper* wrapperForWindow(unsigned int windowID)
{
	return contextWrappers[[NSNumber numberWithInt:windowID]];
}

void defenestratorSetup()
{
	contextWrappers=NSMutableDictionary.alloc.init;
}

@implementation ContextWrapper

-(instancetype)initWithConnectionID:(unsigned int)connectionID windowID:(unsigned int)windowID context:(CAContext*)context
{
	trace(@"ContextWrapper init %d %d %@",connectionID,windowID,context);
	
	_connectionID=connectionID;
	_windowID=windowID;
	_context=context.retain;
	
	unsigned int surfaceID;
	SLSAddSurface(connectionID,windowID,&surfaceID);
	SLSBindSurface(connectionID,windowID,surfaceID,4,0,context.contextId);
	SLSOrderSurface(connectionID,windowID,surfaceID,1,0);
	_surfaceID=surfaceID;
	
	_backdrop=NULL;
	
	self.updateSurfaceBounds;
	
	return self;
}

-(void)updateSurfaceBounds
{
	CGRect bounds;
	SLSGetWindowBounds(_connectionID,_windowID,&bounds);
	
	// trace(@"ContextWrapper updateSurfaceBounds %@",NSStringFromRect(bounds));
	
	bounds.origin.x=0;
	bounds.origin.y=0;
	
	SLSSetSurfaceBounds(_connectionID,_windowID,_surfaceID,bounds);
	
	if(blurBeta())
	{
		if(_backdrop)
		{
			SLSWindowBackdropRelease(_backdrop);
		}
		
		// TODO: why
		bounds.size.width+=1;
		
		_backdrop=SLSWindowBackdropCreateWithLevelAndTintColor(_windowID,@"Mimic",@"Sover",0,NULL,bounds);
	}
}

// TODO: not called when a window is destroyed, only when context is overwritten

-(void)dealloc
{
	trace(@"ContextWrapper dealloc");
	
	// TODO: *Surface* calls are not undone
	
	_context.release;
	
	if(_backdrop)
	{
		SLSWindowBackdropRelease(_backdrop);
	}
	
	super.dealloc;
}

@end

unsigned int SLSSetWindowLayerContext(unsigned int edi_connectionID,unsigned int esi_windowID,CAContext* rdx_context)
{
	ContextWrapper* wrapper=[ContextWrapper.alloc initWithConnectionID:edi_connectionID windowID:esi_windowID context:rdx_context];
	NSNumber* key=[NSNumber numberWithInt:esi_windowID];
	contextWrappers[key]=wrapper;
	wrapper.release;
	
	return 0;
}

// TODO: non ideal way to detect bounds change, but makes visual synchronization easy

unsigned int SLSShapeWindowInWindowCoordinates(unsigned int edi_connectionID,unsigned int esi_windowID,char* rdx_region,unsigned int ecx,unsigned int r8d,unsigned int r9d,unsigned int stack)
{
	unsigned int result=SLSShapeWindowInWindowCoordinate$(edi_connectionID,esi_windowID,rdx_region,ecx,r8d,r9d,stack);
	
	wrapperForWindow(esi_windowID).updateSurfaceBounds;
	
	return result;
}