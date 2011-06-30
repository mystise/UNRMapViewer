//
//  UNRFile.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UNRFile.h"
#import "UNRName.h"
#import "UNRImport.h"
#import "UNRExport.h"
#import "UNRBase.h"
#import "UNRGuid.h"
#import "UNRGeneration.h"
#import "UNRDataPluginLoader.h"

@implementation UNRFile

@synthesize objects = objects_, names = names_, references = references_, version = version_, licensee = licensee_, flags = flags_, generations = generations_, pluginLoader = pluginLoader_;

- (id)init{
	self = [super init];
	if(self){
		self.objects = [NSMutableArray array];
		self.names = [NSMutableArray array];
		self.references = [NSMutableArray array];
		self.generations = [NSMutableArray array];
		self.version = [NSNumber numberWithInt:0];
		self.licensee = [NSNumber numberWithInt:0];
		self.flags = [NSNumber numberWithInt:0];
		//self.subFiles = [NSMutableDictionary dictionary];
	}
	return self;
}

- (id)initWithFileData:(NSData *)fileData pluginsDirectory:(NSString *)path{
	self = [super init];
	if(self){
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		id loader = [[UNRDataPluginLoader alloc] initWithDirectory:path];
		self.pluginLoader = loader;
		[loader release];
		
		self.objects = [NSMutableArray array];
		self.names = [NSMutableArray array];
		self.references = [NSMutableArray array];
		self.generations = [NSMutableArray array];
		self.version = [NSNumber numberWithInt:0];
		self.licensee = [NSNumber numberWithInt:0];
		self.flags = [NSNumber numberWithInt:0];
		//self.subFiles = [NSMutableDictionary dictionary];
		
		DataManager *manager = [[DataManager alloc] initWithFileData:fileData];
		
		int ID = [manager loadInt];
		
		if(ID != 0x9E2A83C1){
			printf("Error File is not a Unreal Package File!!!");
			[manager release];
			[self release];
			self = nil;
			return self;
		}
		
		self.version = [NSNumber numberWithShort:[manager loadShort]];
		
		self.licensee = [NSNumber numberWithShort:[manager loadShort]];
		
		self.flags = [NSNumber numberWithInt:[manager loadInt]];
		
		int nameCount = [manager loadInt];
		
		int nameOffset = [manager loadInt];
		
		int exportCount = [manager loadInt];
		
		int exportOffset = [manager loadInt];
		
		int importCount = [manager loadInt];
		
		int importOffset = [manager loadInt];
		
		if([self.version intValue] < 68){
			int guidCount = [manager loadInt];
			int guidOffset = [manager loadInt];
			manager.curPos = guidOffset;
			for(int i = 0; i < guidCount; i++){
				[self.generations addObject:[UNRGuid guidWithManager:manager]];
			}
		}else{
			[self.generations addObject:[UNRGuid guidWithManager:manager]];
			int generationCount = [manager loadInt];
			for(int i = 0; i < generationCount; i++){
				[self.generations addObject:[UNRGeneration generationWithManager:manager]];
			}
		}
		
		manager.curPos = nameOffset;
		
		for(int i = 0; i < nameCount; i++){
			UNRName *obj = [UNRName nameWithManager:manager version:self.version];
			[self.names addObject:obj];
		}
		
		manager.curPos = exportOffset;
		
		for(int i = 0; i < exportCount; i++){
			UNRExport *obj = [UNRExport exportWithManager:manager];
			[self.objects addObject:obj];
		}
		
		manager.curPos = importOffset;
		
		for(int i = 0; i < importCount; i++){
			UNRImport *obj = [UNRImport importWithManager:manager];
			[self.references addObject:obj];
		}
		
		for(UNRImport *obj in self.references){
			[obj resolveRefrences:self];
		}
		
		for(UNRExport *obj in self.objects){
			[obj resolveRefrences:self];
		}
		
		/*for(UNRExport *obj in self.objects){
		 [obj loadPlugin:self];
		 }*/
		
		[manager release];
		//self.pluginLoader = nil;
		[pool drain];
	}
	return self;
}

- (id)resolveObjectReference:(int)ref{
	if(ref > 0){
		UNRExport *retVal = [self.objects objectAtIndex:ref-1];
		if(retVal.objectData == nil && retVal.loading != YES){
			[retVal loadPlugin:self];
		}
		return retVal;
	}else if(ref < 0){
		return [self.references objectAtIndex:-ref-1];
	}
	return nil;
}

- (NSUInteger)nameCount{
	return [self.names count];
}

- (NSUInteger)objectCount{
	return [self.objects count];
}

- (NSUInteger)referenceCount{
	return [self.references count];
}

