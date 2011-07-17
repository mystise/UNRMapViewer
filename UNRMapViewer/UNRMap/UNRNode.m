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

UNRNode *UNRNodeCreate(NSMutableDictionary *model, NSMutableDictionary *attrib){
    UNRNode *nodeStruct = calloc(1, sizeof(UNRNode));
	if(nodeStruct){
		
		nodeStruct->back = NULL;
		nodeStruct->front = NULL;
		nodeStruct->coPlanar = NULL;
		nodeStruct->lightMap = nil;
		nodeStruct->renderBox = nil;
		nodeStruct->shader = nil;
		nodeStruct->strideLength = 0;
		nodeStruct->tex = nil;
		nodeStruct->vao = 0;
		nodeStruct->vbo = 0;
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		UNRMap *map = [attrib valueForKey:@"map"];
		NSMutableArray *vectors = [attrib valueForKey:@"vectors"];
		NSMutableArray *points = [attrib valueForKey:@"points"];
		NSMutableArray *verticies = [attrib valueForKey:@"verts"];
		NSMutableArray *lights = [attrib valueForKey:@"lights"];
		NSMutableDictionary *node = [[model valueForKey:@"nodes"] objectAtIndex:[[attrib valueForKey:@"iNode"] intValue]];
		NSMutableDictionary *surf = [[model valueForKey:@"surfs"] objectAtIndex:[[node valueForKey:@"iSurf"] intValue]];
		
		nodeStruct->surfFlags = [[surf valueForKey:@"polyFlags"] intValue];
		if(nodeStruct->surfFlags & (PF_Translucent | PF_Modulated | PF_Masked)){
			nodeStruct->surfFlags |= PF_NotSolid;
		}else{
			nodeStruct->surfFlags &= ~PF_NotSolid;
		}
		
		nodeStruct->state = NULL;
		
		nodeStruct->origin = Vector3DCreateWithDictionary([points objectAtIndex:[[surf valueForKey:@"pBase"] intValue]]);
		
		nodeStruct->normal = Vector3DNegation(Vector3DCreateWithDictionary([vectors objectAtIndex:[[surf valueForKey:@"vNormal"] intValue]]));
		nodeStruct->plane = Vector4DCreateWithDictionary([node valueForKey:@"plane"]);
		nodeStruct->plane.w = -nodeStruct->plane.w;
		
		/*{
			int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
			int pointIndexA = [[[verticies objectAtIndex:iVertPool] valueForKey:@"pVertex"] intValue];
			Vector3D A = Vector3DCreateWithDictionary([points objectAtIndex:pointIndexA]);
			
			int pointIndexB = [[[verticies objectAtIndex:iVertPool+1] valueForKey:@"pVertex"] intValue];
			Vector3D B = Vector3DCreateWithDictionary([points objectAtIndex:pointIndexB]);
			
			int pointIndexC = [[[verticies objectAtIndex:iVertPool+2] valueForKey:@"pVertex"] intValue];
			Vector3D C = Vector3DCreateWithDictionary([points objectAtIndex:pointIndexC]);
			
			Vector3D AB = Vector3DSubtract(B, A);
			Vector3D AC = Vector3DSubtract(C, A);
			Vector3D normal = Vector3DNormalize(Vector3DCross(AB, AC));
			float w = -Vector3DDot(A, normal);
			
			Vector4D plane = nodeStruct->plane;
			
			//nodeStruct->normal = normal;
			nodeStruct->plane.x = normal.x;
			nodeStruct->plane.y = normal.y;
			nodeStruct->plane.z = normal.z;
			nodeStruct->plane.w = w;
		}*/
		
		nodeStruct->uVec = Vector3DCreateWithDictionary([vectors objectAtIndex:[[surf valueForKey:@"vTextureU"] intValue]]);
		nodeStruct->vVec = Vector3DCreateWithDictionary([vectors objectAtIndex:[[surf valueForKey:@"vTextureV"] intValue]]);
		
		int renderIndex = [[node valueForKey:@"iRenderBound"] intValue];
		if(renderIndex != -1){
			UNRBoundingBox *renderBox = [[UNRBoundingBox alloc] initWithBox:[[[model valueForKey:@"bounds"] objectAtIndex:renderIndex] valueForKey:@"bound"]];
			nodeStruct->renderBox = [renderBox retain];
			[renderBox release];
		}
		
		if((nodeStruct->surfFlags & PF_Invisible) != PF_Invisible){
			{
				id texture = [surf valueForKey:@"texture"];
				UNRExport *exp = texture;
				if([exp isKindOfClass:[UNRImport class]]){
					UNRImport *tex = (UNRImport *)exp;
					exp = tex.obj;
				}
				if(exp != nil){
					if([map.textures valueForKey:exp.name.string]){
						nodeStruct->tex = [[map.textures valueForKey:exp.name.string] retain];
					}else{
						UNRTexture *tex = [UNRTexture textureWithObject:exp.objectData attributes:[NSDictionary dictionaryWithObjectsAndKeys:
																								   [NSNumber numberWithBool:((nodeStruct->surfFlags & PF_Masked) == PF_Masked)], @"masked",
																								   [NSNumber numberWithInt:0], @"startMip",
																								   [NSNumber numberWithBool:((nodeStruct->surfFlags & PF_NoSmooth) != 0)], @"noSmooth",
																								   nil]];
						nodeStruct->tex = [tex retain];
						[map.textures setValue:tex forKey:exp.name.string];
					}
				}
			}
			
			int lightIndex = [[surf valueForKey:@"iLightMap"] intValue];
			NSMutableDictionary *lightMap = nil;
			if(lightIndex != -1){
				lightMap = [[model valueForKey:@"lightMaps"] objectAtIndex:lightIndex];
			}
			if(([map.lightMaps valueForKey:[NSString stringWithFormat:@"%i", lightIndex]] == nil && lightMap != nil) || nodeStruct->surfFlags & PF_Unlit){
				NSMutableData *lightData = [model valueForKey:@"LightBits"];
				UNRTexture *lighting = [UNRTexture textureWithLightMap:lightMap data:lightData lights:lights node:nodeStruct];
				[map.lightMaps setValue:lighting forKey:[NSString stringWithFormat:@"%i", lightIndex]];
				nodeStruct->lightMap = [lighting retain];
			}else{
				nodeStruct->lightMap = [[map.lightMaps valueForKey:[NSString stringWithFormat:@"%i", lightIndex]] retain];
			}
			
			if([map.shaders valueForKey:@"Texture"]){
				nodeStruct->shader = [[map.shaders valueForKey:@"Texture"] retain];
			}else{
				UNRShader *shad = [[UNRShader alloc] initWithShader:@"Texture"];
				nodeStruct->shader = [shad retain];
				[map.shaders setValue:shad forKey:@"Texture"];
				[shad release];
			}
			
			GLuint vbo;
			glGenBuffers(1, &vbo);
			nodeStruct->vbo = vbo;
			glBindBuffer(GL_ARRAY_BUFFER, nodeStruct->vbo);
			
			if((nodeStruct->surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
				nodeStruct->strideLength = 5;
				
				//float scaleU = Vector3DMagnitude(vTextureU);
				//float scaleV = Vector3DMagnitude(vTextureV);
				//Vector3DNormalizeEqual(&vTextureU);
				//Vector3DNormalizeEqual(&vTextureV);
				short panU = [[surf valueForKey:@"panU"] shortValue];
				short panV = [[surf	valueForKey:@"panV"] shortValue];
				
				Vector3D lightPan = Vector3DCreateWithDictionary([lightMap valueForKey:@"pan"]);
				float lightUScale = [[lightMap valueForKey:@"uScale"] floatValue];
				float lightVScale = [[lightMap valueForKey:@"vScale"] floatValue];
				
				//lightmap panbias = -0.5
				//Tex.UPan = Info.Pan.X + PanBias*Info.UScale;
				//Tex.VPan = Info.Pan.Y + PanBias*Info.VScale;
				
				int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
				int vertCount = [[node valueForKey:@"vertCount"] intValue];
				
                nodeStruct->lightMapCoords = (Vector2D *)calloc(vertCount, sizeof(Vector2D));
				GLfloat *coordinates = (GLfloat *)calloc(vertCount*nodeStruct->strideLength, sizeof(GLfloat));
				nodeStruct->vertCount = vertCount;
				int index = 0;
				for(int i = 0; i < vertCount; i++){
					int pointIndex = [[[verticies objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue];
					Vector3D coord = Vector3DCreateWithDictionary([points objectAtIndex:pointIndex]);
					Vector3D disp = Vector3DSubtract(coord, nodeStruct->origin);
					
					Vector2D texCoord = {0.0f, 0.0f};
					texCoord.x = (Vector3DDot(disp, nodeStruct->uVec) + panU)/(nodeStruct->tex.width);
					texCoord.y = (Vector3DDot(disp, nodeStruct->vVec) + panV)/(nodeStruct->tex.height);
					
					Vector2D lightCoord = {0.0f, 0.0f};
					lightCoord.x = (Vector3DDot(disp, nodeStruct->uVec) - lightPan.x + 0.5f*lightUScale)/(lightUScale*nodeStruct->lightMap.width);
					lightCoord.y = (Vector3DDot(disp, nodeStruct->vVec) - lightPan.y + 0.5f*lightVScale)/(lightVScale*nodeStruct->lightMap.height);
					
					coordinates[index]   = coord.x;
					coordinates[index+1] = coord.y;
					coordinates[index+2] = coord.z;
					coordinates[index+3] = texCoord.x;
					coordinates[index+4] = texCoord.y;
                  nodeStruct->lightMapCoords[i].x = lightCoord.x;
                  nodeStruct->lightMapCoords[i].y = lightCoord.y;
                  //					coordinates[index+5] = lightCoord.x;
//					coordinates[index+6] = lightCoord.y;
					index += nodeStruct->strideLength;
				}
				
				glBufferData(GL_ARRAY_BUFFER, vertCount*sizeof(GLfloat)*nodeStruct->strideLength, coordinates, GL_STATIC_DRAW);
				
				free(coordinates);
			}else{
				nodeStruct->strideLength = 3;
				
				int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
				int vertCount = [[node valueForKey:@"vertCount"] intValue];
				GLfloat *coordinates = (GLfloat *)calloc(vertCount*nodeStruct->strideLength, sizeof(GLfloat));
				nodeStruct->vertCount = vertCount;
				int index = 0;
				for(int i = 0; i < vertCount; i++){
					int pointIndex = [[[verticies objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue];
					Vector3D coord = Vector3DCreateWithDictionary([points objectAtIndex:pointIndex]);
					
					coordinates[index]   = coord.x;
					coordinates[index+1] = coord.y;
					coordinates[index+2] = coord.z;
					index += nodeStruct->strideLength;
				}
				
				glBufferData(GL_ARRAY_BUFFER, vertCount*sizeof(GLfloat)*nodeStruct->strideLength, coordinates, GL_STATIC_DRAW);
				
				free(coordinates);
			}
			
			GLuint vao = 0;
			glGenVertexArraysOES(1, &vao);
			nodeStruct->vao = vao;
			glBindVertexArrayOES(nodeStruct->vao);
			
			glBindBuffer(GL_ARRAY_BUFFER, nodeStruct->vbo);
			
			[nodeStruct->shader use];
			
			GLuint position = [nodeStruct->shader attribLocation:@"position"];
			glEnableVertexAttribArray(position);
			glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, nodeStruct->strideLength*sizeof(GLfloat), NULL);
			
			if((nodeStruct->surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
				[nodeStruct->tex bind:0];
				[nodeStruct->lightMap bind:1];
				
				GLuint inTexCoord = [nodeStruct->shader attribLocation:@"inTexCoord"];
				//GLuint inLightCoord = [nodeStruct->shader attribLocation:@"inLightCoord"];
				GLuint texture = [nodeStruct->shader uniformLocation:@"texture"];
				GLuint lightmap = [nodeStruct->shader uniformLocation:@"lightmap"];
				
				glUniform1i(texture, 0);
				glUniform1i(lightmap, 1);
				glEnableVertexAttribArray(inTexCoord);
				//glEnableVertexAttribArray(inLightCoord);
				glVertexAttribPointer(inTexCoord, 2, GL_FLOAT, GL_FALSE, nodeStruct->strideLength*sizeof(GLfloat), (void *)(3*sizeof(GLfloat)));
				//glVertexAttribPointer(inLightCoord, 2, GL_FLOAT, GL_FALSE, nodeStruct->strideLength*sizeof(GLfloat), (void *)(5*sizeof(GLfloat)));
			}
			
			glBindVertexArrayOES(0);
			glBindBuffer(GL_ARRAY_BUFFER, 0);
		}
		
		int frontInd = [[node valueForKey:@"iFront"] intValue];
		int backInd = [[node valueForKey:@"iBack"] intValue];
		int planeInd = [[node valueForKey:@"iPlane"] intValue];
		
		[pool drain];
		
		pool = [[NSAutoreleasePool alloc] init];
		
		if(planeInd != -1){
			[attrib setValue:[NSNumber numberWithInt:planeInd] forKey:@"iNode"];
			UNRNode *plane = UNRNodeCreate(model, attrib);
			nodeStruct->coPlanar = plane;
		}
		
		if(frontInd != -1){
			[attrib setValue:[NSNumber numberWithInt:frontInd] forKey:@"iNode"];
			UNRNode *front = UNRNodeCreate(model, attrib);
			nodeStruct->front = front;
		}
		
		if(backInd != -1){
			[attrib setValue:[NSNumber numberWithInt:backInd] forKey:@"iNode"];
			UNRNode *back = UNRNodeCreate(model, attrib);
			nodeStruct->back = back;
		}
		
		/*if(nodeStruct->surfFlags & PF_NotSolid){
			UNRNode *temp = nodeStruct->front;
			nodeStruct->front = nodeStruct->back;
			nodeStruct->back = temp;
		}*/
		
		[pool drain];
	}
	
	return nodeStruct;
}

void UNRNodeSetupState(UNRNode *node, UNRState *state){
	int flags = state->currentFlags;
	int surfFlags = node->surfFlags;
	int changed = surfFlags ^ flags;
	
	if(changed & PF_FakeBackdrop){
		if(surfFlags & PF_FakeBackdrop){
			glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
		}else{
			glStencilOp(GL_KEEP, GL_KEEP, GL_ZERO);
		}
	}
	
	if(changed & PF_TwoSided){
		if(surfFlags & PF_TwoSided){
			glDisable(GL_CULL_FACE);
		}else{
			glEnable(GL_CULL_FACE);
		}
	}
	
	if(changed & (PF_Translucent | PF_Modulated | PF_Masked)){
		/*if(surfFlags & (PF_Translucent | PF_Modulated | PF_Masked)){
		 glStencilMask(0x00);
		 }else{
		 glStencilMask(UINT_MAX);
		 }*/
		if(surfFlags & (PF_Translucent | PF_Modulated | PF_Masked)){
			//glEnable(GL_BLEND);
			if(surfFlags & PF_Translucent){
				glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR);
			}else if(surfFlags & PF_Modulated){
				glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);
			}else if(surfFlags & PF_Masked){
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			}
		}else{
			//glDisable(GL_BLEND);
		}
	}
	
	if((node->surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
		
		//for each tex in the tex array
		//	find the currently used texture
		//end for
		//if you can't find the currently used texture,
		//	search for an empty one
		//end if
		//if you can't find an empty slot
		//	search for the oldest one
		//end if
		//bind that slot to the texture
		
		/*GLuint index = -1, oldAge = 0;
		 BOOL rebind = YES, found = NO;
		 for(int i = 0; i < 7; i++){
		 int age = state->textures[i].age;
		 if(age != -1){
		 state->textures[i].age++;
		 }
		 if(!found){
		 int tex = state->textures[i].tex;
		 
		 if(tex == node->tex.glTex){
		 index = i;
		 rebind = NO;
		 found = YES;
		 }else if(tex == -1){
		 index = i;
		 rebind = YES;
		 found = YES;
		 }else{
		 if(age > oldAge){
		 oldAge = age;
		 index = i;
		 rebind = YES;
		 }
		 }
		 }
		 }
		 
		 //GLuint texture = [node->shader uniformLocation:@"texture"];
		 glUniform1i(node->texUniform, index);
		 
		 if(rebind == YES){
		 [node->tex bind:index];
		 state->textures[index].tex = node->tex.glTex;
		 state->textures[index].age = 0;
		 }*/
		
		if(state->tex != node->tex.glTex){
			[node->tex bind:0];
			state->tex = node->tex.glTex;
		}
		
//		if(state->lightmap != node->lightMap.glTex){
//			[node->lightMap bind:1];
//			state->lightmap = node->lightMap.glTex;
//		}
	}
	
	//	if(changed & PF_NotSolid){
	//		//glDepthMask(surfFlags & PF_NotSolid);
	//		if(surfFlags & PF_NotSolid){
	//			//glDepthMask(GL_FALSE);
	//		}else{
	//			;
	//			//glDepthMask(GL_TRUE);
	//		}
	//	}
	//	
	state->currentFlags = surfFlags;
}

void UNRNodeDrawWithState(UNRNode *node, UNRState *state, UNRFrustum frustum, Vector3D *camPos){
	//	#if defined(DEBUG)
	//	 if(![nodeStruct->shader validate]){
	//	 NSLog(@"Failed to validate program: %d", nodeStruct->shader.program);
	//	 return;
	//	 }
	//	 #endif
	
	//TODO: only draw the node and it's sub nodes if it is visible from the camera position
	//frustum cull
	
	//visibility test each subNode, back and front, not coplaner, and only draw them if they are visible.
	//frustum cull each node in the visible space
	
	BOOL shouldDraw = YES;
	
	if(state->shouldBoundTest == YES){
		//do the bounding box test, only draw if it succedes, set the shouldBoundTest to whether it fully passed, or only partly passed
		CollType culling = [node->renderBox classify:frustum];
		if(culling == C_In){
			state->shouldBoundTest = NO;
		}else if(culling == C_Out){
			shouldDraw = NO;
		}
	}
	
	//if portal, and portal is occluded, don't draw the back half
	
	if(shouldDraw){
		//glDisable(GL_DEPTH_TEST);
		float dist = Vector4DDistance(node->plane, *camPos);
		BOOL nonSolid = state->nonSolid;
		if(dist > 0.0f){
			if(node->front){
				UNRNodeDrawWithState(node->front, state, frustum, camPos);
			}
		}else{
			if(node->back){
				UNRNodeDrawWithState(node->back, state, frustum, camPos);
			}
		}
		
		//if((node->surfFlags & PF_TwoSided) || (dist > 0.0f)){
			if((node->surfFlags & PF_Invisible) != PF_Invisible && (nonSolid || !(node->surfFlags & PF_NotSolid))){
				glBindVertexArrayOES(node->vao);
				
				UNRNodeSetupState(node, state);
				
				glDrawArrays(GL_TRIANGLE_FAN, 0, node->vertCount);
			}
			
			if(node->coPlanar){
				UNRNodeDrawWithState(node->coPlanar, state, frustum, camPos);
			}
		//}
		
		if(dist > 0.0f){
			if(node->back){
				UNRNodeDrawWithState(node->back, state, frustum, camPos);
			}
		}else{
			if(node->front){
				UNRNodeDrawWithState(node->front, state, frustum, camPos);
			}
		}
	}
}

void UNRNodeDraw(UNRNode *root, Matrix3D mat, UNRFrustum frustum, Vector3D camPos, BOOL nonSolid, BOOL backDrop){
	if(root->state == NULL){
		UNRState *state = malloc(sizeof(UNRState));
		state->currentFlags = 0;
		state->lightmap = -1;
		state->tex = -1;
		state->shouldBoundTest = YES;
		root->state = state;
	}
	root->state->shouldBoundTest = YES;
	root->state->nonSolid = nonSolid;
	/*state->backDrop = backDrop;
	 if(nonSolid){
	 glEnable(GL_BLEND);
	 }else{
	 glDisable(GL_BLEND);
	 }*/
	//NSMutableDictionary *state = [NSMutableDictionary dictionary];
	
	//[state setValue: forKey:@"zone"];
	//UNRZone *zone = [self zoneForCamera:camPos];
	
	//	[state setValue:[NSNumber numberWithBool:YES] forKey:@"shouldBoundTest"];
	
	[root->shader use];
	
	GLuint matrix = [root->shader uniformLocation:@"modelViewProjection"];
	glUniformMatrix4fv(matrix, 1, GL_FALSE, mat);
	
	//	[state setValue:[NSNumber numberWithBool:nonSolid] forKey:@"nonSolid"];
	
	UNRNodeDrawWithState(root, root->state, frustum, &camPos);
	//[self drawWithState:state frustum:frustum camPos:&camPos];
	//free(state);
}

void UNRNodeDelete(UNRNode *node){
	[node->tex release];
	[node->lightMap release];
	[node->renderBox release];
	[node->shader release];
	free(node->state);
	glDeleteVertexArraysOES(1, &node->vao);
	glDeleteBuffers(1, &node->vbo);
	
	UNRNodeDelete(node->front);
	UNRNodeDelete(node->back);
	UNRNodeDelete(node->coPlanar);
	
	free(node);
}

/*@implementation UNRNode
 
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
 
 nodeStruct->surfFlags = [[surf valueForKey:@"polyFlags"] intValue];
 if(!(nodeStruct->surfFlags & PF_NoOcclude)){
 nodeStruct->surfFlags |= PF_Occlude;
 }
 
 nodeStruct->origin = Vector3DCreateWithDictionary([points objectAtIndex:[[surf valueForKey:@"pBase"] intValue]]);
 
 nodeStruct->normal = Vector3DCreateWithDictionary([vectors objectAtIndex:[[surf valueForKey:@"vNormal"] intValue]]);
 nodeStruct->plane = Vector4DCreateWithDictionary([node valueForKey:@"plane"]);
 int renderIndex = [[node valueForKey:@"iRenderBound"] intValue];
 if(renderIndex != -1){
 UNRBoundingBox *renderBox = [[UNRBoundingBox alloc] initWithBox:[[[model valueForKey:@"bounds"] objectAtIndex:renderIndex] valueForKey:@"bound"]];
 nodeStruct->renderBox = renderBox;
 [renderBox release];
 }
 
 //		printf("\tDone loading Box\n");
 
 if((nodeStruct->surfFlags & PF_Invisible) != PF_Invisible){
 {
 id texture = [surf valueForKey:@"texture"];
 UNRExport *exp = texture;
 if([exp isKindOfClass:[UNRImport class]]){
 UNRImport *tex = (UNRImport *)exp;
 exp = tex.obj;
 }
 if(exp != nil){
 if([map.textures valueForKey:exp.name.string]){
 nodeStruct->tex = [map.textures valueForKey:exp.name.string];
 }else{
 UNRTexture *tex = [UNRTexture textureWithObject:exp.objectData attributes:[NSDictionary dictionaryWithObjectsAndKeys:
 [NSNumber numberWithBool:((nodeStruct->surfFlags & PF_Masked) == PF_Masked)], @"masked",
 [NSNumber numberWithInt:0], @"startMip",
 [NSNumber numberWithBool:((nodeStruct->surfFlags & PF_NoSmooth) != 0)], @"noSmooth",
 nil]];
 nodeStruct->tex = tex;
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
 nodeStruct->lightMap = lighting;
 }else{
 nodeStruct->lightMap = [map.lightMaps valueForKey:[NSString stringWithFormat:@"%i", lightIndex]];
 }
 
 //			printf("\tDone loading LightMap\n");
 
 //			if((nodeStruct->surfFlags & PF_FakeBackdrop) == PF_FakeBackdrop){
 //			 if([map.shaders valueForKey:@"SkyBox"]){
 //			 nodeStruct->shader = [map.shaders valueForKey:@"SkyBox"];
 //			 }else{
 //			 UNRShader *shad = [[UNRShader alloc] initWithShader:@"SkyBox"];
 //			 nodeStruct->shader = shad;
 //			 [map.shaders setValue:shad forKey:@"SkyBox"];
 //			 [shad release];
 //			 }
 //			 }else{
 if([map.shaders valueForKey:@"Texture"]){
 nodeStruct->shader = [map.shaders valueForKey:@"Texture"];
 }else{
 UNRShader *shad = [[UNRShader alloc] initWithShader:@"Texture"];
 nodeStruct->shader = shad;
 [map.shaders setValue:shad forKey:@"Texture"];
 [shad release];
 }
 //}
 
 //			printf("\tDone loading Shader\n");
 
 GLuint vbo;
 glGenBuffers(1, &vbo);
 nodeStruct->vbo = vbo;
 glBindBuffer(GL_ARRAY_BUFFER, nodeStruct->vbo);
 
 if((nodeStruct->surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
 nodeStruct->strideLength = 7;
 
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
 GLfloat *coordinates = (GLfloat *)calloc(vertCount*nodeStruct->strideLength, sizeof(GLfloat));
 nodeStruct->vertCount = vertCount;
 int index = 0;
 for(int i = 0; i < vertCount; i++){
 int pointIndex = [[[verticies objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue];
 Vector3D coord = Vector3DCreateWithDictionary([points objectAtIndex:pointIndex]);
 Vector3D disp = Vector3DSubtract(coord, nodeStruct->origin);
 
 Vector2D texCoord = {0.0f, 0.0f};
 texCoord.x = (Vector3DDot(disp, vTextureU) + panU)/nodeStruct->tex.width;
 texCoord.y = (Vector3DDot(disp, vTextureV) + panV)/nodeStruct->tex.height;
 
 Vector2D lightCoord = {0.0f, 0.0f};
 lightCoord.x = (Vector3DDot(disp, vTextureU) - lightPan.x + 0.5f*lightUScale)/(lightUScale*nodeStruct->lightMap.width);
 lightCoord.y = (Vector3DDot(disp, vTextureV) - lightPan.y + 0.5f*lightVScale)/(lightVScale*nodeStruct->lightMap.height);
 
 coordinates[index]   = coord.x;
 coordinates[index+1] = coord.y;
 coordinates[index+2] = coord.z;
 coordinates[index+3] = texCoord.x;
 coordinates[index+4] = texCoord.y;
 coordinates[index+5] = lightCoord.x;
 coordinates[index+6] = lightCoord.y;
 index += nodeStruct->strideLength;
 }
 
 glBufferData(GL_ARRAY_BUFFER, vertCount*sizeof(GLfloat)*nodeStruct->strideLength, coordinates, GL_STATIC_DRAW);
 
 free(coordinates);
 }else{
 nodeStruct->strideLength = 3;
 
 int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
 int vertCount = [[node valueForKey:@"vertCount"] intValue];
 GLfloat *coordinates = (GLfloat *)calloc(vertCount*nodeStruct->strideLength, sizeof(GLfloat));
 nodeStruct->vertCount = vertCount;
 int index = 0;
 for(int i = 0; i < vertCount; i++){
 int pointIndex = [[[verticies objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue];
 Vector3D coord = Vector3DCreateWithDictionary([points objectAtIndex:pointIndex]);
 
 coordinates[index]   = coord.x;
 coordinates[index+1] = coord.y;
 coordinates[index+2] = coord.z;
 index += nodeStruct->strideLength;
 }
 
 glBufferData(GL_ARRAY_BUFFER, vertCount*sizeof(GLfloat)*nodeStruct->strideLength, coordinates, GL_STATIC_DRAW);
 
 free(coordinates);
 }
 
 //			printf("\tDone loading VBO\n");
 
 GLuint vao = 0;
 glGenVertexArraysOES(1, &vao);
 nodeStruct->vao = vao;
 glBindVertexArrayOES(nodeStruct->vao);
 
 glBindBuffer(GL_ARRAY_BUFFER, nodeStruct->vbo);
 
 [nodeStruct->shader use];
 
 GLuint position = [nodeStruct->shader attribLocation:@"position"];
 glEnableVertexAttribArray(position);
 glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, nodeStruct->strideLength*sizeof(GLfloat), NULL);
 
 if((nodeStruct->surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
 [nodeStruct->tex bind:0];
 [nodeStruct->lightMap bind:1];
 
 GLuint inTexCoord = [nodeStruct->shader attribLocation:@"inTexCoord"];
 GLuint inLightCoord = [nodeStruct->shader attribLocation:@"inLightCoord"];
 GLuint texture = [nodeStruct->shader uniformLocation:@"texture"];
 GLuint lightmap = [nodeStruct->shader uniformLocation:@"lightmap"];
 
 glUniform1i(texture, 0);
 glUniform1i(lightmap, 1);
 glEnableVertexAttribArray(inTexCoord);
 glEnableVertexAttribArray(inLightCoord);
 glVertexAttribPointer(inTexCoord, 2, GL_FLOAT, GL_FALSE, nodeStruct->strideLength*sizeof(GLfloat), (void *)(3*sizeof(GLfloat)));
 glVertexAttribPointer(inLightCoord, 2, GL_FLOAT, GL_FALSE, nodeStruct->strideLength*sizeof(GLfloat), (void *)(5*sizeof(GLfloat)));
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
 //			nodeStruct->frontZone = frontZone;
 //			[frontZone release];
 //		}else{
 //			nodeStruct->frontZone = [map.zones valueForKey:[NSString stringWithFormat:@"%i", frontZoneIndex]];
 //		}
 //		
 //		if([map.zones valueForKey:[NSString stringWithFormat:@"%i", backZoneIndex]] == nil){
 //			UNRZone *backZone = [[UNRZone alloc] initWithZone:[[model valueForKey:@"zones"] objectAtIndex:backZoneIndex] index:backZoneIndex];
 //			nodeStruct->backZone = backZone;
 //			[backZone release];
 //		}else{
 //			nodeStruct->backZone = [map.zones valueForKey:[NSString stringWithFormat:@"%i", backZoneIndex]];
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
 nodeStruct->coPlanar = plane;
 [plane release];
 }
 
 if(frontInd != -1){
 [attrib setValue:[NSNumber numberWithInt:frontInd] forKey:@"iNode"];
 UNRNode *front = [[UNRNode alloc] initWithModel:model attributes:attrib];//nodeNumber:frontInd file:file map:map
 nodeStruct->front = front;
 [front release];
 }
 
 if(backInd != -1){
 [attrib setValue:[NSNumber numberWithInt:backInd] forKey:@"iNode"];
 UNRNode *back = [[UNRNode alloc] initWithModel:model attributes:attrib];//nodeNumber:backInd file:file map:map
 nodeStruct->back = back;
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
 
 [nodeStruct->shader use];
 
 GLuint matrix = [nodeStruct->shader uniformLocation:@"modelViewProjection"];
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
 //	#if defined(DEBUG)
 //	 if(![nodeStruct->shader validate]){
 //	 NSLog(@"Failed to validate program: %d", nodeStruct->shader.program);
 //	 return;
 //	 }
 //	 #endif
 
 //TODO: only draw the node and it's sub nodes if it is visible from the camera position
 //frustum cull
 
 //visibility test each subNode, back and front, not coplaner, and only draw them if they are visible.
 //frustum cull each node in the visible space
 
 BOOL shouldDraw = YES;
 
 if([[state valueForKey:@"shouldBoundTest"] boolValue] == YES){
 //do the bounding box test, only draw if it succedes, set the shouldBoundTest to whether it fully passed, or only partly passed
 CollType culling = [nodeStruct->renderBox classify:frustum];
 if(culling == C_In){
 [state setValue:[NSNumber numberWithBool:NO] forKey:@"shouldBoundTest"];
 }else if(culling == C_Out){
 shouldDraw = NO;
 }
 }
 
 //if portal, and portal is occluded, don't draw the back half
 
 if(shouldDraw){
 //float dist = Vector3DDot(nodeStruct->normal, Vector3DSubtract(*camPos, nodeStruct->origin));
 float dist = Vector4DDistance(nodeStruct->plane, *camPos);
 if(dist < 0.0f){
 [nodeStruct->front drawWithState:state frustum:frustum camPos:camPos];
 }else{
 [nodeStruct->back drawWithState:state frustum:frustum camPos:camPos];
 }
 
 if((nodeStruct->surfFlags & PF_TwoSided) || (dist > 0.0f)){
 BOOL nonSolid = [[state valueForKey:@"nonSolid"] boolValue];
 if((nodeStruct->surfFlags & PF_Invisible) != PF_Invisible && nonSolid == ((nodeStruct->surfFlags & PF_NotSolid) != 0)){
 glBindVertexArrayOES(nodeStruct->vao);
 
 if((nodeStruct->surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
 if([[state valueForKey:@"texture"] unsignedIntValue] != nodeStruct->tex.glTex){
 [nodeStruct->tex bind:0];
 [state setValue:[NSNumber numberWithUnsignedInt:nodeStruct->tex.glTex] forKey:@"texture"];
 }
 
 if([[state valueForKey:@"lightMap"] unsignedIntValue] != nodeStruct->lightMap.glTex){
 [nodeStruct->lightMap bind:1];
 [state setValue:[NSNumber numberWithUnsignedInt:nodeStruct->lightMap.glTex] forKey:@"lightMap"];
 }
 }
 
 [self setupState:state];
 
 glDrawArrays(GL_TRIANGLE_FAN, 0, nodeStruct->vertCount);
 }
 
 [nodeStruct->coPlanar drawWithState:state frustum:frustum camPos:camPos];
 }
 
 if(dist < 0.0f){
 [nodeStruct->back drawWithState:state frustum:frustum camPos:camPos];
 }else{
 [nodeStruct->front drawWithState:state frustum:frustum camPos:camPos];
 }
 }
 }
 
 - (void)setupState:(NSMutableDictionary *)state{
 int flags = [[state valueForKey:@"flags"] intValue];
 int surfFlags = nodeStruct->surfFlags;
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
 
 //	if(changed & PF_TwoSided){
 //	 if(surfFlags & PF_TwoSided){
 //	 glDisable(GL_CULL_FACE);
 //	 }else{
 //	 glEnable(GL_CULL_FACE);
 //	 }
 //	 }
 
 [state setValue:[NSNumber numberWithInt:surfFlags] forKey:@"flags"];
 }
 
 //- (UNRZone *)zoneForCamera:(Vector3D)camPos{
 // float dot = Vector4DDistance(nodeStruct->plane, camPos);
 // const float tolerance = 0.01f;
 // 
 // if(dot > tolerance){
 // UNRZone *frontZone = [nodeStruct->front zoneForCamera:camPos];
 // if(frontZone != nil){
 // return frontZone;
 // }else{
 // return nodeStruct->frontZone;
 // }
 // }else if(dot < -tolerance){
 // UNRZone *backZone = [nodeStruct->back zoneForCamera:camPos];
 // if(backZone != nil){
 // return backZone;
 // }else{
 // return nodeStruct->backZone;
 // }
 // }
 // return nodeStruct->frontZone;
 // }
 
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
 //	[backZone_ release];
 //	 backZone_ = nil;
 //	 [frontZone_ release];
 //	 frontZone_ = nil;
 [renderBox_ release];
 renderBox_ = nil;
 
 [super dealloc];
 }
 
 @end
 */