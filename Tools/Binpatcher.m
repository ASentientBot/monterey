#import "Utils.h"

NSMutableData* data;
unsigned long position;

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
		NSString* offsetString=argList[0];
		
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
		findBytesCommon(argList[0],true);
	}];
	
	[commandNames addObject:@"backward"];
	[commandExamples addObject:@"0xbabe"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		findBytesCommon(argList[0],false);
	}];
	
	[commandNames addObject:@"symbol"];
	[commandExamples addObject:@"_fs_snapshot_create"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		unsigned long offset=findSymbolOffset(data.mutableBytes,argList[0]);
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
		NSData* data=dataFromHexString(argList[0]);
		patch(data);
	}];
	
	[commandNames addObject:@"nop"];
	[commandExamples addObject:@"0x1a4"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		unsigned long count=longFromHexString(argList[0]);
		NSString* string=[@"0x" stringByPaddingToLength:(count+1)*2 withString:@"90" startingAtIndex:0];
		patch(dataFromHexString(string));
	}];
	
	[commandNames addObject:@"return"];
	[commandExamples addObject:@"0x45"];
	[commandBlocks addObject:^(NSArray<NSString*>* argList)
	{
		unsigned long value=longFromHexString(argList[0]);
		
		// movabs rax,<value>
		// ret
		NSString* string=[NSString stringWithFormat:@"0x48b8%016llxc3",htonll(value)];
		patch(dataFromHexString(string));
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
	
	NSArray<NSString*>* commands=[script componentsSeparatedByString:@"\n"];
	for(unsigned int index=0;index<commands.count;index++)
	{
		if(commands[index].length==0)
		{
			continue;
		}
		
		NSArray<NSString*>* bits=[commands[index] componentsSeparatedByString:@" "];
		
		NSString* name=bits[0];
		if([name isEqualToString:@"#"])
		{
			continue;
		}
		
		trace(@"  %@",commands[index]);
		
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