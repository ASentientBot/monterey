// TODO: spaghetti

#import "Utils.h"

NSString* oldPath;
NSString* newPath;
NSString* codePath;
NSString* outPath;

NSString* name;
NSArray<NSString*>* oldSymbols;
NSArray<NSString*>* newSymbols;
NSMutableArray<NSString*>* symbols;
NSMutableString* output;
NSMutableString* shims;
NSMutableArray<NSString*>* constantNames;
NSMutableArray<NSString*>* functionNames;
NSString* shimMainPath;

NSArray<NSString*>* getSymbols(NSString* path)
{
	NSString* symbolsString;
	
	if(runTask(@[@"/usr/bin/nm",@"-gUj",path],nil,&symbolsString))
	{
		return nil;
	}
	
	return [symbolsString componentsSeparatedByString:@"\n"];
}

NSDictionary<NSString*,id>* runObjcHelper(NSString* path)
{
	trace(@"%@",path);
	
	assert(!runTask(@[@"StubberObjcHelper",path],nil,nil));
	
	NSData* jsonData=[NSData dataWithContentsOfFile:@"StubberObjcTemp.json"];
	assert(jsonData);
	
	NSError* error=nil;
	NSDictionary<NSString*,id>* result=[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
	assert(!error);
	
	return result;
}

int runObjcNewWay()
{
	trace(@"RUN HELPER");
	
	NSDictionary<NSString*,id>* oldInfo=runObjcHelper(oldPath);
	NSDictionary<NSString*,id>* newInfo=runObjcHelper(newPath);
	
	int count=0;
	
	// TODO: extremely fragile and probably dependent on my particular coding style
	
	trace(@"PARSE SHIMS");
	
	NSMutableDictionary<NSString*,NSMutableArray*>* shimMethodLines=NSMutableDictionary.alloc.init.autorelease;
	NSArray<NSString*>* shimLines=[shims componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
	NSString* parseClass=nil;
	for(NSString* line in shimLines)
	{
		if([line containsString:@"@implementation"])
		{
			NSArray<NSString*>* bits=[line componentsSeparatedByCharactersInSet:NSCharacterSet.alphanumericCharacterSet.invertedSet];
			for(int index=0;index<bits.count-1;index++)
			{
				if([bits[index] containsString:@"implementation"])
				{
					parseClass=bits[index+1];
					trace(@"into %@",parseClass);
					break;
				}
			}
			
			continue;
		}
		
		if(!parseClass)
		{
			continue;
		}
		
		if([line containsString:@"@end"])
		{
			trace(@"out of %@",parseClass);
			parseClass=nil;
			
			continue;
		}
		
		if(line.length<2)
		{
			continue;
		}
		
		NSString* first2=[line substringToIndex:2];
		if([first2 isEqualToString:@"-("]||[first2 isEqualToString:@"+("])
		{
			trace(@"method %@",line);
			
			if(!shimMethodLines[parseClass])
			{
				shimMethodLines[parseClass]=NSMutableArray.alloc.init.autorelease;
			}
			
			[shimMethodLines[parseClass] addObject:[line stringByAppendingString:@"$"]];
		}
	}
	
	trace(@"COMPARE");
	
	for(NSDictionary* newClass in newInfo)
	{
		NSString* name=newClass[@"name"];
		
		NSDictionary* oldClass=nil;
		for(NSDictionary* oldCheck in oldInfo)
		{
			if([oldCheck[@"name"] isEqualToString:name])
			{
				oldClass=oldCheck;
				break;
			}
		}
		
		NSString* sanity=[@"_OBJC_CLASS_$_" stringByAppendingString:name];
		if(![newSymbols containsObject:sanity])
		{
			trace(@"not exported %@",name);
			continue;
		}
		
		NSString* block=[NSString stringWithFormat:@"// nostub %@\n",name];
		if([shims containsString:block])
		{
			trace(@"explicitly blocked %@",name);
			continue;
		}
		
		// TODO: skip entire classes implemented in shims
		
		NSMutableString* classOutput=NSMutableString.alloc.init.autorelease;
		BOOL addClass=false;
		
		NSArray<NSDictionary*>* oldMethods;
		if(oldClass)
		{
			oldMethods=oldClass[@"methods"];
			
			[classOutput appendString:@"// category - class exists but is missing selectors\n"];
			
			NSString* block=[NSString stringWithFormat:@"// nostubinterface %@\n",name];
			if([shims containsString:block])
			{
				trace(@"explicit nostubinterface %@",name);
			}
			else
			{
				[classOutput appendFormat:@"@interface %@:NSObject\n@end\n",name];
			}
			
			[classOutput appendFormat:@"@interface %@(Stub)\n@end\n@implementation %@(Stub)\n",name,name];
		}
		else
		{
			// TODO: can't add ivars in a category
			// this is going to become a problem sooner or later
			
			oldMethods=@[];
			
			addClass=true;
			
			[classOutput appendFormat:@"// stub - class doesn't exist at all\n@interface %@:NSObject\n{\n",name];
			
			for(NSDictionary* newIvar in newClass[@"ivars"])
			{
				[classOutput appendFormat:@"\t%@",newIvar[@"stub"]];
				count++;
			}
			
			[classOutput appendFormat:@"}\n@end\n@implementation %@\n",name];
		}
		
		for(NSDictionary* newMethod in newClass[@"methods"])
		{
			BOOL skip=false;
			
			NSString* methodName=newMethod[@"name"];
			for(NSDictionary* oldCheck in oldMethods)
			{
				if(((NSNumber*)oldCheck[@"instance"]).boolValue==((NSNumber*)newMethod[@"instance"]).boolValue&&[oldCheck[@"name"] isEqualToString:methodName])
				{
					skip=true;
					break;
				}
			}
			
			if(skip)
			{
				continue;
			}
			
			NSArray<NSString*>* nameBits=[methodName componentsSeparatedByString:@":"];
			for(NSString* line in shimMethodLines[name])
			{
				BOOL allBitsMatch=true;
				NSUInteger lastBitOffset=0;
				for(int index=0;index<nameBits.count;index++)
				{
					NSString* bit=nameBits[index];
					
					if(bit.length==0)
					{
						continue;
					}
					
					if(index==0)
					{
						bit=[@")" stringByAppendingString:bit];
					}
					if(nameBits.count>1)
					{
						bit=[bit stringByAppendingString:@":"];
					}
					else
					{
						bit=[bit stringByAppendingString:@"$"];
					}
					
					NSUInteger bitOffset=[line rangeOfString:bit].location;
					if(bitOffset==NSNotFound||bitOffset<lastBitOffset)
					{
						allBitsMatch=false;
						break;
					}
					
					lastBitOffset=bitOffset;
				}
				
				if(allBitsMatch)
				{
					trace(@"matched shims %@ | %@",methodName,line);
					skip=true;
					break;
				}
			}
			
			if(skip)
			{
				continue;
			}
			
			trace(@"method %@",methodName);
			
			addClass=true;
			
			[classOutput appendString:newMethod[@"stub"]];
			count++;
		}
		
		[classOutput appendString:@"@end\n"];
		
		if(addClass)
		{
			trace(@"class %@",name);
			[output appendString:classOutput];
		}
	}
	
	return count;
}

const int TYPE_ONCE=0;
const int TYPE_PER_SYMBOL=1;

// TODO: weird
const int RET_ERROR=-1;
const int RET_NULL=-2;
const int RET_DONE_KEEP=-3;
const int RET_DONE_DELETE=-4;
const int RET_YES=-5;
const int RET_NO=-6;

NSMutableArray<NSString*>* taskNames;
NSMutableArray<NSNumber*>* taskTypes;
NSMutableArray<int(^)()>* taskBlocks;

void addTask(NSString* name,int type,int (^block)())
{
	[taskNames addObject:name];
	
	[taskTypes addObject:[NSNumber numberWithInt:type]];
	
	int (^heapBlock)()=Block_copy(block);
	[taskBlocks addObject:heapBlock];
	Block_release(heapBlock);
}

void setupTasks()
{
	taskNames=NSMutableArray.alloc.init;
	taskTypes=NSMutableArray.alloc.init;
	taskBlocks=NSMutableArray.alloc.init;
	
	addTask(@"compare symbols",TYPE_ONCE,^int()
	{
		oldSymbols=getSymbols(oldPath);
		newSymbols=getSymbols(newPath);
		
		if(!oldSymbols||!newSymbols)
		{
			return RET_ERROR;
		}
		
		symbols=NSMutableArray.alloc.init;
		for(NSString* newSymbol in newSymbols)
		{
			if([oldSymbols indexOfObject:newSymbol]==NSNotFound)
			{
				NSString* symbolNoUnderscore=[newSymbol substringFromIndex:1];
				[symbols addObject:symbolNoUnderscore];
			}
		}
		
		return symbols.count;
	});
	
	addTask(@"init output",TYPE_ONCE,^int()
	{
		output=NSMutableString.alloc.init;
	
		[output appendString:@"// generated by Stubber\n\n"];
		
		[output appendString:@"@import Foundation;\n"];
		
		return RET_NULL;
	});
	
	addTask(@"read shims",TYPE_ONCE,^int()
	{
		shims=NSMutableString.alloc.init;
		shimMainPath=nil;
		
		NSString* folderPath=[codePath stringByAppendingPathComponent:name];
		
		NSError* error=nil;
		NSArray<NSString*>* fileNames=[NSFileManager.defaultManager contentsOfDirectoryAtPath:folderPath error:&error];
		if(error)
		{
			trace(@"can't list directory %@",folderPath);
			return RET_NO;
		}
		
		unsigned int count=0;
		for(NSString* fileName in fileNames)
		{
			if([fileName hasSuffix:@".m"])
			{
				NSString* filePath=[folderPath stringByAppendingPathComponent:fileName];
				
				if([fileName isEqual:@"Main.m"])
				{
					shimMainPath=filePath;
				}
				
				NSString* shimString=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
				[shims appendString:shimString];
				[shims appendString:@"\n"];
				count++;
			}
		}
		
		return count;
	});
	
	addTask(@"remove explicit ignores",TYPE_PER_SYMBOL,^int(NSString* symbol)
	{
		NSString* check=[NSString stringWithFormat:@"// nostub %@",symbol];
		return [shims containsString:check]?RET_DONE_DELETE:RET_NULL;
	});
	
	addTask(@"(new) add imports",TYPE_ONCE,^int()
	{
		int count=0;
		NSArray<NSString*>* shimLines=[shims componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
		for(NSString* line in shimLines)
		{
			if([line containsString:@"// shimimport"])
			{
				NSString* name=[line componentsSeparatedByString:@" "].lastObject;
				[output appendFormat:@"@import %@;\n",name];
				count++;
			}
		}
		return count;
	});
	
	addTask(@"(new) generate objective-c stubs",TYPE_ONCE,^int()
	{
		return runObjcNewWay();
	});
	
	addTask(@"(new) skip objective-c symbols",TYPE_PER_SYMBOL,^int(NSString* symbol)
	{
		return [symbol containsString:@"OBJC_"]?RET_DONE_DELETE:RET_NULL;
	});
	
	addTask(@"init constants",TYPE_ONCE,^int()
	{
		constantNames=NSMutableArray.alloc.init;
		return RET_NULL;
	});
	
	addTask(@"add constants",TYPE_PER_SYMBOL,^int(NSString* symbol)
	{
		if([NSCharacterSet.lowercaseLetterCharacterSet characterIsMember:[symbol characterAtIndex:0]])
		{
			[constantNames addObject:symbol];
			return RET_DONE_DELETE;
		}
		return RET_NULL;
	});
	
	addTask(@"remove shim constants",TYPE_ONCE,^int()
	{
		unsigned int count=0;
		for(unsigned int index=0;index<constantNames.count;index++)
		{
			NSString* check=[NSString stringWithFormat:@" %@=",constantNames[index]];
			if([shims containsString:check])
			{
				[constantNames removeObjectAtIndex:index];
				index--;
				count++;
			}
		}
		return count;
	});
	
	addTask(@"commit constants",TYPE_ONCE,^int()
	{
		for(NSString* constantName in constantNames)
		{
			[output appendFormat:@"NSString* %@=@\"%@\";\n",constantName,constantName];
		}
		return constantNames.count;
	});
	
	addTask(@"init functions",TYPE_ONCE,^int()
	{
		functionNames=NSMutableArray.alloc.init;
		return RET_NULL;
	});
	
	addTask(@"add functions",TYPE_PER_SYMBOL,^int(NSString* symbol)
	{
		[functionNames addObject:symbol];
		return RET_DONE_DELETE;
	});
	
	addTask(@"remove shim functions",TYPE_ONCE,^int()
	{
		unsigned int count=0;
		for(unsigned int index=0;index<functionNames.count;index++)
		{
			NSString* check=[NSString stringWithFormat:@" %@(",functionNames[index]];
			if([shims containsString:check])
			{
				[functionNames removeObjectAtIndex:index];
				index--;
				count++;
			}
		}
		return count;
	});
	
	addTask(@"commit functions",TYPE_ONCE,^int()
	{
		for(NSString* functionName in functionNames)
		{
			[output appendFormat:@"unsigned long %@()\n{\n\treturn 0;\n}\n",functionName];
		}
		return functionNames.count;
	});
	
	addTask(@"import main",TYPE_ONCE,^int()
	{
		if(shimMainPath)
		{
			[output appendFormat:@"#import \"%@\"\n",shimMainPath];
			return RET_YES;
		}
		return RET_NO;
	});
	
	addTask(@"write output",TYPE_ONCE,^int()
	{
		NSError* error=nil;
		[output writeToFile:outPath atomically:false encoding:NSUTF8StringEncoding error:&error];
		return error?RET_ERROR:RET_NULL;
	});
}

void runTasks()
{
	for(unsigned int index=0;index<taskNames.count;index++)
	{
		trace(@"  %@",taskNames[index]);
		
		switch(taskTypes[index].intValue)
		{
			case TYPE_ONCE:
			{
				int ret=taskBlocks[index]();
				switch(ret)
				{
					case RET_ERROR:
					trace(@"    failed");
					exit(1);
					
					case RET_NULL:
					trace(@"    done");
					break;
					
					case RET_YES:
					trace(@"    yes");
					break;
					
					case RET_NO:
					trace(@"    no");
					break;
					
					default:
					trace(@"    count: %d",ret);
				}
			}
			break;
			
			case TYPE_PER_SYMBOL:
			{
				unsigned int count=0;
				
				for(unsigned int symbolIndex=0;symbolIndex<symbols.count;symbolIndex++)
				{
					int ret=taskBlocks[index](symbols[symbolIndex]);
					switch(ret)
					{
						case RET_ERROR:
						trace(@"    failed");
						exit(1);
						
						case RET_DONE_DELETE:
						[symbols removeObjectAtIndex:symbolIndex];
						symbolIndex--;
						
						case RET_DONE_KEEP:
						
						count++;
					}
				}
				
				trace(@"    count: %d",count);
			}
			break;
		}
	}
}

int main(int argCount,char** argList)
{
	if(argCount!=5)
	{
		trace(@"usage: %s old.dylib new.dylib shims_dir out.m",argList[0]);
		return 1;
	}
	
	oldPath=[NSString stringWithUTF8String:argList[1]];
	newPath=[NSString stringWithUTF8String:argList[2]];
	codePath=[NSString stringWithUTF8String:argList[3]];
	outPath=[NSString stringWithUTF8String:argList[4]];
	
	setupTasks();
	
	name=newPath.lastPathComponent;
	trace(@"name: %@",name);
	
	runTasks();
	
	return 0;
}