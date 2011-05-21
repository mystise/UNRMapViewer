//
//  UNRExport.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UNRExport.h"

#import "UNRFile.h"
#import "UNRName.h"
#import "UNRDataPluginLoader.h"

@implementation UNRExport

@synthesize classObj = classObj_, superObj = superObj_, flags = flags_, data = data_, objectData = objectData_, classObjRef = classObjRef_, superObjRef = superObjRef_;

+ (id)exportWithManager:(DataManager *)manager{
	UNRExport *export = [[[self alloc] init] autorelease];
	if(export != nil){
		export.classObjRef = [UNRFile readCompactIndex:manager];
		export.superObjRef = [UNRFile readCompactIndex:manager];
		export.packageRef = [manager loadInt];
		export.nameRef = [UNRFile readCompactIndex:manager];
		export.flags = [NSNumber numberWithInt:[manager loadInt]];
		int fileSize = [UNRFile readCompactIndex:manager];
		
		if(fileSize > 0){
			int fileOffset = [UNRFile readCompactIndex:manager];
			export.data = [manager.fileData subdataWithRange:NSMakeRange(fileOffset, fileSize)];
		}
		export.objectData = nil;
	}
	return export;
}

- (NSString *)description{
	return [NSString stringWithFormat:@"UNRExport: %@", self.name.string];
}

- (void)resolveRefrences:(UNRFile *)file{
	[super resolveRefrences:file];
	self.classObj = [file resolveObjectReference:self.classObjRef];
	self.superObj = [file resolveObjectReference:self.superObjRef];
}

- (void)loadPlugin:(UNRFile *)file{
	if(self.data && !self.objectData){
		[file.pluginLoader loadPlugin:self file:file];
	}
}

- (void)dealloc{
	[classObj_ release];
	classObj_ = nil;
	[superObj_ release];
	superObj_ = nil;
	[flags_ release];
	flags_ = nil;
	[data_ release];
	data_ = nil;
	[objectData_ release];
	objectData_ = nil;
	[super dealloc];
}

@end
