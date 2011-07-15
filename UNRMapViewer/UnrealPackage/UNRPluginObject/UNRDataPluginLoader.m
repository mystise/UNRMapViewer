//
//  PluginLoader.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 1/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRDataPluginLoader.h"

#import "UNRObject.h"
#import "UNRDataPluginReader.h"

@implementation UNRDataPluginLoader

@synthesize plugins = plugins_, url = url_;

- (id)initWithDirectory:(NSString *)path{
	self = [super init];
	if(self){
		self.plugins = [NSMutableDictionary dictionary];
		
		NSFileManager *manager = [[[NSFileManager alloc] init] autorelease];
		NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:path];
		NSString *filePath;
		while((filePath = [enumerator nextObject]) != nil){
			if([[filePath pathExtension] isEqualToString:@"xml"]){
				self.url = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:filePath]];
				//NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:filePath]];
				NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:self.url];
				parser.delegate = self;
				[parser parse];
				[parser release];
			}
		}
	}
	return self;
}

- (void)loadPlugin:(UNRExport *)object file:(UNRFile *)file{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	UNRDataPluginReader *reader = [[UNRDataPluginReader alloc] init];
	
	id obj = [[UNRObject alloc] initWithFile:file object:object];
	reader.obj = obj;
	[obj release];
	
	reader.plugins = self.plugins;
	
	NSString *className = object.classObj.name.string;
	if(className == nil){
		className = @"Class";
	}
	
	//NSXMLParser *parser = [self.plugins valueForKey:[className lowercaseString]];
	//if(parser == nil){
	//	parser = [self.plugins valueForKey:@"object"];
	//}
	NSURL *url = [self.plugins valueForKey:[className lowercaseString]];
	if(url == nil){
		url = [self.plugins valueForKey:@"object"];
	}
	if(url != nil){
		NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
		parser.delegate = reader;
		[parser parse];
		[parser release];
		
		/*int leftOverData = [reader.obj.manager.fileData length]-reader.obj.manager.curPos;
		 if(leftOverData > 0){
		 [[reader.obj.currentData objectAtIndex:0] setValue:[reader.obj.manager.fileData subdataWithRange:NSMakeRange(reader.obj.manager.curPos, leftOverData)] forKey:@"leftoverData"];
		 }*/
		
		object.objectData = [reader.obj.currentData objectAtIndex:0];
		object.data = nil;
	}
	reader.obj = nil;
	[reader release];
	[pool drain];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)eName namespaceURI:(NSString *)nURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)aDict{
	eName = [eName lowercaseString];
	if([eName isEqualToString:@"plugin"]){
		NSString *className = [aDict valueForKey:@"class"];
		if([self.plugins valueForKey:className] == nil){ //if the plugin is not in the dictionary, add it then stop parsing
			[self.plugins setValue:self.url forKey:className];
			//[self.plugins setValue:parser forKey:className];
			//[parser abortParsing];
		}
	}
}

- (void)dealloc{
	[plugins_ release];
	plugins_ = nil;
	[url_ release];
	url_ = nil;
	[super dealloc];
}

@end
