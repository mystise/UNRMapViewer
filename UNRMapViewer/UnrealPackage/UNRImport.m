//
//  UNRImport.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UNRImport.h"

#import "UNRFile.h"
#import "UNRExport.h"
#import "UNRName.h"

@implementation UNRImport

@synthesize classPackage = classPackage_, className = className_, classPackageRef = classPackageRef_, classNameRef = classNameRef_, obj = obj_;

+ (id)importWithManager:(DataManager *)manager{
	UNRImport *import = [[[self alloc] init] autorelease];
	if(import != nil){
		import.classPackageRef = [UNRFile readCompactIndex:manager];
		import.classNameRef = [UNRFile readCompactIndex:manager];
		import.packageRef = [manager loadInt];
		import.nameRef = [UNRFile readCompactIndex:manager];
	}
	return import;
}

- (NSString *)description{
	return [NSString stringWithFormat:@"<UNRImport: %X %@ %@>", self, self.className.string, self.name.string];
}

- (void)resolveRefrences:(UNRFile *)file{
	[super resolveRefrences:file];
	self.classPackage = [file.names objectAtIndex:self.classPackageRef];
	self.className = [file.names objectAtIndex:self.classNameRef];
}

- (void)dealloc{
	[obj_ release];
	obj_ = nil;
	[classPackage_ release];
	classPackage_ = nil;
	[className_ release];
	className_ = nil;
	[super dealloc];
}

@end
