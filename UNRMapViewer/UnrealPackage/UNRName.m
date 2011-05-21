//
//  UNRName.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UNRName.h"


@implementation UNRName

@synthesize flags = flags_, string = string_;

+ (id)nameWithManager:(DataManager *)manager version:(NSNumber *)version{
	UNRName *name = [[[self alloc] init] autorelease];
	if(name != nil){
		NSMutableString *string = [NSMutableString string];
		if([version intValue] >= 64){
			[manager loadByte]; //String length, unused
		}
		BOOL exit = NO;
		while(exit == NO){
			char character = [manager loadByte];
			if(character == 0x00){
				exit = YES;
			}else{			
				[string appendFormat:@"%c", character];
			}
		}
		name.string = string;
		name.flags = [NSNumber numberWithInt:[manager loadInt]];
	}
	return name;
}

- (NSString *)description{
	return [NSString stringWithFormat:@"UNRName: %@", self.string];
}

- (void)dealloc{
	[string_ release];
	string_ = nil;
	[flags_ release];
	flags_ = nil;
	[super dealloc];
}

@end