+ (int)readCompactIndex:(DataManager *)manager{
	Byte byte1 = [manager loadByte];
	BOOL negative = byte1&0x80;
	BOOL readNext = byte1&0x40;
	int final = byte1&0x3F;
	Byte bytes[4] = {0};
	for(int i = 0; i < 4; i++){
		if(readNext){
			bytes[i] = [manager loadByte];
			readNext = bytes[i]&0x80;
			final |= (bytes[i]&0x7F)<<(6+(i*7));
		}else{
			break;
		}
	}
	return (negative)?final*-1:final;
}

- (void)resolveImportReferences:(NSString *)path{
	NSFileManager *resManager = [[NSFileManager alloc] init];
	NSMutableDictionary *files = [[NSMutableDictionary alloc] init];
	NSDirectoryEnumerator *directEnum = [resManager enumeratorAtPath:path];
	NSString *filePath;
	while((filePath = [directEnum nextObject]) != nil){
		NSString *fileName = [[[filePath lastPathComponent] stringByDeletingPathExtension] lowercaseString];
		[files setValue:filePath forKey:fileName];
	}
	
	[resManager release];
	
	NSMutableDictionary *subFiles = [[NSMutableDictionary alloc] init];
	for(UNRImport *import in self.references){
		if([import.className.string isEqualToString:@"Package"] && import.package == nil){
			NSString *filePath = [files valueForKey:[import.name.string lowercaseString]];
			if(filePath != nil){
				NSData *dat = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:filePath]];
				UNRFile *file = [[UNRFile alloc] initWithFileData:dat pluginsDirectory:nil];
				file.pluginLoader = self.pluginLoader;
				if(file != nil){
					[subFiles setObject:file forKey:import.name.string];
				}
				[file release];
			}
		}
	}
	
	[files release];
	
	for(UNRImport *import in self.references){
		if(![import.className.string isEqualToString:@"Package"]){
			//load the object from the file
			UNRBase *package = import.package;
			while(package.package != nil){
				package = package.package;
			}
			UNRFile *file = [subFiles objectForKey:package.name.string];
			NSArray *objNames = [[file.objects valueForKeyPath:@"name.string"] retain];
			NSArray *classNames = [[file.objects valueForKeyPath:@"classObj.name.string"] retain];
			int index = 0;
			for(int i = 0; i < [objNames count]; i++){
				NSString *name = [objNames objectAtIndex:i];
				NSString *className = [classNames objectAtIndex:i];
				if(name != (NSString *)[NSNull null] && className != (NSString *)[NSNull null]){
					if([[name lowercaseString] isEqualToString:[import.name.string lowercaseString]] && [[className lowercaseString] isEqualToString:[import.className.string lowercaseString]]){
						index = i;
						break;
					}
				}
			}
			[objNames release];
			[classNames release];
			import.obj = [file.objects objectAtIndex:index];
			[import.obj loadPlugin:file];
		}
	}
	[subFiles release];
}

/*- (NSData *)dataFromFile{
 NSMutableData *data = [NSMutableData data];
 
 //write header
 
 for(UNRExport *obj in objects){
 [data appendData:[obj dataFromExport]];
 }
 
 for(UNRImport *obj in references){
 [data appendData:[obj dataFromImport]];
 }
 
 for(UNRName *name in names){
 [data appendData:[name dataFromName]];
 }
 //then do data from the exports object data
 
 return [[data copy] autorelease];
 }
 
 + (NSData *)writeCompactIndex:(int)index{
 NSMutableData *data = [NSMutableData data];
 Byte negative = 0x00;
 if(index < 0){
 negative = 0x80;
 }
 Byte length;
 if(index < pow(2.0f, 6.0f)){ //6 bit
 length = 1;
 }else if(index < pow(2.0f, 13.0f)){ //13 bit
 length = 2;
 }else if(index < pow(2.0f, 20.0f)){ //20 bit
 length = 3;
 }else if(index < pow(2.0f, 27.0f)){//27 bit
 length = 4;
 }else{//35 bit
 length = 5;
 }
 
 Byte *indexData = malloc(sizeof(Byte)*length);
 
 for(int i = 0; i < length; i++){
 Byte loadNext = 0x00;
 if(i+1 < length){
 loadNext = 0x80;
 }
 if(i == 0){
 indexData[i] = negative | (loadNext>>1) | (index&0x3F);
 }else{
 indexData[i] = loadNext | ((index>>(6+7*(i-1)))&0x7F);
 }
 }
 
 [data appendBytes:(const void *)indexData length:length];
 
 return [[data copy] autorelease];
 }*/

- (void)dealloc{
	[names_ release];
	names_ = nil;
	[objects_ release];
	objects_ = nil;
	[references_ release];
	references_ = nil;
	[generations_ release];
	generations_ = nil;
	[version_ release];
	version_ = nil;
	[licensee_ release];
	licensee_ = nil;
	[flags_ release];
	flags_ = nil;
	[pluginLoader_ release];
	pluginLoader_ = nil;
	[super dealloc];
}

@end
