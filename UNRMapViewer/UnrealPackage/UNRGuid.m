//
//  UNRGuid.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 1/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRGuid.h"


@implementation UNRGuid

@synthesize guid=guid_;

- (id)init{
	self = [super init];
	if(self){
		self.guid = malloc(sizeof(Byte)*16);
	}
	return self;
}

+ (id)guidWithManager:(DataManager *)manager{
	UNRGuid *guid = [[[self alloc] init] autorelease];
	if(guid){
		for(int i = 0; i < 16; i++){
			guid.guid[i] = [manager loadByte];
		}
	}
	return guid;
}

- (NSString *)description{
	return [NSString stringWithFormat:@"%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X"
			, self.guid[0], self.guid[1], self.guid[2], self.guid[3]
			, self.guid[4], self.guid[5], self.guid[6], self.guid[7]
			, self.guid[8], self.guid[9], self.guid[10], self.guid[11]
			, self.guid[12], self.guid[13], self.guid[14], self.guid[15]];
}

- (void)dealloc{
	free(guid_);
	guid_ = NULL;
	[super dealloc];
}

@end
