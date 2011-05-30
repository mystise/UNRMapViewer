//
//  UNRNode.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRNode.h"
#import "UNRFile.h"

@implementation UNRNode

@synthesize verts = verts_, normal = normal_, plane = plane_, front = front_, back = back_, coPlanar = coPlanar_;

- (id)init{
	self = [super init];
	if(self){
		self.verts = [NSArray array];
		self.normal = [NSDictionary dictionary];
		self.plane = [NSDictionary dictionary];
	}
	return self;
}

- (id)initWithModel:(NSMutableDictionary *)model nodeNumber:(int)nodeNum file:(UNRFile *)file{
	self = [super init];
	if(self){
		self.verts = [NSArray array];
		self.normal = [NSDictionary dictionary];
		self.plane = [NSDictionary dictionary];
		NSMutableDictionary *node = [[model valueForKey:@"nodes"] objectAtIndex:nodeNum];
		NSMutableDictionary *surf = [[model valueForKey:@"surfs"] objectAtIndex:[[node valueForKey:@"iSurf"] intValue]];
		id texture = [file resolveObjectReference:[[surf valueForKey:@"texture"] intValue]];
		//read the model node at nodeNum
		//load all the data associated with the node
		//get it into an easily accessible form (for drawing)
		//allocate and prepare all sub nodes
	}
	return self;
}

- (void)dealloc{
	[verts_ release];
	verts_ = nil;
	[normal_ release];
	normal_ = nil;
	[plane_ release];
	plane_ = nil;
	[front_ release];
	front_ = nil;
	[back_ release];
	back_ = nil;
	[coPlanar_ release];
	coPlanar_ = nil;
	[super dealloc];
}

@end
