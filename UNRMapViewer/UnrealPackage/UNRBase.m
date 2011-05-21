//
//  UNRBase.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UNRBase.h"

#import "UNRFile.h"
#import "UNRName.h"

@implementation UNRBase

@synthesize package = package_, name = name_, subObjects = subObjects_, packageRef = packageRef_, nameRef = nameRef_;

- (id)init{
	self = [super init];
	if(self != nil){
		self.subObjects = [NSMutableArray array];
	}
	return self;
}

- (void)resolveRefrences:(UNRFile *)file{
	self.package = [file resolveObjectReference:self.packageRef];
	self.name = [file.names objectAtIndex:self.nameRef];
}

- (NSUInteger)subObjectsCount{
	return [self.subObjects count];
}

- (void)dealloc{
	//[package_ release];
	//package_ = nil;
	[name_ release];
	name_ = nil;
	[subObjects_ release];
	subObjects_ = nil;
	[super dealloc];
}

@end
