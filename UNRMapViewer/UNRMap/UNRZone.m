//
//  UNRZone.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRZone.h"

@implementation UNRZone

@synthesize zoneIndex = zoneIndex_, visibility = visibility_, connectivity = connectivity_;

- (id)initWithZone:(NSMutableDictionary *)zone index:(int)zoneIndex{
	self = [super init];
	if(self){
		self.zoneIndex = zoneIndex;
		//self.visibility = [[zone valueForKey:@"visibility"] longLongValue];
		self.visibility = [[zone valueForKey:@"connectivity"] longLongValue];
		self.connectivity = [[zone valueForKey:@"connectivity"] longLongValue];
	}
	return self;
}

- (BOOL)isZoneVisible:(UNRZone *)zone{
	return (self.visibility & (1<<zone.zoneIndex))!=0;
}

- (BOOL)isVisibleFromZone:(UNRZone *)zone{
	return (zone.visibility & (1<<self.zoneIndex))!=0;
}

- (NSString *)description{
	return [NSString stringWithFormat:@"<UNRZone:%i Connect:%x>", self.zoneIndex, self.connectivity];
}

@end