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

// TODO: dumb but i can't link AppKit

@interface NSWindowLite:NSObject

@property(assign) unsigned int windowNumber;

@end

unsigned int getNSWindowID(NSWindowLite* window)
{
	return window.windowNumber;
}

void defenestratorSetup()
{
	contextWrappers=NSMutableDictionary.alloc.init;
}

dispatch_once_t defenestratorOnce;

@implementation ContextWrapper

-(instancetype)initWithConnectionID:(unsigned int)connectionID windowID:(unsigned int)windowID context:(CAContext*)context
{
	dispatch_once(&defenestratorOnce,^()
	{
		NSNotificationCenter* center=NSNotificationCenter.defaultCenter;
		
		// TODO: these aren't sent for menu bar dropdowns
		
		[center addObserver:self.class selector:@selector(closeHandler:) name:@"NSWindowWillCloseNotification" object:nil];
		
		if(!blurBeta())
		{
			return;
		}
		
		[center addObserver:self.class selector:@selector(activateHandler:) name:@"NSWindowDidBecomeMainNotification" object:nil];
		[center addObserver:self.class selector:@selector(activateHandler:) name:@"NSWindowDidBecomeKeyNotification" object:nil];
		[center addObserver:self.class selector:@selector(deactivateHandler:) name:@"NSWindowDidResignMainNotification" object:nil];
		[center addObserver:self.class selector:@selector(deactivateHandler:) name:@"NSWindowDidResignKeyNotification" object:nil];
	});
	
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
	SLSSetSurfaceBounds(_connectionID,_windowID,_surfaceID,self.getBounds);
	
	if(blurBeta())
	{
		self.addBackdrop;
	}
}

-(CGRect)getBounds
{
	CGRect bounds;
	SLSGetWindowBounds(_connectionID,_windowID,&bounds);
	
	bounds.origin.x=0;
	bounds.origin.y=0;
	
	return bounds;
}

-(void)removeBackdrop
{
	if(_backdrop)
	{
		SLSWindowBackdropRelease(_backdrop);
		_backdrop=NULL;
	}
}

-(void)addBackdrop
{
	self.removeBackdrop;
	
	CGRect bounds=self.getBounds;
	
	// TODO: why
	bounds.size.width+=1;
	
	_backdrop=SLSWindowBackdropCreateWithLevelAndTintColor(_windowID,@"Mimic",@"Sover",0,NULL,bounds);
}

+(void)activateHandler:(NSNotification*)notification
{
	// trace(@"ContextWrapper activateHandler: %@",notification);
	
	ContextWrapper* wrapper=wrapperForWindow(getNSWindowID(notification.object));
	if(wrapper)
	{
		// TODO
		// SLSWindowBackdropActivate(wrapper.backdrop);
		
		wrapper.addBackdrop;
	}
}

+(void)deactivateHandler:(NSNotification*)notification
{
	// trace(@"ContextWrapper deactivateHandler: %@",notification);
	
	ContextWrapper* wrapper=wrapperForWindow(getNSWindowID(notification.object));
	if(wrapper)
	{
		// TODO
		// SLSWindowBackdropDeactivate(wrapper.backdrop);
		
		wrapper.removeBackdrop;
	}
}

+(void)closeHandler:(NSNotification*)notification
{
	// trace(@"ContextWrapper closeHandler: %@",notification);
	
	// TODO: sometimes a window (e.g. QuickLook) is reused after being closed
	// so we need to detect when the window is permanently destroyed
	// just disabled for now, but this leaks resources...
	
	// [contextWrappers removeObjectForKey:[NSNumber numberWithInt:getNSWindowID(notification.object)]];
}

-(void)dealloc
{
	trace(@"ContextWrapper dealloc");
	
	// TODO: *Surface* calls are not undone
	
	_context.release;
	
	self.removeBackdrop;
	
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