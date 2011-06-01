//
//  UNRMap.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRMap.h"

#import "UNRFile.h"
#import "UNRTexture.h"
#import "UNRNode.h"
#import "Utilities.h"

@implementation UNRMap

@synthesize rootNode = rootNode_, textures = textures_, shaders = shaders_;

- (id)initWithModel:(NSMutableDictionary *)model andFile:(UNRFile *)file{
	self = [super init];
	if(self != nil){
		self.textures = [NSMutableDictionary dictionary];
		self.shaders = [NSMutableDictionary dictionary];
		UNRNode *node = [[UNRNode alloc] initWithModel:model nodeNumber:0 file:file map:self];
		self.rootNode = node;
		[node release];
	}
	return self;
}

- (void)draw{
	//maybe do cool stuff
	[self.rootNode draw];
}

- (void)dealloc{
	[rootNode_ release];
	rootNode_ = nil;
	[super dealloc];
}

@end
