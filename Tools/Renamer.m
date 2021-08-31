#import "Utils.h"

unsigned int recurseTrie(char* startPointer,char* currentPointer,NSString* currentSymbol,NSArray<NSString*>* targetList)
{
	unsigned int count=0;
	
	unsigned int endLength=readULEB128(&currentPointer);
	if(endLength)
	{
		currentPointer++;
		readULEB128(&currentPointer);
	}
	
	unsigned char childCount=*currentPointer;
	currentPointer++;
	
	for(unsigned int childIndex=0;childIndex<childCount;childIndex++)
	{
		char* nextString=currentPointer;
		NSString* newSymbol=[currentSymbol stringByAppendingFormat:@"%s",nextString];
		
		NSUInteger targetIndex=[targetList indexOfObject:newSymbol];
		if(targetIndex!=NSNotFound)
		{
			nextString[strlen(nextString)-1]='$';
			NSString* newNewSymbol=[currentSymbol stringByAppendingFormat:@"%s",nextString];
			trace(@"  %@ --> %@",newSymbol,newNewSymbol);
			count++;
		}
		
		currentPointer+=strlen(nextString)+1;
		unsigned int nextOffset=readULEB128(&currentPointer);
		count+=recurseTrie(startPointer,startPointer+nextOffset,newSymbol,targetList);
	}
	
	return count;
}

int main(int argCount,char* argList[])
{
	if(argCount<4)
	{
		trace(@"usage: %s in.dylib out.dylib _symbol1 [_symbol2 [...]]",argList[0]);
		
		return 1;
	}
	
	NSString* inPath=[NSString stringWithUTF8String:argList[1]];
	NSString* outPath=[NSString stringWithUTF8String:argList[2]];
	
	NSMutableArray<NSString*>* targetSymbols=NSMutableArray.alloc.init;
	for(unsigned int index=3;index<argCount;index++)
	{
		[targetSymbols addObject:[NSString stringWithUTF8String:argList[index]]];
	}
	
	trace(@"reading %@",inPath);
	NSMutableData* data=[NSMutableData dataWithContentsOfFile:inPath];
	if(!data)
	{
		trace(@"read error");
		return 1;
	}
	
	char* pointer=data.mutableBytes;
	struct dyld_info_command* infoCommand=(struct dyld_info_command*)findLoadCommandOfType(pointer,LC_DYLD_INFO_ONLY);
	pointer=(char*)data.mutableBytes+infoCommand->export_off;
	
	if(recurseTrie(pointer,pointer,@"",targetSymbols)!=targetSymbols.count)
	{
		trace(@"not all symbols were found");
		return 1;
	}
	targetSymbols.release;
	
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