// TODO: relative jumps
// TODO: basic math
// TODO: variables or a stack
// TODO: nop auto size

#import "Utils.h"

NSMutableData* data;
unsigned long position;

int currentLine;
int lastModifiedLine;

NSMutableData* dataFromHexString(NSString* string)
{
	if(![string hasPrefix:@"0x"])
	{
		trace(@"not a hex string");
		exit(1);
	}
	
	string=[string substringFromIndex:2];
	if(string.length%2==1)
	{
		string=[@"0" stringByAppendingString:string];
	}
	
	NSMutableData* data=NSMutableData.alloc.init;
	
	for(unsigned long index=0;index<string.length;index+=2)
	{
		unsigned char byte;
		sscanf(string.UTF8String+index,"%2hhx",&byte);
		[data appendBytes:&byte length:1];
	}
	
	return data.autorelease;
}

unsigned long longFromData(NSData* data)
{
	if(data.length>sizeof(long))
	{
		trace(@"data too long");
		exit(1);
	}
	
	unsigned long result=0;
	
	for(unsigned int index=0;index<data.length;index++)
	{
		result+=((unsigned char*)data.bytes)[index];
		if(index<data.length-1)
		{
			result<<=8;
		}
	}
	
	return result;
}

unsigned long longFromHexString(NSString* string)
{
	return longFromData(dataFromHexString(string));
}

NSString* hexStringFromData(NSData* data)
{
	NSMutableString* result=NSMutableString.alloc.init;
	
	[result appendString:@"0x"];
	
	for(unsigned long index=0;index<data.length;index++)
	{
		[result appendFormat:@"%02hhx",((unsigned char*)data.bytes)[index]];
	}
	
	return result.autorelease;
}

void setPosition(unsigned long newPosition)
{
	if(newPosition>data.length)
	{
		trace(@"out of bounds");
		exit(1);
	}
	
	position=newPosition;
	
	trace(@"    offset 0x%lx",position);
}

void patch(NSData* input)
{
	trace(@"    patch %@",hexStringFromData(input));
	memcpy(data.mutableBytes+position,input.bytes,input.length);
	
	setPosition(position+input.length);
	
	lastModifiedLine=currentLine;
}

void findBytesCommon(NSString* needleString,BOOL forward)
{
	NSData* needle=dataFromHexString(needleString);
	NSRange found;
	
	if(forward)
	{
		NSRange range=NSMakeRange(position,data.length-position);
		found=[data rangeOfData:needle options:0 range:range];
	}
	else
	{
		NSRange range=NSMakeRange(0,position);
		found=[data rangeOfData:needle options:NSDataSearchBackwards range:range];
	}
	
	if(found.location==NSNotFound)
	{
		trace(@"not found");
		exit(1);
	}
	
	setPosition(found.location);
}

NSCharacterSet* nonHexCharacters=nil;
NSMutableDictionary<NSString*,NSNumber*>* assemblyCacheLines=nil;
NSMutableDictionary<NSString*,NSArray*>* assemblyCache=nil;
BOOL alwaysCacheAssembly=true;

unsigned long addressFromDumpLine(NSString* line)
{
	NSString* lineTrimmed=[line stringByTrimmingCharactersInSet:nonHexCharacters];
	NSArray<NSString*>* lineBits=[lineTrimmed componentsSeparatedByCharactersInSet:nonHexCharacters];
	
	if(lineBits.count==0||lineBits.firstObject.length<4)
	{
		return 0;
	}
	
	return longFromHexString([@"0x" stringByAppendingString:lineBits.firstObject]);
}

