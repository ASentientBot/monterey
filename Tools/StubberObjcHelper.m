// dumb

@import Foundation;
@import Darwin.POSIX.dlfcn;
@import ObjectiveC.runtime;

// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html

NSMutableDictionary<NSString*,NSArray<NSString*>*>* basicTypes=nil;
NSDictionary<NSString*,NSArray<NSString*>*>* getBasicTypes()
{
	if(!basicTypes)
	{
		basicTypes=NSMutableDictionary.alloc.init;
		basicTypes[@"c"]=@[@"char",@"0"];
		basicTypes[@"i"]=@[@"int",@"0"];
		basicTypes[@"s"]=@[@"short",@"0"];
		basicTypes[@"l"]=@[@"long",@"0"];
		basicTypes[@"q"]=@[@"long long",@"0"];
		basicTypes[@"C"]=@[@"unsigned char",@"0"];
		basicTypes[@"I"]=@[@"unsigned int",@"0"];
		basicTypes[@"S"]=@[@"unsigned short",@"0"];
		basicTypes[@"L"]=@[@"unsigned long",@"0"];
		basicTypes[@"Q"]=@[@"unsigned long long",@"0"];
		basicTypes[@"f"]=@[@"float",@"0"];
		basicTypes[@"d"]=@[@"double",@"0"];
		basicTypes[@"B"]=@[@"bool",@"0"];
		basicTypes[@"v"]=@[@"void",@""];
		basicTypes[@"*"]=@[@"char*",@"NULL"];
		basicTypes[@"#"]=@[@"Class",@"NULL"];
		basicTypes[@":"]=@[@"SEL",@"NULL"];
		basicTypes[@"@"]=@[@"id",@"nil"];
		basicTypes[@"^"]=@[@"void*",@"NULL"];
		basicTypes[@"?"]=@[@"void*",@"NULL"];
	}
	
	return basicTypes;
}

// TODO: make it go up the inheritance hierarchy and check for methods on parents
// rather than hardcoding NSObject ones

NSMutableArray<NSString*>* bannedMethods=nil;
NSArray<NSString*>* getBannedMethods()
{
	if(!bannedMethods)
	{
		bannedMethods=NSMutableArray.alloc.init;
		[bannedMethods addObject:@"isEqual:"];
		[bannedMethods addObject:@"hash"];
		[bannedMethods addObject:@"dealloc"];
		[bannedMethods addObject:@".cxx_destruct"];
		[bannedMethods addObject:@".cxx_construct"];
		[bannedMethods addObject:@"observationInfo"];
		[bannedMethods addObject:@"setObservationInfo:"];
	}
	
	return bannedMethods;
}

NSArray<NSString*>* lookupEncoding(const char* encodingC)
{
	NSString* encoding=[NSString stringWithUTF8String:encodingC];
	NSString* firstChar=[encoding substringToIndex:1];
	NSArray<NSString*>* result=getBasicTypes()[firstChar];
	
	if(!result)
	{
		return @[@"NSString*",@"@\"unimplemented!\""];
	}
	
	return result;
}

NSString* typeFromEncoding(const char* encodingC)
{
	return lookupEncoding(encodingC)[0];
}

NSString* stubValueFromEncoding(const char* encodingC)
{
	return lookupEncoding(encodingC)[1];
}

NSDictionary<NSString*,id>* methodInfo(Method method,BOOL instance)
{
	NSMutableString* stub=NSMutableString.alloc.init.autorelease;
	
	NSString* name=[NSString stringWithUTF8String:sel_getName(method_getName(method))];
	NSArray<NSString*>* nameBits=[name componentsSeparatedByString:@":"];
	
	char* returnType=method_copyReturnType(method);
	
	const char* combinedType=method_getTypeEncoding(method);
	[stub appendFormat:@"// %@ %s %s\n",name,returnType,combinedType];
	
	if([getBannedMethods() containsObject:name])
	{
		[stub appendString:@"// skipped - in StubberObjcHelper.bannedMethods\n"];
	}
	else
	{
		[stub appendFormat:@"%@(%@)%@",instance?@"-":@"+",typeFromEncoding(returnType),nameBits[0]];
		
		int argCount=method_getNumberOfArguments(method);
		for(int argIndex=2;argIndex<argCount;argIndex++)
		{
			if(argIndex>2)
			{
				[stub appendFormat:@" %@",nameBits[argIndex-2]];
			}
			char* type=method_copyArgumentType(method,argIndex);
			[stub appendFormat:@":(%@)arg%d",typeFromEncoding(type),argIndex];
			free(type);
		}
		
		[stub appendFormat:@"\n{\n\treturn %@;\n}\n",stubValueFromEncoding(returnType)];
	}
	
	free(returnType);
	
	NSMutableDictionary<NSString*,id>* output=NSMutableDictionary.alloc.init.autorelease;
	output[@"name"]=name;
	output[@"instance"]=[NSNumber numberWithBool:instance];
	output[@"stub"]=stub;
	
	return output;
}

