const NSString* PLUGIN_PATH=@"/etc/SkyLightPlugins";
const NSString* PLUGIN_LIST_NAME=@"List.txt";

void pluginsSetup()
{
	NSString* listPath=[PLUGIN_PATH stringByAppendingPathComponent:(NSString*)PLUGIN_LIST_NAME];
	NSString* list=[NSString stringWithContentsOfFile:listPath encoding:NSUTF8StringEncoding error:nil];
	
	if(!list)
	{
		return;
	}
	
	// TODO: dumb, but logging in early boot causes a hang
	BOOL shouldLog=getpid()>200;
	
	NSString* process=NSProcessInfo.processInfo.arguments[0];
	
	NSArray<NSString*>* lines=[list componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
	for(NSString* line in lines)
	{
		NSArray<NSString*>* bits=[line componentsSeparatedByString:@":"];
		if(bits.count!=2)
		{
			continue;
		}
		
		NSString* target=[bits[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
		NSString* dylib=[bits[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
		
		if([target isEqualToString:@"*"]||[target isEqualToString:process])
		{
			if(shouldLog)
			{
				trace(@"matched \"%@\" : \"%@\", loading...",target,dylib);
			}
			
			NSString* dylibPath=[PLUGIN_PATH stringByAppendingPathComponent:dylib];
			void* handle=dlopen(dylibPath.UTF8String,RTLD_NOW);
			
			if(shouldLog)
			{
				if(handle)
				{
					trace(@"...success");
				}
				else
				{
					trace(@"...error (%s)",dlerror());
				}
			}
		}
	}
}