void assemblyRegexCommon(NSArray<NSString*>* commandPrefix,NSArray<NSString*>* argList)
{
	if(!nonHexCharacters)
	{
		nonHexCharacters=[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef"].invertedSet.retain;
		assemblyCacheLines=NSMutableDictionary.alloc.init;
		assemblyCache=NSMutableDictionary.alloc.init;
	}
	
	NSArray<NSString*>* dumpLines=nil;
	
	NSString* commandName=commandPrefix.firstObject;
	if(assemblyCacheLines[commandName])
	{
		if(alwaysCacheAssembly||assemblyCacheLines[commandName].intValue>lastModifiedLine)
		{
			trace(@"    using cached dump");
			dumpLines=assemblyCache[commandName];
		}
		else
		{
			trace(@"    rejecting cached dump");
		}
	}
	
	if(!dumpLines)
	{
		char tempPathC[]="/tmp/Binpatcher.XXXXX";
		if(!mktemp(tempPathC))
		{
			trace(@"mktemp error");
			exit(1);
		}
		
		NSString* tempPath=[NSString stringWithUTF8String:tempPathC];
		
		NSError* writeError=nil;
		[data writeToFile:tempPath options:0 error:&writeError];
		if(writeError)
		{
			trace(@"write error");
			exit(1);
		}
		
		NSString* dumpString=nil;
		if(runTask([commandPrefix arrayByAddingObject:tempPath],nil,&dumpString))
		{
			trace(@"task error");
			exit(1);
		}
		
		if(remove(tempPathC))
		{
			trace(@"remove error");
			exit(1);
		}
		
		dumpLines=[dumpString componentsSeparatedByString:@"\n"];
		
		assemblyCacheLines[commandName]=[NSNumber numberWithInt:currentLine];
		assemblyCache[commandName]=dumpLines;
	}
	
	NSString* directionString=argList.firstObject;
	BOOL forward=false;
	if([directionString isEqualToString:@"forward"])
	{
		forward=true;
	}
	else if(![directionString isEqualToString:@"backward"])
	{
		trace(@"must specify direction");
		exit(1);
	}
	
	NSString* regexString=[[argList subarrayWithRange:NSMakeRange(1,argList.count-1)] componentsJoinedByString:@" "];
	
	NSError* regexError=nil;
	NSRegularExpression* regex=[NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&regexError];
	if(regexError)
	{
		trace(@"regex error");
		exit(1);
	}
	
	// TODO: assumes one TEXT,text
	struct segment_command_64* textSeg=findSegmentCommand((char*)data.bytes,SEG_TEXT);
	struct section_64* textSect=findSectionCommand((char*)data.bytes,SEG_TEXT,SECT_TEXT);
	unsigned long textAddress=textSect->addr;
	unsigned long textOffset=textSeg->fileoff+textSect->offset;
	unsigned long addressDelta=textAddress-textOffset;
	trace(@"    address delta 0x%lx",addressDelta);
	
	NSArray<NSString*>* relevantLines;
	
	unsigned long lastAddress=0;
	unsigned long targetAddress=position+addressDelta;
	unsigned long step=dumpLines.count/2;
	long index=0;
	unsigned int binarySearchCount=0;
	while(true)
	{
		binarySearchCount++;
		
		unsigned long address=addressFromDumpLine(dumpLines[index]);
		
		if(address<targetAddress)
		{
			index+=step;
		}
		else
		{
			if(address==targetAddress)
			{
				break;
			}
			
			if(step==1&&lastAddress<targetAddress)
			{
				break;
			}
			
			index-=step;
		}
		
		lastAddress=address;
		
		index=MIN(MAX(index,0),dumpLines.count-1);
		step=MAX((step+1)/2,1);
	}
	
	// TODO: the function's last major performance issue
	if(forward)
	{
		trace(@"    skipping to line %d (%d comparisons)",index,binarySearchCount);
		relevantLines=[dumpLines subarrayWithRange:NSMakeRange(index,dumpLines.count-index)];
	}
	else
	{
		trace(@"    trimming to line %d (%d comparisons)",index,binarySearchCount);
		relevantLines=[dumpLines subarrayWithRange:NSMakeRange(0,index)];
	}
	NSString* relevantString=[relevantLines componentsJoinedByString:@"\n"];
	
	NSArray<NSTextCheckingResult*>* matches=[regex matchesInString:relevantString options:0 range:NSMakeRange(0,relevantString.length)];
	
	if(matches.count==0)
	{
		trace(@"not found");
		exit(1);
	}
	
	NSTextCheckingResult* match=forward?matches.firstObject:matches.lastObject;
	
	NSString* matchString=[relevantString substringWithRange:match.range];
	trace(@"    match %@",matchString);
	
	unsigned long address=addressFromDumpLine(matchString);
	
	setPosition(address-addressDelta);
}

NSMutableArray<NSString*>* commandNames;
NSMutableArray<NSString*>* commandExamples;
NSMutableArray<void (^)(NSArray<NSString*>*)>* commandBlocks;

void initCommands()
{
	commandNames=NSMutableArray.alloc.init;
	commandExamples=NSMutableArray.alloc.init;
	commandBlocks=NSMutableArray.alloc.init;
	
	[commandNames addObject:@"set"];
	[commandExamples addObject:@"0xcafe | +0xcafe | -0xcafe"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		NSString* offsetString=argList.firstObject;
		
		if([offsetString hasPrefix:@"+"])
		{
			setPosition(position+longFromHexString([offsetString substringFromIndex:1]));
		}
		else if([offsetString hasPrefix:@"-"])
		{
			setPosition(position-longFromHexString([offsetString substringFromIndex:1]));
		}
		else
		{
			setPosition(longFromHexString(offsetString));
		}
	}];
	
	[commandNames addObject:@"forward"];
	[commandExamples addObject:@"0xbabe"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		findBytesCommon(argList.firstObject,true);
	}];
	
	[commandNames addObject:@"backward"];
	[commandExamples addObject:@"0xbabe"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		findBytesCommon(argList.firstObject,false);
	}];
	
	[commandNames addObject:@"symbol"];
	[commandExamples addObject:@"_fs_snapshot_create"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		unsigned long offset=findSymbolOffset(data.mutableBytes,argList.firstObject);
		if(!offset)
		{
			trace(@"not found");
			exit(1);
		}
		
		setPosition(offset);
	}];
	
	[commandNames addObject:@"write"];
	[commandExamples addObject:@"0xface"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		NSData* data=dataFromHexString(argList.firstObject);
		patch(data);
	}];
	
	[commandNames addObject:@"nop"];
	[commandExamples addObject:@"0x1a4"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		unsigned long count=longFromHexString(argList.firstObject);
		NSString* string=[@"0x" stringByPaddingToLength:(count+1)*2 withString:@"90" startingAtIndex:0];
		patch(dataFromHexString(string));
	}];
	
	[commandNames addObject:@"return"];
	[commandExamples addObject:@"0x45"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		unsigned long value=longFromHexString(argList.firstObject);
		
		// movabs rax,<value>
		// ret
		NSString* string=[NSString stringWithFormat:@"0x48b8%016llxc3",htonll(value)];
		patch(dataFromHexString(string));
	}];
	
	[commandNames addObject:@"otool"];
	[commandExamples addObject:@"( forward | backward ) (?m)^.+?rdrand.+?$"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		assemblyRegexCommon(@[@"/usr/bin/otool",@"-xVj"],argList);
	}];
	
	[commandNames addObject:@"objdump"];
	[commandExamples addObject:@"( forward | backward ) (?m)^.+?rdrand.+?$"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		assemblyRegexCommon(@[@"/usr/bin/objdump",@"-d",@"--x86-asm-syntax=intel"],argList);
	}];
	
	[commandNames addObject:@"strict_cache"];
	[commandExamples addObject:@""];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		alwaysCacheAssembly=false;
	}];
}

