struct load_command* findLoadCommand(char* startPointer,BOOL(^filterBlock)(struct load_command*))
{
	char* pointer=startPointer;
	
	struct mach_header_64* header=(struct mach_header_64*)pointer;
	pointer+=sizeof(struct mach_header_64);
	
	for(unsigned int commandIndex=0;commandIndex<header->ncmds;commandIndex++)
	{
		struct load_command* command=(struct load_command*)pointer;
		if(filterBlock(command))
		{
			return command;
		}
		
		pointer+=command->cmdsize;
	}
	
	return NULL;
}

struct load_command* findLoadCommandOfType(char* startPointer,unsigned int type)
{
	return findLoadCommand(startPointer,^BOOL(struct load_command* command)
	{
		return command->cmd==type;
	});
}

struct segment_command_64* findSegmentCommand(char* startPointer,char* type)
{
	return (struct segment_command_64*)findLoadCommand(startPointer,^BOOL(struct load_command* command)
	{
		if(command->cmd==LC_SEGMENT_64)
		{
			return strcmp(((struct segment_command_64*)command)->segname,type)==0;
		}
		return false;
	});
}

struct section_64* findSectionCommand(char* startPointer,char* segmentType,char* sectionType)
{
	struct segment_command_64* segment=findSegmentCommand(startPointer,segmentType);
	
	struct section_64* section=(struct section_64*)((char*)segment+sizeof(struct segment_command_64));
	for(unsigned int sectionIndex=0;sectionIndex<segment->nsects;sectionIndex++)
	{
		if(strcmp(section->sectname,sectionType)==0)
		{
			return section;
		}
		section++;
	}
	
	return NULL;
}

unsigned long findSymbolOffset(char* startPointer,NSString* targetSymbolName)
{
	char* pointer=startPointer;
	
	struct segment_command_64* textCommand=findSegmentCommand(startPointer,SEG_TEXT);
	struct symtab_command* symtabCommand=(struct symtab_command*)findLoadCommandOfType(startPointer,LC_SYMTAB);
	
	if(!symtabCommand||!textCommand)
	{
		return 0;
	}
	
	char* stringTable=startPointer+symtabCommand->stroff;
	
	unsigned long symbolAddress=0;
	pointer=startPointer+symtabCommand->symoff;
	for(unsigned int symbolIndex=0;symbolIndex<symtabCommand->nsyms;symbolIndex++)
	{
		struct nlist_64* symbolStruct=(struct nlist_64*)pointer;
		NSString* symbolName=[NSString stringWithUTF8String:stringTable+symbolStruct->n_un.n_strx];
		if([symbolName isEqualToString:targetSymbolName])
		{
			symbolAddress=symbolStruct->n_value;
			break;
		}
		
		pointer+=sizeof(struct nlist_64);
	}
	
	unsigned long textDelta=textCommand->vmaddr-textCommand->fileoff;
	unsigned long symbolOffset=symbolAddress-textDelta;
	
	return symbolOffset;
}

// https://en.wikipedia.org/wiki/LEB128#Decode_unsigned_integer

unsigned int readULEB128(char** input)
{
	unsigned int result=0;
	unsigned int shift=0;
	while(true)
	{
		result|=((**input&0x7f)<<shift);
		shift+=7;
		if(!(**input&0x80))
		{
			break;
		}
		*input+=1;
	}
	*input+=1;
	return result;
}