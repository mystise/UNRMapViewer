//
//  UNRGeneration.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRGeneration.h"


@implementation UNRGeneration

@synthesize objectCount=objectCount_, nameCount=nameCount_;

+ (id)generationWithManager:(DataManager *)manager{
	UNRGeneration *generation = [[[self alloc] init] autorelease];
	if(generation){
		generation.objectCount = [manager loadInt];
		generation.nameCount = [manager loadInt];
	}
	return generation;
}

@end
