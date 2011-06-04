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
#import "Matrix3D.h"

using Matrix::Matrix3D;

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

- (void)draw:(float)aspect{
	//maybe do cool stuff
	static float rotation = 0.0f;
	rotation += 1.0f;
	Matrix3D mat;
	
	Matrix3D projection;
	Matrix3D modelView;
	
	projection.perspective(45.0f, 0.1f, 10000.0f, aspect);
	modelView.uniformScale(0.01f);
	modelView.rotateY(rotation);
	modelView.rotateX(90.0f);
	//modelView.rotateY(45.0f);
	mat = projection * modelView;

	
	[self.rootNode draw:aspect matrix:mat];
}

- (void)dealloc{
	[rootNode_ release];
	rootNode_ = nil;
	[super dealloc];
}

@end
