//
//  UNRDataPluginReader.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRDataPluginReader.h"

@implementation UNRDataPluginReader

@synthesize addData = addData_, dataTypes = dataTypes_, dataEndTypes = dataEndTypes_, obj = obj_, plugins = plugins_;

- (id)init{
    self = [super init];
    if(self){
		self.addData = NO;
		self.dataTypes = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"addByteWithAttributes:",			@"byte",
						  @"addShortWithAttributes:",			@"short",
						  @"addIntWithAttributes:",				@"int",
						  @"addLongWithAttributes:",			@"long",
						  @"addFloatWithAttributes:",			@"float",
						  @"addCompactIndexWithAttributes:",	@"compactindex",
						  @"addPropertiesWithAttributes:",		@"properties",
						  @"addStringWithAttributes:",			@"string",
						  @"addDataWithAttributes:",			@"data",
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
							 @"endArrayWithAttributes:",		@"array",
							 @"endConditionalWithAttributes:",	@"if",
							 nil];
    }
    
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)eName namespaceURI:(NSString *)nURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)aDict{
	eName = [eName lowercaseString];
	if([eName isEqualToString:@"plugin"]){
		NSString *superClassName = [aDict valueForKey:@"super"];
		if(superClassName != nil){
			//NSXMLParser *superParser = [self.plugins valueForKey:superClassName];
			NSXMLParser *superParser = [[NSXMLParser alloc] initWithContentsOfURL:[self.plugins valueForKey:superClassName]];
			superParser.delegate = self;
			[superParser parse];
			[superParser release];
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
	[obj_ release];
	obj_ = nil;
	[plugins_ release];
	plugins_ = nil;
	[dataTypes_ release];
	dataTypes_ = nil;
	[dataEndTypes_ release];
	dataEndTypes_ = nil;
    [super dealloc];
}

@end
