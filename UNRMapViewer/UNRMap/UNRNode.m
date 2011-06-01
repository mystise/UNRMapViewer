//
//  UNRNode.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRNode.h"
#import "UNRFile.h"
#import "UNRImport.h"
#import "UNRTexture.h"
#import "UNRShader.h"

@implementation UNRNode

@synthesize verts = verts_, vertCount = vertCount_, texCoords = texCoords_, normal = normal_, tex = tex_, plane = plane_, front = front_, back = back_, coPlanar = coPlanar_, surfFlags = surfFlags_, shader = shader_;

- (id)init{
	self = [super init];
	if(self){
		self.plane = [NSDictionary dictionary];
	}
	return self;
}

- (id)initWithModel:(NSMutableDictionary *)model nodeNumber:(int)nodeNum file:(UNRFile *)file map:(UNRMap *)map{
	self = [super init];
	if(self){
		NSMutableArray *vectors = [model valueForKey:@"vectors"];
		NSMutableArray *points = [model valueForKey:@"points"];
		NSMutableArray *verticies = [model valueForKey:@"verts"];
		NSMutableDictionary *node = [[model valueForKey:@"nodes"] objectAtIndex:nodeNum];
		NSMutableDictionary *surf = [[model valueForKey:@"surfs"] objectAtIndex:[[node valueForKey:@"iSurf"] intValue]];
		
		id texture = [file resolveObjectReference:[[surf valueForKey:@"texture"] intValue]];
		if([texture isKindOfClass:[UNRImport class]]){
			UNRImport *tex = texture;
			texture = tex.obj;
		}
		self.tex = [UNRTexture textureWithObject:texture withFile:file];
		
		self.plane = [node valueForKey:@"plane"];
		
		self.surfFlags = [[surf valueForKey:@"polyFlags"] intValue];
		
		vec3 pBase = vec3Create([points objectAtIndex:[[node valueForKey:@"pBase"] intValue]]);
		self.normal = vec3Create([vectors objectAtIndex:[[node valueForKey:@"vNormal"] intValue]]);
		vec3 vTextureU = vec3Create([points objectAtIndex:[[node valueForKey:@"vTextureU"] intValue]]);
		vec3 vTextureV = vec3Create([points objectAtIndex:[[node valueForKey:@"vTextureV"] intValue]]);
		float scaleU = vec3Mag(vTextureU);
		float scaleV = vec3Mag(vTextureV);
		short panU = [[node valueForKey:@"panU"] shortValue];
		short panV = [[node	valueForKey:@"panV"] shortValue];
		
		int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
		self.vertCount = [[node valueForKey:@"vertCount"] intValue];
		self.verts = calloc(self.vertCount, sizeof(vec3));
		self.texCoords = calloc(self.vertCount, sizeof(vec2));
		for(int i = iVertPool; i < self.vertCount+iVertPool; i++){
			vec3 coord = vec3Create([points objectAtIndex:[[[verticies objectAtIndex:i] valueForKey:@"pVertex"] intValue]]);
			self.verts[i-iVertPool] = coord;
			vec3 disp = vec3Sub(coord, pBase);
			vec2 texCoord = {0.0f, 0.0f};
			texCoord.x = (vec3Dot(disp, vTextureU) - panU*scaleU)/self.tex.width;
			texCoord.y = (vec3Dot(disp, vTextureV) - panV*scaleV)/self.tex.height;
		}
		
		int frontInd = [[node valueForKey:@"iFront"] intValue];
		int backInd = [[node valueForKey:@"iBack"] intValue];
		int planeInd = [[node valueForKey:@"iPlane"] intValue];
		if(frontInd != -1){
			UNRNode *front = [[UNRNode alloc] initWithModel:model nodeNumber:frontInd file:file];
			self.front = front;
			[front release];
		}
		if(backInd != -1){
			UNRNode *back = [[UNRNode alloc] initWithModel:model nodeNumber:backInd file:file];
			self.back = back;
			[back release];
		}
		if(planeInd != -1){
			UNRNode *plane = [[UNRNode alloc] initWithModel:model nodeNumber:planeInd file:file];
			self.coPlanar = plane;
			[plane release];
		}
		
		//setup gl-texture
	}
	return self;
}

- (void)draw{
	
	// Validate program before drawing. This is a good check, but only really necessary in a debug build.
	// DEBUG macro must be defined in your debug configurations if that's not already the case.
	/*#if defined(DEBUG)
	 if(![self validateProgram:program]){
	 NSLog(@"Failed to validate program: %d", program);
	 return;
	 }
	 #endif*/
	
	//set gl state
	//draw self and coplanar
	//draw sub-nodes
	if(self.coPlanar){
		[self.coPlanar draw];
	}
	if(self.front){
		[self.front draw];
	}
	if(self.back){
		[self.back draw];
	}
}

- (void)setVerts:(vec3 *)verts{
	if(verts_){
		free(verts_);
		verts_ = NULL;
	}
	verts_ = verts;
}

- (void)setTexCoords:(vec2 *)texCoords{
	if(texCoords_){
		free(texCoords_);
		texCoords_ = nil;
	}
	texCoords_ = texCoords;
}

- (void)dealloc{
	if(verts_){
		free(verts_);
		verts_ = NULL;
	}
	if(texCoords_){
		free(texCoords_);
		texCoords_ = NULL;
	}
	[tex_ release];
	tex_ = nil;
	[plane_ release];
	plane_ = nil;
	[front_ release];
	front_ = nil;
	[back_ release];
	back_ = nil;
	[coPlanar_ release];
	coPlanar_ = nil;
	[shader_ release];
	shader_ = nil;
	[super dealloc];
}

@end
