//
//  UNRBoundingBox.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRBoundingBox.h"


@implementation UNRBoundingBox

@synthesize min = min_, max = max_;

- (id)initWithBox:(NSMutableDictionary *)box{
	self = [super init];
	if(self){
		self.min = Vector3DCreateWithDictionary([box valueForKey:@"min"]);
		self.max = Vector3DCreateWithDictionary([box valueForKey:@"max"]);
	}
	return self;
}

- (CollType)classify:(Matrix3D)frustum{
	
	return C_In;
}

@end
