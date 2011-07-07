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
#import "UNRBoundingBox.h"

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
//@synthesize frontZone = frontZone_, backZone = backZone_;
@synthesize renderBox = renderBox_;

- (id)initWithModel:(NSMutableDictionary *)model attributes:(NSMutableDictionary *)attrib{//nodeNumber:(int)nodeNum file:(UNRFile *)file map:(UNRMap *)map
	self = [super init];
	if(self){
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		UNRMap *map = [attrib valueForKey:@"map"];
		NSMutableArray *vectors = [attrib valueForKey:@"vectors"];
		NSMutableArray *points = [attrib valueForKey:@"points"];
		NSMutableArray *verticies = [attrib valueForKey:@"verts"];
		NSMutableArray *lights = [attrib valueForKey:@"lights"];
		NSMutableDictionary *node = [[model valueForKey:@"nodes"] objectAtIndex:[[attrib valueForKey:@"iNode"] intValue]];
		NSMutableDictionary *surf = [[model valueForKey:@"surfs"] objectAtIndex:[[node valueForKey:@"iSurf"] intValue]];
		
//		printf("\nLoading node:%i\n", [[attrib valueForKey:@"iNode"] intValue]);
		
		self.surfFlags = [[surf valueForKey:@"polyFlags"] intValue];
		if(!(self.surfFlags & PF_NoOcclude)){
			self.surfFlags |= PF_Occlude;
		}
		
		self.origin = Vector3DCreateWithDictionary([points objectAtIndex:[[surf valueForKey:@"pBase"] intValue]]);
		
		self.normal = Vector3DCreateWithDictionary([vectors objectAtIndex:[[surf valueForKey:@"vNormal"] intValue]]);
		self.plane = Vector4DCreateWithDictionary([node valueForKey:@"plane"]);
		int renderIndex = [[node valueForKey:@"iRenderBound"] intValue];
		if(renderIndex != -1){
			UNRBoundingBox *renderBox = [[UNRBoundingBox alloc] initWithBox:[[[model valueForKey:@"bounds"] objectAtIndex:renderIndex] valueForKey:@"bound"]];
			self.renderBox = renderBox;
			[renderBox release];
		}
		
//		printf("\tDone loading Box\n");
		
		if((self.surfFlags & PF_Invisible) != PF_Invisible){
			{
				id texture = [surf valueForKey:@"texture"];
				UNRExport *exp = texture;
				if([exp isKindOfClass:[UNRImport class]]){
					UNRImport *tex = (UNRImport *)exp;
					exp = tex.obj;
				}
				if(exp != nil){
					if([map.textures valueForKey:exp.name.string]){
						self.tex = [map.textures valueForKey:exp.name.string];
					}else{
						UNRTexture *tex = [UNRTexture textureWithObject:exp.objectData attributes:[NSDictionary dictionaryWithObjectsAndKeys:
																								   [NSNumber numberWithBool:((self.surfFlags & PF_Masked) == PF_Masked)], @"masked",
																								   [NSNumber numberWithInt:0], @"startMip",
																								   [NSNumber numberWithBool:((self.surfFlags & PF_NoSmooth) != 0)], @"noSmooth",
																								   nil]];
						self.tex = tex;
						[map.textures setValue:tex forKey:exp.name.string];
					}
				}
			}
//			printf("\tDone loading Texture\n");
			
			int lightIndex = [[surf valueForKey:@"iLightMap"] intValue];
			NSMutableDictionary *lightMap = nil;
			if(lightIndex != -1){
				lightMap = [[model valueForKey:@"lightMaps"] objectAtIndex:lightIndex];
			}
			if([map.lightMaps valueForKey:[NSString stringWithFormat:@"%i", lightIndex]] == nil){
				NSMutableData *lightData = [model valueForKey:@"LightBits"];
				UNRTexture *lighting = [UNRTexture textureWithLightMap:lightMap data:lightData lights:lights node:self];
				[map.lightMaps setValue:lighting forKey:[NSString stringWithFormat:@"%i", lightIndex]];
				self.lightMap = lighting;
			}else{
				self.lightMap = [map.lightMaps valueForKey:[NSString stringWithFormat:@"%i", lightIndex]];
			}
			
//			printf("\tDone loading LightMap\n");
			
			/*if((self.surfFlags & PF_FakeBackdrop) == PF_FakeBackdrop){
			 if([map.shaders valueForKey:@"SkyBox"]){
			 self.shader = [map.shaders valueForKey:@"SkyBox"];
			 }else{
			 UNRShader *shad = [[UNRShader alloc] initWithShader:@"SkyBox"];
			 self.shader = shad;
			 [map.shaders setValue:shad forKey:@"SkyBox"];
			 [shad release];
			 }
			 }else{*/
			if([map.shaders valueForKey:@"Texture"]){
				self.shader = [map.shaders valueForKey:@"Texture"];
			}else{
				UNRShader *shad = [[UNRShader alloc] initWithShader:@"Texture"];
				self.shader = shad;
				[map.shaders setValue:shad forKey:@"Texture"];
				[shad release];
			}
			//}
			
//			printf("\tDone loading Shader\n");
			
			GLuint vbo;
			glGenBuffers(1, &vbo);
			self.vbo = vbo;
			glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
			
			if((self.surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
				self.strideLength = 7;
				
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
					int pointIndex = [[[verticies objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue];
					Vector3D coord = Vector3DCreateWithDictionary([points objectAtIndex:pointIndex]);
					Vector3D disp = Vector3DSubtract(coord, self.origin);
					
					Vector2D texCoord = {0.0f, 0.0f};
					texCoord.x = (Vector3DDot(disp, vTextureU) + panU)/self.tex.width;
					texCoord.y = (Vector3DDot(disp, vTextureV) + panV)/self.tex.height;
					
					Vector2D lightCoord = {0.0f, 0.0f};
					lightCoord.x = (Vector3DDot(disp, vTextureU) - lightPan.x + 0.5f*lightUScale)/(lightUScale*self.lightMap.width);
					lightCoord.y = (Vector3DDot(disp, vTextureV) - lightPan.y + 0.5f*lightVScale)/(lightVScale*self.lightMap.height);
					
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
					int pointIndex = [[[verticies objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue];
					Vector3D coord = Vector3DCreateWithDictionary([points objectAtIndex:pointIndex]);
					
					coordinates[index]   = coord.x;
					coordinates[index+1] = coord.y;
					coordinates[index+2] = coord.z;
					index += self.strideLength;
				}
				
				glBufferData(GL_ARRAY_BUFFER, vertCount*sizeof(GLfloat)*self.strideLength, coordinates, GL_STATIC_DRAW);
				
				free(coordinates);
			}
			
//			printf("\tDone loading VBO\n");
			
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
			
			glBindVertexArrayOES(0);
			glBindBuffer(GL_ARRAY_BUFFER, 0);
			
//			printf("\tDone loading VAO\n");
		}
		
		//		int frontZoneIndex = [[node valueForKey:@"iZone1"] intValue];
		//		int backZoneIndex = [[node valueForKey:@"iZone2"] intValue];
		//		
		//		if([map.zones valueForKey:[NSString stringWithFormat:@"%i", frontZoneIndex]] == nil){
		//			UNRZone *frontZone = [[UNRZone alloc] initWithZone:[[model valueForKey:@"zones"] objectAtIndex:frontZoneIndex] index:frontZoneIndex];
		//			self.frontZone = frontZone;
		//			[frontZone release];
		//		}else{
		//			self.frontZone = [map.zones valueForKey:[NSString stringWithFormat:@"%i", frontZoneIndex]];
		//		}
		//		
		//		if([map.zones valueForKey:[NSString stringWithFormat:@"%i", backZoneIndex]] == nil){
		//			UNRZone *backZone = [[UNRZone alloc] initWithZone:[[model valueForKey:@"zones"] objectAtIndex:backZoneIndex] index:backZoneIndex];
		//			self.backZone = backZone;
		//			[backZone release];
		//		}else{
		//			self.backZone = [map.zones valueForKey:[NSString stringWithFormat:@"%i", backZoneIndex]];
		//		}
		
//		printf("Done loading node.\n");
		
		int frontInd = [[node valueForKey:@"iFront"] intValue];
		int backInd = [[node valueForKey:@"iBack"] intValue];
		int planeInd = [[node valueForKey:@"iPlane"] intValue];
		
		[pool drain];
		
		pool = [[NSAutoreleasePool alloc] init];
		
		if(planeInd != -1){
			[attrib setValue:[NSNumber numberWithInt:planeInd] forKey:@"iNode"];
			UNRNode *plane = [[UNRNode alloc] initWithModel:model attributes:attrib];//nodeNumber:planeInd file:file map:map
			self.coPlanar = plane;
			[plane release];
		}
		
		if(frontInd != -1){
			[attrib setValue:[NSNumber numberWithInt:frontInd] forKey:@"iNode"];
			UNRNode *front = [[UNRNode alloc] initWithModel:model attributes:attrib];//nodeNumber:frontInd file:file map:map
			self.front = front;
			[front release];
		}
		
		if(backInd != -1){
			[attrib setValue:[NSNumber numberWithInt:backInd] forKey:@"iNode"];
			UNRNode *back = [[UNRNode alloc] initWithModel:model attributes:attrib];//nodeNumber:backInd file:file map:map
			self.back = back;
			[back release];
		}
		
		[pool drain];
	}
	return self;
}

- (void)drawWithMatrix:(Matrix3D)mat frustum:(UNRFrustum)frustum camPos:(Vector3D)camPos nonSolid:(BOOL)nonSolid{
	NSMutableDictionary *state = [NSMutableDictionary dictionary];
	
	//[state setValue: forKey:@"zone"];
	//UNRZone *zone = [self zoneForCamera:camPos];
	
	[state setValue:[NSNumber numberWithBool:YES] forKey:@"shouldBoundTest"];
	
	[self.shader use];
	
	GLuint matrix = [self.shader uniformLocation:@"modelViewProjection"];
	glUniformMatrix4fv(matrix, 1, GL_FALSE, mat);
	
	[state setValue:[NSNumber numberWithBool:nonSolid] forKey:@"nonSolid"];
	if(nonSolid){
		glEnable(GL_BLEND);
	}else{
		glDisable(GL_BLEND);
	}
	
	[self drawWithState:state frustum:frustum camPos:&camPos];
	
//	[state setValue:[NSNumber numberWithBool:YES] forKey:@"nonSolid"];
//	glEnable(GL_BLEND);
//	
//	[self drawWithState:state matrix:mat camPos:&camPos];
}

- (void)drawWithState:(NSMutableDictionary *)state frustum:(UNRFrustum)frustum camPos:(Vector3D *)camPos{
	/*#if defined(DEBUG)
	 if(![self.shader validate]){
	 NSLog(@"Failed to validate program: %d", self.shader.program);
	 return;
	 }
	 #endif*/
	
	//TODO: only draw the node and it's sub nodes if it is visible from the camera position
	//frustum cull
	
	//visibility test each subNode, back and front, not coplaner, and only draw them if they are visible.
	//frustum cull each node in the visible space
	
	BOOL shouldDraw = YES;
	
	if([[state valueForKey:@"shouldBoundTest"] boolValue] == YES){
		//do the bounding box test, only draw if it succedes, set the shouldBoundTest to whether it fully passed, or only partly passed
		CollType culling = [self.renderBox classify:frustum];
		if(culling == C_In){
			[state setValue:[NSNumber numberWithBool:NO] forKey:@"shouldBoundTest"];
		}else if(culling == C_Out){
			shouldDraw = NO;
		}
	}
	
	//if portal, and portal is occluded, don't draw the back half
	
	if(shouldDraw){
		//float dist = Vector3DDot(self.normal, Vector3DSubtract(*camPos, self.origin));
		float dist = Vector4DDistance(self.plane, *camPos);
		if(dist < 0.0f){
			[self.front drawWithState:state frustum:frustum camPos:camPos];
		}else{
			[self.back drawWithState:state frustum:frustum camPos:camPos];
		}
		
		if((self.surfFlags & PF_TwoSided) || (dist > 0.0f)){
			BOOL nonSolid = [[state valueForKey:@"nonSolid"] boolValue];
			if((self.surfFlags & PF_Invisible) != PF_Invisible && nonSolid == ((self.surfFlags & PF_NotSolid) != 0)){
				glBindVertexArrayOES(self.vao);
				
				if((self.surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
					if([[state valueForKey:@"texture"] unsignedIntValue] != self.tex.glTex){
						[self.tex bind:0];
						[state setValue:[NSNumber numberWithUnsignedInt:self.tex.glTex] forKey:@"texture"];
					}
					
					if([[state valueForKey:@"lightMap"] unsignedIntValue] != self.lightMap.glTex){
						[self.lightMap bind:1];
						[state setValue:[NSNumber numberWithUnsignedInt:self.lightMap.glTex] forKey:@"lightMap"];
					}
				}
				
				[self setupState:state];
				
				glDrawArrays(GL_TRIANGLE_FAN, 0, self.vertCount);
			}
			
			[self.coPlanar drawWithState:state frustum:frustum camPos:camPos];
		}
		
		if(dist < 0.0f){
			[self.back drawWithState:state frustum:frustum camPos:camPos];
		}else{
			[self.front drawWithState:state frustum:frustum camPos:camPos];
		}
	}
}

- (void)setupState:(NSMutableDictionary *)state{
	int flags = [[state valueForKey:@"flags"] intValue];
	int surfFlags = self.surfFlags;
	int changed = surfFlags ^ flags;
	//setup stuff
	
	if(changed & PF_FakeBackdrop){
		if(surfFlags & PF_FakeBackdrop){
			glStencilOp(GL_ZERO, GL_ZERO, GL_REPLACE);
		}else{
			glStencilOp(GL_ZERO, GL_ZERO, GL_ZERO);
		}
	}
	
	if(changed & (PF_Translucent | PF_Modulated | PF_Masked)){
		if(surfFlags & PF_Translucent){
			glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR);
		}else if(surfFlags & PF_Modulated){
			glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);
		}else if(surfFlags & PF_Masked){
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		}
	}
	
	if(changed & PF_NotSolid){
		glDepthMask(surfFlags & PF_NotSolid);
	}
	
	/*if(changed & PF_TwoSided){
	 if(surfFlags & PF_TwoSided){
	 glDisable(GL_CULL_FACE);
	 }else{
	 glEnable(GL_CULL_FACE);
	 }
	 }*/
	
	[state setValue:[NSNumber numberWithInt:surfFlags] forKey:@"flags"];
}

/*- (UNRZone *)zoneForCamera:(Vector3D)camPos{
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
 }*/

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
	/*[backZone_ release];
	 backZone_ = nil;
	 [frontZone_ release];
	 frontZone_ = nil;*/
	[renderBox_ release];
	renderBox_ = nil;
	
	[super dealloc];
}

@end
