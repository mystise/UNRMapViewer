//
//  PluginLoader.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 1/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRDataPluginLoader.h"

#import "UNRObject.h"

@implementation UNRDataPluginLoader

@synthesize plugins = plugins_, addData = addData_, obj = obj_, dataTypes = dataTypes_, dataEndTypes = dataEndTypes_, url = url_;

- (id)initWithDirectory:(NSString *)path{
	if(self = [super init]){
		self.plugins = [NSMutableDictionary dictionary];
		
		NSFileManager *manager = [[[NSFileManager alloc] init] autorelease];
		NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:path];
		NSString *filePath;
		while(filePath = [enumerator nextObject]){
			if([[filePath pathExtension] isEqualToString:@"xml"]){
				self.url = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:filePath]];
				//NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:filePath]];
				NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:self.url];
				parser.delegate = self;
				[parser parse];
				[parser release];
			}
		}
		
		self.addData = NO;
		self.dataTypes = [NSDictionary dictionaryWithObjectsAndKeys:
					 @"addByteWithAttributes:",				@"byte",
					 @"addShortWithAttributes:",			@"short",
					 @"addIntWithAttributes:",				@"int",
					 @"addLongWithAttributes:",				@"long",
					 @"addFloatWithAttributes:",			@"float",
					 @"addCompactIndexWithAttributes:",		@"compactindex",
					 @"addPropertiesWithAttributes:",		@"properties",
					 @"addStringWithAttributes:",			@"string",
					 @"addDataWithAttributes:",				@"data",
					 @"addObjectReferenceWithAttributes:",	@"objectreference",
					 @"addNameReferenceWithAttributes:",	@"namereference",
					 @"beginArrayWithAttributes:",			@"array",
					 @"beginConditionalWithAttributes:",	@"if",
					 @"addVectorWithAttributes:",			@"vector",
					 @"addIntVectorWithAttributes:",		@"intvector",
					 @"addPlaneWithAttributes:",			@"plane",
					 @"addBoxWithAttributes:",				@"box",
					 @"addSphereWithAttributes:",			@"sphere",
					 @"addRotatorWithAttributes:",			@"rotator",
					 nil];
		
		self.dataEndTypes = [NSDictionary dictionaryWithObjectsAndKeys:
						@"endArrayWithAttributes:",			@"array",
						@"endConditionalWithAttributes:",	@"if",
						nil];
	}
	return self;
}

- (void)loadPlugin:(UNRExport *)object file:(UNRFile *)file{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	self.addData = NO;
	
	id obj = [[UNRObject alloc] initWithFile:file object:object];
	self.obj = obj;
	[obj release];
	
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
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	parser.delegate = self;
	[parser parse];
	[parser release];
	
	int leftOverData = [self.obj.manager.fileData length]-self.obj.manager.curPos;
	if(leftOverData > 0){
		[[self.obj.currentData objectAtIndex:0] setValue:[self.obj.manager.fileData subdataWithRange:NSMakeRange(self.obj.manager.curPos, leftOverData)] forKey:@"leftoverData"];
	}
	
	object.objectData = [self.obj.currentData objectAtIndex:0];
	self.obj = nil;
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
		}else{
			NSString *superClassName = [aDict valueForKey:@"super"];
			if(superClassName != nil){
				//NSXMLParser *superParser = [self.plugins valueForKey:superClassName];
				NSXMLParser *superParser = [[NSXMLParser alloc] initWithContentsOfURL:[self.plugins valueForKey:superClassName]];
				superParser.delegate = self;
				[superParser parse];
				[superParser release];
			}
		}
	}else if([eName isEqualToString:@"info"]){
		self.addData = YES;
	}else if(self.addData){
		NSString *methodName = [self.dataTypes valueForKey:eName];
		if(methodName){
			SEL method = NSSelectorFromString(methodName);
			[self.obj performSelector:method withObject:aDict];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)eName namespaceURI:(NSString *)nURI qualifiedName:(NSString *)qName{
	if([eName isEqualToString:@"info"]){
		self.addData = NO;
	}else if(self.addData){
		NSString *methodName = [self.dataEndTypes valueForKey:[eName lowercaseString]];
		if(methodName){
			SEL method = NSSelectorFromString(methodName);
			[self.obj performSelector:method withObject:nil];
		}
	}
}

- (void)dealloc{
	[plugins_ release];
	plugins_ = nil;
	[obj_ release];
	obj_ = nil;
	[dataTypes_ release];
	dataTypes_ = nil;
	[dataEndTypes_ release];
	dataEndTypes_ = nil;
	[url_ release];
	url_ = nil;
	[super dealloc];
}

@end