int main(int argCount,char* argList[])
{
	initCommands();
	
	if(argCount!=4)
	{
		trace(@"usage: %s in.dylib out.dylib <script>\ncommands:",argList[0]);
		for(unsigned int index=0;index<commandNames.count;index++)
		{
			trace(@"  %@ %@",commandNames[index],commandExamples[index]);
		}
		return 1;
	}
	
	NSString* inPath=[NSString stringWithUTF8String:argList[1]];
	NSString* outPath=[NSString stringWithUTF8String:argList[2]];
	NSString* script=[NSString stringWithUTF8String:argList[3]];
	
	trace(@"reading %@",inPath);
	data=[NSMutableData dataWithContentsOfFile:inPath];
	
	if(!data)
	{
		trace(@"read error");
		return 1;
	}
	
	position=0;
	
	lastModifiedLine=-1;
	
	NSArray<NSString*>* commands=[script componentsSeparatedByString:@"\n"];
	for(unsigned int index=0;index<commands.count;index++)
	{
		@autoreleasepool
		{
			currentLine=index;
			
			if(commands[index].length==0)
			{
				continue;
			}
			
			if([commands[index] hasPrefix:@"#"])
			{
				continue;
			}
			
			NSArray<NSString*>* bits=[commands[index] componentsSeparatedByString:@" "];
			
			trace(@"  %@",commands[index]);
			
			NSString* name=bits.firstObject;
			NSUInteger commandIndex=[commandNames indexOfObject:name];
			if(commandIndex==NSNotFound)
			{
				trace(@"invalid command");
				return 1;
			}
			
			NSRange argsRange=NSMakeRange(1,bits.count-1);
			NSArray<NSString*>* args=[bits subarrayWithRange:argsRange];
			
			commandBlocks[commandIndex](args);
		}
	}
	
	trace(@"writing %@",outPath);
	NSError* writeError=nil;
	[data writeToFile:outPath options:0 error:&writeError];
	if(writeError)
	{
		trace(@"write error");
		return 1;
	}
	
	return 0;
}