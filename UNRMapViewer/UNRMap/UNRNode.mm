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
#import "UNRExport.h"

#import "UNRTexture.h"
#import "UNRShader.h"

#import "UNRMap.h"

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
		
		id texture = [surf valueForKey:@"texture"];
		if([texture isKindOfClass:[UNRImport class]]){
			UNRImport *tex = texture;
			texture = tex.obj;
		}
		UNRExport *exp = texture;
		if([map.textures valueForKey:exp.name.string]){
			self.tex = [map.textures valueForKey:exp.name.string];
		}else{
			UNRTexture *tex = [UNRTexture textureWithObject:texture];
			self.tex = tex;
			[map.textures setValue:tex forKey:exp.name.string];
		}
		
		self.plane = [node valueForKey:@"plane"];
		
		self.surfFlags = [[surf valueForKey:@"polyFlags"] intValue];
		if((self.surfFlags & PF_FakeBackdrop) == PF_FakeBackdrop){
			
		}else if((self.surfFlags & PF_Invisible) == PF_Invisible){
			
		}else{
			if([map.shaders valueForKey:@"Texture"]){
				self.shader = [map.shaders valueForKey:@"Texture"];
			}else{
				UNRShader *shad = [[UNRShader alloc] initWithShader:@"Texture"];
				self.shader = shad;
				[map.shaders setValue:shad forKey:@"Texture"];
				[shad release];
				[self.shader addAttribute:@"inTexCoord"];
				[self.shader addAttribute:@"position"];
				
				[self.shader addUniform:@"texture"];
				[self.shader addUniform:@"modelViewProjection"];
			}
		}
		
		if(!(self.surfFlags & PF_Invisible)){
			vec3 pBase = vec3Create([[points objectAtIndex:[[surf valueForKey:@"pBase"] intValue]] valueForKey:@"point"]);
			self.normal = vec3Create([[vectors objectAtIndex:[[surf valueForKey:@"vNormal"] intValue]] valueForKey:@"vector"]);
			vec3 vTextureU = vec3Create([[vectors objectAtIndex:[[surf valueForKey:@"vTextureU"] intValue]] valueForKey:@"vector"]);
			vec3 vTextureV = vec3Create([[vectors objectAtIndex:[[surf valueForKey:@"vTextureV"] intValue]] valueForKey:@"vector"]);
			float scaleU = vec3Mag(vTextureU);
			float scaleV = vec3Mag(vTextureV);
			short panU = [[surf valueForKey:@"panU"] shortValue];
			short panV = [[surf	valueForKey:@"panV"] shortValue];
			
			int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
			self.vertCount = [[node valueForKey:@"vertCount"] intValue];
			self.verts = (vec3 *)calloc(self.vertCount, sizeof(vec3));
			self.texCoords = (vec2 *)calloc(self.vertCount, sizeof(vec2));
			for(int i = iVertPool; i < self.vertCount+iVertPool; i++){
				vec3 coord = vec3Create([[points objectAtIndex:[[[verticies objectAtIndex:i] valueForKey:@"pVertex"] intValue]] valueForKey:@"point"]);
				self.verts[i-iVertPool] = coord;
				vec3 disp = vec3Sub(coord, pBase);
				vec2 texCoord = {0.0f, 0.0f};
				texCoord.x = (vec3Dot(disp, vTextureU) - panU*scaleU)/self.tex.width;
				texCoord.y = (vec3Dot(disp, vTextureV) - panV*scaleV)/self.tex.height;
			}
		}
		int frontInd = [[node valueForKey:@"iFront"] intValue];
		int backInd = [[node valueForKey:@"iBack"] intValue];
		int planeInd = [[node valueForKey:@"iPlane"] intValue];
		if(frontInd != -1){
			UNRNode *front = [[UNRNode alloc] initWithModel:model nodeNumber:frontInd file:file map:map];
			self.front = front;
			[front release];
		}
		if(backInd != -1){
			UNRNode *back = [[UNRNode alloc] initWithModel:model nodeNumber:backInd file:file map:map];
			self.back = back;
			[back release];
		}
		if(planeInd != -1){
			UNRNode *plane = [[UNRNode alloc] initWithModel:model nodeNumber:planeInd file:file map:map];
			self.coPlanar = plane;
			[plane release];
		}
	}
	return self;
}

- (void)draw:(float)aspect matrix:(Matrix3D &)mat{
	
	[self.shader use];
	BOOL draw = YES;
	if((self.surfFlags & PF_FakeBackdrop) == PF_FakeBackdrop){
		//draw cubemap, do other stuff, bind to cube-map, draw self
		draw = NO;
		//draw = YES, but not now; :)
	}else if((self.surfFlags & PF_Invisible) == PF_Invisible){
		draw = NO;
	}else{
		GLuint position = [self.shader attribLocation:@"position"];
		GLuint inTexCoord = [self.shader attribLocation:@"inTexCoord"];
		glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, 0, self.verts);
		glEnableVertexAttribArray(position);
		glVertexAttribPointer(inTexCoord, 2, GL_FLOAT, GL_FALSE, 0, self.texCoords);
		glEnableVertexAttribArray(inTexCoord);
		
		GLuint texture = [self.shader uniformLocation:@"texture"];
		[self.tex bind:0];
		glUniform1i(texture, 0);
		
		GLuint matrix = [self.shader uniformLocation:@"modelViewProjection"];
		glUniformMatrix4fv(matrix, 1, GL_FALSE, mat.glData());
	}
	
	if(draw){
		// Validate program before drawing. This is a good check, but only really necessary in a debug build.
		// DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
		if(![self.shader validate]){
			NSLog(@"Failed to validate program: %d", self.shader.program);
			return;
		}
#endif
		glDrawArrays(GL_TRIANGLE_FAN, 0, self.vertCount);
	}
	
	if(self.coPlanar){
		[self.coPlanar draw:aspect matrix:mat];
	}
	if(self.front){
		[self.front draw:aspect matrix:mat];
	}
	if(self.back){
		[self.back draw:aspect matrix:mat];
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
