BOOL swizzleLog=true;

BOOL swizzleImp(NSString* className,NSString* selName,BOOL isInstance,IMP newImp,IMP* oldImpOut)
{
	Class class=NSClassFromString(className);
	if(!class)
	{
		if(swizzleLog)
		{
			trace(@"swizzleImp failure (class): %@.%@",className,selName);
		}
		return false;
	}
	
	SEL sel=NSSelectorFromString(selName);
	
	Method method;
	if(isInstance)
	{
		method=class_getInstanceMethod(class,sel);
	}
	else
	{
		method=class_getClassMethod(class,sel);
	}
	
	if(!method)
	{
		if(swizzleLog)
		{
			trace(@"swizzleImp failure (method): %@.%@",className,selName);
		}
		return false;
	}
	
	IMP oldImp=method_setImplementation(method,newImp);
	if(oldImpOut)
	{
		*oldImpOut=oldImp;
	}
	
	if(swizzleLog)
	{
		trace(@"swizzleImp success: %@.%@",className,selName);
	}
	
	return true;
}