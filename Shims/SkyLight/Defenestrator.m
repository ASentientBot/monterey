// window backing surfaces

@interface ContextWrapper:NSObject

@property unsigned int connectionID;
@property unsigned int windowID;
@property unsigned int surfaceID;
@property(retain) CAContext* context;

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
	
	self.connectionID=connectionID;
	self.windowID=windowID;
	self.context=context;
	
	unsigned int surfaceID;
	SLSAddSurface(connectionID,windowID,&surfaceID);
	SLSBindSurface(connectionID,windowID,surfaceID,4,0,context.contextId);
	SLSOrderSurface(connectionID,windowID,surfaceID,1,0);
	self.surfaceID=surfaceID;
	
	self.updateSurfaceBounds;
	
	return self;
}

-(void)updateSurfaceBounds
{
	CGRect bounds;
	SLSGetWindowBounds(self.connectionID,self.windowID,&bounds);
	
	// trace(@"ContextWrapper updateSurfaceBounds %@",NSStringFromRect(bounds));
	
	bounds.origin.x=0;
	bounds.origin.y=0;
	
	SLSSetSurfaceBounds(self.connectionID,self.windowID,self.surfaceID,bounds);
}

-(void)dealloc
{
	trace(@"ContextWrapper dealloc");
	
	// TODO: *Surface* calls are not undone
	
	self.context.release;
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