NSDictionary<NSString*,id>* ivarInfo(Ivar ivar)
{
	NSMutableDictionary<NSString*,id>* output=NSMutableDictionary.alloc.init.autorelease;
	
	NSString* name=[NSString stringWithUTF8String:ivar_getName(ivar)];
	const char* type=ivar_getTypeEncoding(ivar);
	
	output[@"name"]=name;
	output[@"stub"]=[NSString stringWithFormat:@"%@ %@;\n",typeFromEncoding(type),name];
	
	return output;
}

int main(int argCount,char** argList)
{
	NSString* path=[NSString stringWithUTF8String:argList[1]];
	void* handle=dlopen(path.UTF8String,RTLD_LAZY);
	char* dlerror2=dlerror();
	if(dlerror2)
	{
		puts(dlerror2);
	}
	assert(handle);
	
	unsigned int imageCount;
	const char** images=objc_copyImageNames(&imageCount);
	NSString* fullPath=nil;
	for(int index=0;index<imageCount;index++)
	{
		NSString* imagePath=[NSString stringWithUTF8String:images[index]];
		if([imagePath containsString:path])
		{
			assert(!fullPath);
			fullPath=imagePath;
		}
	}
	free(images);
	assert(fullPath);
	
	unsigned int classCount;
	const char** classNames=objc_copyClassNamesForImage(fullPath.UTF8String,&classCount);
	
	NSMutableArray<NSDictionary*>* output=NSMutableArray.alloc.init.autorelease;
	
	for(int classIndex=0;classIndex<classCount;classIndex++)
	{
		Class class=objc_lookUpClass(classNames[classIndex]);
		unsigned int ivarCount;
		Ivar* ivars=class_copyIvarList(class,&ivarCount);
		unsigned int methodCount;
		Method* methods=class_copyMethodList(class,&methodCount);
		Class metaClass=objc_getMetaClass(classNames[classIndex]);
		unsigned int metaMethodCount;
		Method* metaMethods=class_copyMethodList(metaClass,&metaMethodCount);
		
		NSMutableArray<NSDictionary*>* ivarOutput=NSMutableArray.alloc.init.autorelease;
		for(int ivarIndex=0;ivarIndex<ivarCount;ivarIndex++)
		{
			[ivarOutput addObject:ivarInfo(ivars[ivarIndex])];
		}
		
		NSMutableArray<NSDictionary*>* methodOutput=NSMutableArray.alloc.init.autorelease;
		for(int methodIndex=0;methodIndex<methodCount;methodIndex++)
		{
			[methodOutput addObject:methodInfo(methods[methodIndex],true)];
		}
		for(int methodIndex=0;methodIndex<metaMethodCount;methodIndex++)
		{
			[methodOutput addObject:methodInfo(metaMethods[methodIndex],false)];
		}
		
		free(ivars);
		free(methods);
		free(metaMethods);
		
		NSMutableDictionary<NSString*,id>* classOutput=NSMutableDictionary.alloc.init;
		classOutput[@"methods"]=methodOutput;
		classOutput[@"ivars"]=ivarOutput;
		classOutput[@"name"]=[NSString stringWithUTF8String:classNames[classIndex]];
		
		[output addObject:classOutput];
	}
	
	free(classNames);
	
	NSError* error=nil;
	NSData* jsonData=[NSJSONSerialization dataWithJSONObject:output options:0 error:&error];
	assert(!error);
	
	[jsonData writeToFile:@"StubberObjcTemp.json" atomically:true];
}