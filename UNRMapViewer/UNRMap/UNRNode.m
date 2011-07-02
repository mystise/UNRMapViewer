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
#import "UNRZone.h"

#import "UNRMap.h"

enum{
	CLASS_NoClass = -1,
	CLASS_Front,
	CLASS_Back
};

@implementation UNRNode

@synthesize vbo = vbo_, vao = vao_, vertCount = vertCount_, strideLength = strideLength_, shader = shader_;
@synthesize tex = tex_, lightMap = lightMap_, surfFlags = surfFlags_;
@synthesize front = front_, back = back_, coPlanar = coPlanar_;
@synthesize normal = normal_, origin = origin_, plane = plane_;
@synthesize frontZone = frontZone_, backZone = backZone_;

- (id)init{
	self = [super init];
	if(self){
		
	}
	return self;
}

- (id)initWithModel:(NSMutableDictionary *)model nodeNumber:(int)nodeNum file:(UNRFile *)file map:(UNRMap *)map{
	self = [super init];
	if(self){
		NSMutableArray *vectors = [[model valueForKey:@"vectors"] valueForKey:@"vector"];
		NSMutableArray *points = [[model valueForKey:@"points"] valueForKey:@"point"];
		NSMutableArray *verticies = [model valueForKey:@"verts"];
		NSMutableDictionary *node = [[model valueForKey:@"nodes"] objectAtIndex:nodeNum];
		NSMutableDictionary *surf = [[model valueForKey:@"surfs"] objectAtIndex:[[node valueForKey:@"iSurf"] intValue]];
		self.surfFlags = [[surf valueForKey:@"polyFlags"] intValue];
		self.normal = Vector3DCreateWithDictionary([vectors objectAtIndex:[[surf valueForKey:@"vNormal"] intValue]]);
		self.plane = Vector4DCreateWithDictionary([node valueForKey:@"plane"]);
		
		if((self.surfFlags & PF_Invisible) != PF_Invisible){
			{
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
			}
			
			int lightIndex = [[surf valueForKey:@"iLightMap"] intValue];
			NSMutableDictionary *lightMap = nil;
			if(lightIndex != -1){
				lightMap = [[model valueForKey:@"lightMaps"] objectAtIndex:lightIndex];
				NSMutableData *lightData = [model valueForKey:@"LightBits"];
				if([map.lightMaps valueForKey:[NSString stringWithFormat:@"%i", lightIndex]] == nil){
					UNRTexture *lighting = [UNRTexture textureWithLightMap:lightMap data:lightData lights:[[model valueForKey:@"lights"] valueForKey:@"light"] node:self];
					[map.lightMaps setValue:lighting forKey:[NSString stringWithFormat:@"%i", lightIndex]];
					self.lightMap = lighting;
				}else{
					self.lightMap = [map.lightMaps valueForKey:[NSString stringWithFormat:@"%i", lightIndex]];
				}
			}
			
			if((self.surfFlags & PF_FakeBackdrop) == PF_FakeBackdrop){
				if([map.shaders valueForKey:@"SkyBox"]){
					self.shader = [map.shaders valueForKey:@"SkyBox"];
				}else{
					UNRShader *shad = [[UNRShader alloc] initWithShader:@"SkyBox"];
					self.shader = shad;
					[map.shaders setValue:shad forKey:@"SkyBox"];
					[shad release];
				}
			}else{
				if([map.shaders valueForKey:@"Texture"]){
					self.shader = [map.shaders valueForKey:@"Texture"];
				}else{
					UNRShader *shad = [[UNRShader alloc] initWithShader:@"Texture"];
					self.shader = shad;
					[map.shaders setValue:shad forKey:@"Texture"];
					[shad release];
				}
			}
			
			GLuint vbo;
			glGenBuffers(1, &vbo);
			self.vbo = vbo;
			glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
			
			if((self.surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
				self.strideLength = 7;
				
				self.origin = Vector3DCreateWithDictionary([points objectAtIndex:[[surf valueForKey:@"pBase"] intValue]]);
				Vector3D vTextureU = Vector3DCreateWithDictionary([vectors objectAtIndex:[[surf valueForKey:@"vTextureU"] intValue]]);
				Vector3D vTextureV = Vector3DCreateWithDictionary([vectors objectAtIndex:[[surf valueForKey:@"vTextureV"] intValue]]);
				short panU = [[surf valueForKey:@"panU"] shortValue];
				short panV = [[surf	valueForKey:@"panV"] shortValue];
				
				Vector3D lightPan = Vector3DCreateWithDictionary([lightMap valueForKey:@"pan"]);
				float lightUScale = [[lightMap valueForKey:@"uScale"] floatValue];
				float lightVScale = [[lightMap valueForKey:@"vScale"] floatValue];
				
				//lightmap panbias = -0.5
				//Tex.UPan      = Info.Pan.X + PanBias*Info.UScale;
				//Tex.VPan      = Info.Pan.Y + PanBias*Info.VScale;
				
				int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
				int vertCount = [[node valueForKey:@"vertCount"] intValue];
				GLfloat *coordinates = (GLfloat *)calloc(vertCount*self.strideLength, sizeof(GLfloat));
				self.vertCount = vertCount;
				int index = 0;
				for(int i = 0; i < vertCount; i++){
					Vector3D coord = Vector3DCreateWithDictionary([points objectAtIndex:[[[verticies objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue]]);
					Vector3D disp = Vector3DSubtract(coord, self.origin);
					
					Vector2D texCoord = {0.0f, 0.0f};
					texCoord.x = (Vector3DDot(disp, vTextureU) + panU)/self.tex.width;
					texCoord.y = (Vector3DDot(disp, vTextureV) + panV)/self.tex.height;
					
					Vector2D lightCoord = {0.0f, 0.0f};
					lightCoord.x = (Vector3DDot(disp, vTextureU) - (lightPan.x + (-0.5f*lightUScale)))/(lightUScale*self.lightMap.width);
					lightCoord.y = (Vector3DDot(disp, vTextureV) - (lightPan.y + (-0.5f*lightVScale)))/(lightVScale*self.lightMap.height);
					
					coordinates[index]   = coord.x;
					coordinates[index+1] = coord.y;
					coordinates[index+2] = coord.z;
					coordinates[index+3] = texCoord.x;
					coordinates[index+4] = texCoord.y;
					coordinates[index+5] = lightCoord.x;
					coordinates[index+6] = lightCoord.y;
					index += self.strideLength;
				}
				
				glBufferData(GL_ARRAY_BUFFER, vertCount*sizeof(GLfloat)*self.strideLength, coordinates, GL_STATIC_DRAW);
				
				free(coordinates);
			}else{
				self.strideLength = 3;
				
				int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
				int vertCount = [[node valueForKey:@"vertCount"] intValue];
				GLfloat *coordinates = (GLfloat *)calloc(vertCount*self.strideLength, sizeof(GLfloat));
				self.vertCount = vertCount;
				int index = 0;
				for(int i = 0; i < vertCount; i++){
					Vector3D coord = Vector3DCreateWithDictionary([points objectAtIndex:[[[verticies objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue]]);
					
					coordinates[index]   = coord.x;
					coordinates[index+1] = coord.y;
					coordinates[index+2] = coord.z;
					index += self.strideLength;
				}
				
				glBufferData(GL_ARRAY_BUFFER, vertCount*sizeof(GLfloat)*self.strideLength, coordinates, GL_STATIC_DRAW);
				
				free(coordinates);
			}
			
			GLuint vao = 0;
			glGenVertexArraysOES(1, &vao);
			self.vao = vao;
			glBindVertexArrayOES(self.vao);
			
			glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
			
			[self.shader use];
			
			GLuint position = [self.shader attribLocation:@"position"];
			glEnableVertexAttribArray(position);
			glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, self.strideLength*sizeof(GLfloat), NULL);
			
			if((self.surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
				[self.tex bind:0];
				[self.lightMap bind:1];
				
				GLuint inTexCoord = [self.shader attribLocation:@"inTexCoord"];
				GLuint inLightCoord = [self.shader attribLocation:@"inLightCoord"];
				GLuint texture = [self.shader uniformLocation:@"texture"];
				GLuint lightmap = [self.shader uniformLocation:@"lightmap"];
				
				glUniform1i(texture, 0);
				glUniform1i(lightmap, 1);
				glEnableVertexAttribArray(inTexCoord);
				glEnableVertexAttribArray(inLightCoord);
				glVertexAttribPointer(inTexCoord, 2, GL_FLOAT, GL_FALSE, self.strideLength*sizeof(GLfloat), (void *)(3*sizeof(GLfloat)));
				glVertexAttribPointer(inLightCoord, 2, GL_FLOAT, GL_FALSE, self.strideLength*sizeof(GLfloat), (void *)(5*sizeof(GLfloat)));
			}
		}
		
		int frontZoneIndex = [[node valueForKey:@"iZone2"] intValue];
		int backZoneIndex = [[node valueForKey:@"iZone1"] intValue];
		
		if([map.zones valueForKey:[NSString stringWithFormat:@"%i", frontZoneIndex]] == nil){
			UNRZone *frontZone = [[UNRZone alloc] initWithZone:[[model valueForKey:@"zones"] objectAtIndex:frontZoneIndex] index:frontZoneIndex];
			self.frontZone = frontZone;
			[frontZone release];
		}else{
			self.frontZone = [map.zones valueForKey:[NSString stringWithFormat:@"%i", frontZoneIndex]];
		}
		
		if([map.zones valueForKey:[NSString stringWithFormat:@"%i", backZoneIndex]] == nil){
			UNRZone *backZone = [[UNRZone alloc] initWithZone:[[model valueForKey:@"zones"] objectAtIndex:backZoneIndex] index:backZoneIndex];
			self.backZone = backZone;
			[backZone release];
		}else{
			self.backZone = [map.zones valueForKey:[NSString stringWithFormat:@"%i", backZoneIndex]];
		}
		
		int frontInd = [[node valueForKey:@"iFront"] intValue];
		int backInd = [[node valueForKey:@"iBack"] intValue];
		int planeInd = [[node valueForKey:@"iPlane"] intValue];
		
		if(planeInd != -1){
			UNRNode *plane = [[UNRNode alloc] initWithModel:model nodeNumber:planeInd file:file map:map];
			self.coPlanar = plane;
			[plane release];
		}
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
	}
	return self;
}

- (void)drawWithMatrix:(Matrix3D)mat camPos:(Vector3D)camPos{
	NSMutableDictionary *state = [NSMutableDictionary dictionary];
	
	GLuint matrix = [self.shader uniformLocation:@"modelViewProjection"];
	glUniformMatrix4fv(matrix, 1, GL_FALSE, mat);
	[state setValue:[NSNumber numberWithUnsignedInt:(unsigned int)mat] forKey:@"matrix"];
	
	//[state setValue:[NSNumber numberWithUnsignedInt:(unsigned int)&vec] forKey:@"camPos"];
	
	//[state setValue:[NSNumber numberWithUnsignedInt:(unsigned int)&viewVec] forKey:@"viewVec"];
	
	[state setValue:[self zoneForCamera:camPos] forKey:@"zone"];
	
	[self drawWithState:state];
}

- (void)drawWithState:(NSMutableDictionary *)state{
	/*#if defined(DEBUG)
	 if(![self.shader validate]){
	 NSLog(@"Failed to validate program: %d", self.shader.program);
	 return;
	 }
	 #endif*/
	
	//TODO: only draw the node and it's sub nodes if it is visible from the camera position
	//frustum cull, and visibility test
	
	//visibility test each subNode, back and front, not coplaner, and only draw them if they are visible.
	//frustum cull each node in the visible space
	if((self.surfFlags & PF_Invisible) != PF_Invisible){
		glBindVertexArrayOES(self.vao);
		
		GLuint matrix = [self.shader uniformLocation:@"modelViewProjection"];
		float *mat = (float *)[[state valueForKey:@"matrix"] unsignedIntValue];
		glUniformMatrix4fv(matrix, 1, GL_FALSE, mat);
		[state setValue:[NSNumber numberWithUnsignedInt:(unsigned int)mat] forKey:@"matrix"];
		
		[self.shader use];
		
		if((self.surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
			if([[state valueForKey:@"texture"] unsignedIntValue] != self.tex.glTex){
				[self.tex bind:0];
				[state setValue:[NSNumber numberWithUnsignedInt:self.tex.glTex] forKey:@"texture"];
			}
			
			if([[state valueForKey:@"lightMap"] unsignedIntValue] != self.lightMap.glTex){
				[self.lightMap bind:1];
				[state setValue:[NSNumber numberWithUnsignedInt:self.lightMap.glTex] forKey:@"lightMap"];
			}
		}else{
			glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
			//TODO: find a way to draw the skybox with depth testing on.
			//glDepthMask(GL_FALSE);
		}
		glDrawArrays(GL_TRIANGLE_FAN, 0, self.vertCount);
		
		if((self.surfFlags & PF_FakeBackdrop) == PF_FakeBackdrop){
			glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
			//glDepthMask(GL_TRUE);
		}
	}
	
	if(self.coPlanar){
		[self.coPlanar drawWithState:state];
	}
	
	//UNRZone *zone = [state valueForKey:@"zone"];
	//if([zone isZoneVisible:self.frontZone]){
		if(self.front){
			[self.front drawWithState:state];
		}
	//}
	//if([zone isZoneVisible:self.backZone]){
		if(self.back){
			[self.back drawWithState:state];
		}
	//}
}

- (UNRZone *)zoneForCamera:(Vector3D)camPos{
	float dot = Vector4DDistance(self.plane, camPos);
	const float tolerance = 0.01f;
	
	if(dot > tolerance){
		UNRZone *frontZone = [self.front zoneForCamera:camPos];
		if(frontZone != nil){
			return frontZone;
		}else{
			return self.frontZone;
		}
	}else if(dot < -tolerance){
		UNRZone *backZone = [self.back zoneForCamera:camPos];
		if(backZone != nil){
			return backZone;
		}else{
			return self.backZone;
		}
	}
	return self.frontZone;
}

- (void)dealloc{
	if(vbo_){
		glDeleteBuffers(1, &vbo_);
		vbo_ = 0;
	}
	if(vao_){
		glDeleteVertexArraysOES(1, &vao_);
		vao_ = 0;
	}
	[tex_ release];
	tex_ = nil;
	[lightMap_ release];
	lightMap_ = nil;
	[front_ release];
	front_ = nil;
	[back_ release];
	back_ = nil;
	[coPlanar_ release];
	coPlanar_ = nil;
	[shader_ release];
	shader_ = nil;
	[backZone_ release];
	backZone_ = nil;
	[frontZone_ release];
	frontZone_ = nil;
	
	[super dealloc];
}

@end
