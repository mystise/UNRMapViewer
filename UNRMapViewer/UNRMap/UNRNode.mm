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

/*normal = normal_, plane = plane_, */
@synthesize vbo = vbo_, vao = vao_, vertCount = vertCount_, tex = tex_, front = front_, back = back_, coPlanar = coPlanar_, surfFlags = surfFlags_, shader = shader_, lightMap = lightMap_, strideLength = strideLength_;

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
		
		if((self.surfFlags & PF_FakeBackdrop) == PF_FakeBackdrop){
			self.surfFlags = self.surfFlags | PF_Invisible;
		}
		
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
			if(lightIndex != -1 && (self.surfFlags & PF_Unlit) != PF_Unlit){
				NSMutableDictionary *lightMap = [[model valueForKey:@"lightMaps"] objectAtIndex:lightIndex];
				NSMutableData *lightData = [model valueForKey:@"LightBits"];
				if([map.lightMaps valueForKey:[NSString stringWithFormat:@"%i", lightIndex]] == nil){
					UNRTexture *lighting = [UNRTexture textureWithLightMap:lightMap data:lightData lights:[[model valueForKey:@"lights"] valueForKey:@"light"]];
					[map.lightMaps setValue:lighting forKey:[NSString stringWithFormat:@"%i", lightIndex]];
					self.lightMap = lighting;
				}else{
					self.lightMap = [map.lightMaps valueForKey:[NSString stringWithFormat:@"%i", lightIndex]];
				}
			}
			
			//self.plane = [node valueForKey:@"plane"];
			
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
			
			GLuint vbo;
			glGenBuffers(1, &vbo);
			self.vbo = vbo;
			glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
			
			//if((self.surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
				self.strideLength = 7;
				
				NSMutableDictionary *lightMap = nil;
				if(lightIndex != -1){
					lightMap = [[model valueForKey:@"lightMaps"] objectAtIndex:lightIndex];
				}
				vec3 pBase = vec3Create([points objectAtIndex:[[surf valueForKey:@"pBase"] intValue]]);
				vec3 vTextureU = vec3Create([vectors objectAtIndex:[[surf valueForKey:@"vTextureU"] intValue]]);
				vec3 vTextureV = vec3Create([vectors objectAtIndex:[[surf valueForKey:@"vTextureV"] intValue]]);
				short panU = [[surf valueForKey:@"panU"] shortValue];
				short panV = [[surf	valueForKey:@"panV"] shortValue];
				
				vec3 lightPan = vec3Create([lightMap valueForKey:@"pan"]);
				float lightUScale = [[lightMap valueForKey:@"uScale"] floatValue];
				float lightVScale = [[lightMap valueForKey:@"vScale"] floatValue];
				vec3 lightU = vTextureU;
				vec3 lightV = vTextureV;
				
				//lightmap panbias = -0.5
				//Tex.UPan      = Info.Pan.X + PanBias*Info.UScale;
				//Tex.VPan      = Info.Pan.Y + PanBias*Info.VScale;
				
				int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
				int vertCount = [[node valueForKey:@"vertCount"] intValue];
				GLfloat *coordinates = (GLfloat *)calloc(vertCount*self.strideLength, sizeof(GLfloat));
				self.vertCount = vertCount;
				int index = 0;
				for(int i = 0; i < vertCount; i++){
					vec3 coord = vec3Create([points objectAtIndex:[[[verticies objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue]]);
					vec3 disp = vec3Sub(coord, pBase);
					
					vec2 texCoord = {0.0f, 0.0f};
					texCoord.x = (vec3Dot(disp, vTextureU) + panU)/self.tex.width;
					texCoord.y = (vec3Dot(disp, vTextureV) + panV)/self.tex.height;
					
					vec2 lightCoord = {0.0f, 0.0f};
					lightCoord.x = (vec3Dot(disp, lightU) - (lightPan.x + (-0.5f*lightUScale)))/(lightUScale*self.lightMap.width);
					lightCoord.y = (vec3Dot(disp, lightV) - (lightPan.y + (-0.5f*lightVScale)))/(lightVScale*self.lightMap.height);
					
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
			/*}else{
			  self.strideLength = 3;
			  
			  int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
			  int vertCount = [[node valueForKey:@"vertCount"] intValue];
			  GLfloat *coordinates = (GLfloat *)calloc(vertCount*self.strideLength, sizeof(GLfloat));
			  self.vertCount = vertCount;
			  int index = 0;
			  for(int i = 0; i < vertCount; i++){
			  vec3 coord = vec3Create([points objectAtIndex:[[[verticies objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue]]);
			  
			  coordinates[index]   = coord.x;
			  coordinates[index+1] = coord.y;
			  coordinates[index+2] = coord.z;
			  index += self.strideLength;
			  }
			  
			  glBufferData(GL_ARRAY_BUFFER, vertCount*sizeof(GLfloat)*self.strideLength, coordinates, GL_STATIC_DRAW);
			  
			  free(coordinates);
			  }*/
			
			GLuint vao = 0;
			glGenVertexArraysOES(1, &vao);
			self.vao = vao;
			glBindVertexArrayOES(self.vao);
			
			glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
			
			[self.shader use];
			
			GLuint position = [self.shader attribLocation:@"position"];
			glEnableVertexAttribArray(position);
			glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, self.strideLength*sizeof(GLfloat), NULL);
			[self.tex bind:0];
			
			//if((self.surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
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
			//}
			
			//self.normal = vec3Create([[vectors objectAtIndex:[[surf valueForKey:@"vNormal"] intValue]] valueForKey:@"vector"]);
		}
		
		int frontInd = [[node valueForKey:@"iFront"] intValue];
		int backInd = [[node valueForKey:@"iBack"] intValue];
		int planeInd = [[node valueForKey:@"iPlane"] intValue];
		
		if(planeInd != -1){
			UNRNode *plane = [[UNRNode alloc] initWithModel:model nodeNumber:planeInd file:file map:map];
			self.coPlanar = plane;
			[plane release];
		}
		if(frontInd != -1 && frontInd < [[model valueForKey:@"nodes"] count]){
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

- (void)drawWithMatrix:(Matrix3D &)mat cubeMap:(GLuint)texMap cameraPos:(vec3)vec{
	NSMutableDictionary *state = [NSMutableDictionary dictionary];
	//[self.shader use];
	//[state setValue:[NSNumber numberWithUnsignedInt:self.shader.program] forKey:@"shader"];
	
	//if(texMap != 0){
	//	[state setValue:[NSNumber numberWithUnsignedInt:texMap] forKey:@"cubeMap"];
	//}
	
	GLuint matrix = [self.shader uniformLocation:@"modelViewProjection"];
	glUniformMatrix4fv(matrix, 1, GL_FALSE, mat.glData());
	[state setValue:[NSNumber numberWithUnsignedInt:(unsigned int)mat.glData()] forKey:@"matrix"];
	
	[state setValue:[NSNumber numberWithUnsignedInt:(unsigned int)&vec] forKey:@"camPos"];
	
	[self drawWithState:state];
}

- (void)drawWithState:(NSMutableDictionary *)state{
	//if(self.shader.program != [[state valueForKey:@"shader"] unsignedIntValue] && self.shader != nil){
	//[self.shader use];
	//[state setValue:[NSNumber numberWithUnsignedInt:self.shader.program] forKey:@"shader"];
	/*GLuint position = [self.shader attribLocation:@"position"];
	 glEnableVertexAttribArray(position);
	 
	 if((self.surfFlags & PF_FakeBackdrop) != PF_FakeBackdrop){
	 GLuint inTexCoord = [self.shader attribLocation:@"inTexCoord"];
	 GLuint inLightCoord = [self.shader attribLocation:@"inLightCoord"];
	 GLuint lightmap = [self.shader uniformLocation:@"lightmap"];
	 GLuint texture = [self.shader uniformLocation:@"texture"];
	 
	 glUniform1i(texture, 0);
	 glUniform1i(lightmap, 1);
	 glEnableVertexAttribArray(inTexCoord);
	 glEnableVertexAttribArray(inLightCoord);
	 }*/
	
	/*#if defined(DEBUG)
	 if(![self.shader validate]){
	 NSLog(@"Failed to validate program: %d", self.shader.program);
	 return;
	 }
	 #endif*/
	//}
	
	if((self.surfFlags & PF_Invisible) != PF_Invisible){
		glBindVertexArrayOES(self.vao);
		
		GLuint matrix = [self.shader uniformLocation:@"modelViewProjection"];
		float *mat = (float *)[[state valueForKey:@"matrix"] unsignedIntValue];
		glUniformMatrix4fv(matrix, 1, GL_FALSE, mat);
		[state setValue:[NSNumber numberWithUnsignedInt:(unsigned int)mat] forKey:@"matrix"];
		
		[self.shader use];
		
		if([[state valueForKey:@"texture"] unsignedIntValue] != self.tex.glTex){
			[self.tex bind:0];
			[state setValue:[NSNumber numberWithUnsignedInt:self.tex.glTex] forKey:@"texture"];
		}
		
		if([[state valueForKey:@"lightMap"] unsignedIntValue] != self.lightMap.glTex){
			[self.lightMap bind:1];
			[state setValue:[NSNumber numberWithUnsignedInt:self.lightMap.glTex] forKey:@"lightMap"];
		}
		/*GLuint position = [self.shader attribLocation:@"position"];
		 glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
		 glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, self.strideLength*sizeof(GLfloat), NULL);*/
		
		//if((self.surfFlags & PF_FakeBackdrop) == PF_FakeBackdrop){
		//	GLuint cubeMap = [[state valueForKey:@"cubeMap"] unsignedIntValue];
		//	if(cubeMap != 0){
		//GLuint camPos = [self.shader uniformLocation:@"camPos"];
		
		//vec3 camPosition = *(vec3 *)[[state valueForKey:@"camPos"] unsignedIntValue];
		
		//glUniform3f(camPos, camPosition.x, camPosition.y, camPosition.z);
		
		/*		if([[state valueForKey:@"texture"] unsignedIntValue] != cubeMap){
		 glActiveTexture(GL_TEXTURE0);
		 glBindTexture(GL_TEXTURE_CUBE_MAP, cubeMap);
		 [state setValue:[NSNumber numberWithUnsignedInt:cubeMap] forKey:@"texture"];
		 }*/
		//	}
		/*}else if(self.shader != nil){
		 GLuint inTexCoord = [self.shader attribLocation:@"inTexCoord"];
		 GLuint inLightCoord = [self.shader attribLocation:@"inLightCoord"];
		 
		 glVertexAttribPointer(inTexCoord, 2, GL_FLOAT, GL_FALSE, 7*sizeof(GLfloat), (void *)(3*sizeof(GLfloat)));
		 glVertexAttribPointer(inLightCoord, 2, GL_FLOAT, GL_FALSE, 7*sizeof(GLfloat), (void *)(5*sizeof(GLfloat)));
		 
		 if([[state valueForKey:@"texture"] unsignedIntValue] != self.tex.glTex){
		 [self.tex bind:0];
		 [state setValue:[NSNumber numberWithUnsignedInt:self.tex.glTex] forKey:@"texture"];
		 }
		 
		 if([[state valueForKey:@"lightMap"] unsignedIntValue] != self.lightMap.glTex){
		 [self.lightMap bind:1];
		 [state setValue:[NSNumber numberWithUnsignedInt:self.lightMap.glTex] forKey:@"lightMap"];
		 }
		 }*/
		
		glDrawArrays(GL_TRIANGLE_FAN, 0, self.vertCount);
	}
	
	if(self.coPlanar){
		[self.coPlanar drawWithState:state];
	}
	if(self.front){
		[self.front drawWithState:state];
	}
	if(self.back){
		[self.back drawWithState:state];
	}
}

- (void)dealloc{
	if(vbo_){
		glDeleteBuffers(1, &vbo_);
		vbo_ = NULL;
	}
	if(vao_){
		glDeleteVertexArraysOES(1, &vao_);
		vao_ = NULL;
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
	[super dealloc];
}

@end
