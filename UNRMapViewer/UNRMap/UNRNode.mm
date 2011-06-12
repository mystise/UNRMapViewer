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

/*verts = verts_, vertCount = vertCount_, texCoords = texCoords_, */
@synthesize vbo = vbo_, vertCount = vertCount_, normal = normal_, tex = tex_, plane = plane_, front = front_, back = back_, coPlanar = coPlanar_, surfFlags = surfFlags_, shader = shader_;

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
				
				[self.shader use];
				
				GLuint position = [self.shader attribLocation:@"position"];
				GLuint inTexCoord = [self.shader attribLocation:@"inTexCoord"];
				GLuint texture = [self.shader uniformLocation:@"texture"];
				
				glUniform1i(texture, 0);
				glEnableVertexAttribArray(position);
				glEnableVertexAttribArray(inTexCoord);
			}
		}
		
		if(!(self.surfFlags & PF_Invisible)){
			vec3 pBase = vec3Create([[points objectAtIndex:[[surf valueForKey:@"pBase"] intValue]] valueForKey:@"point"]);
			self.normal = vec3Create([[vectors objectAtIndex:[[surf valueForKey:@"vNormal"] intValue]] valueForKey:@"vector"]);
			vec3 vTextureU = vec3Create([[vectors objectAtIndex:[[surf valueForKey:@"vTextureU"] intValue]] valueForKey:@"vector"]);
			vec3 vTextureV = vec3Create([[vectors objectAtIndex:[[surf valueForKey:@"vTextureV"] intValue]] valueForKey:@"vector"]);
			short panU = [[surf valueForKey:@"panU"] shortValue];
			short panV = [[surf	valueForKey:@"panV"] shortValue];
			
			int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
			int vertCount = [[node valueForKey:@"vertCount"] intValue];
			self.vertCount = vertCount;
			vec3 *verts = (vec3 *)calloc(vertCount, sizeof(vec3));
			vec2 *texCoords = (vec2 *)calloc(vertCount, sizeof(vec2));
			for(int i = iVertPool; i < vertCount+iVertPool; i++){
				vec3 coord = vec3Create([[points objectAtIndex:[[[verticies objectAtIndex:i] valueForKey:@"pVertex"] intValue]] valueForKey:@"point"]);
				verts[i-iVertPool] = coord;
				vec3 disp = vec3Sub(coord, pBase);
				vec2 texCoord = {0.0f, 0.0f};
				texCoord.x = (vec3Dot(disp, vTextureU) + panU)/self.tex.width;
				texCoord.y = (vec3Dot(disp, vTextureV) + panV)/self.tex.height;
				texCoords[i-iVertPool] = texCoord;
			}
			
			GLfloat *texAndVerts = (GLfloat *)calloc(vertCount*5, sizeof(GLfloat));
			
			int index = 0;
			for(int i = 0; i < vertCount; i++){
				texAndVerts[index]   = verts[i].x;
				texAndVerts[index+1] = verts[i].y;
				texAndVerts[index+2] = verts[i].z;
				texAndVerts[index+3] = texCoords[i].x;
				texAndVerts[index+4] = texCoords[i].y;
				index += 5;
			}
			
			GLuint vbo;
			glGenBuffers(1, &vbo);
			self.vbo = vbo;
			glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
			glBufferData(GL_ARRAY_BUFFER, vertCount*sizeof(GLfloat)*5, texAndVerts, GL_STATIC_DRAW);
			
			free(texCoords);
			free(verts);
			free(texAndVerts);
		}
		
		int frontInd = [[node valueForKey:@"iFront"] intValue];
		int backInd = [[node valueForKey:@"iBack"] intValue];
		int planeInd = [[node valueForKey:@"iPlane"] intValue];
		
		int lightIndex = [[surf valueForKey:@"iLightMap"] intValue];
		if(lightIndex != -1 && !(self.surfFlags & PF_Unlit)){
			NSMutableDictionary *lightMap = [[model valueForKey:@"lightMaps"] objectAtIndex:lightIndex];
			NSData *lightData = [model valueForKey:@"LightBits"];
			int uSize = [[lightMap valueForKey:@"uClamp"] intValue];
			int vSize = [[lightMap valueForKey:@"vClamp"] intValue];
			int dataOffset = [[lightMap valueForKey:@"dataOffset"] intValue];
			printf("LightMap: node:%i lightMap:%i\n", nodeNum, [[surf valueForKey:@"iLightMap"] intValue]);
			printf("	coplanar:%i back:%i front:%i\n", planeInd, backInd, frontInd);
			printf("	texture:%s\n", [exp.name.string UTF8String]);
			printf("	uSize:%i vSize:%i dataOffset:%i\n", uSize, vSize, dataOffset);
			if(dataOffset < [lightData length]){
				//uSize*vSize + dataOffset
				//[lightData subdataWithRange:NSMakeRange(dataOffset, uSize*vSize)];
			}else{
				printf("		Failed!!!\n");
			}
			
			//create the lightmap
		}
		
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

- (void)drawWithMatrix:(Matrix3D &)mat{
	NSMutableDictionary *state = [NSMutableDictionary dictionary];
	[self.shader use];
	[state setValue:[NSNumber numberWithUnsignedInt:self.shader.program] forKey:@"shader"];
	
	GLuint matrix = [self.shader uniformLocation:@"modelViewProjection"];
	glUniformMatrix4fv(matrix, 1, GL_FALSE, mat.glData());
	[state setValue:[NSNumber numberWithUnsignedInt:(unsigned int)mat.glData()] forKey:@"matrix"];
	
	[self drawWithState:state];
}

- (void)drawWithState:(NSMutableDictionary *)state{
	if(self.shader.program != [[state valueForKey:@"shader"] unsignedIntValue] && self.shader != nil){
		[self.shader use];
		[state setValue:[NSNumber numberWithUnsignedInt:self.shader.program] forKey:@"shader"];
		
		GLuint matrix = [self.shader uniformLocation:@"modelViewProjection"];
		float *mat = (float *)[[state valueForKey:@"matrix"] unsignedIntValue];
		glUniformMatrix4fv(matrix, 1, GL_FALSE, mat);
		[state setValue:[NSNumber numberWithUnsignedInt:(unsigned int)mat] forKey:@"matrix"];
		//rebind any other neccessary state
	}
	
	if((self.surfFlags & PF_Invisible) == PF_Invisible){
		//do nothing
	}else if(self.shader != nil){
		/*if((self.surfFlags & PF_FakeBackdrop) == PF_FakeBackdrop){
		 //bind to cube-map, draw self
		 draw = NO;
		 }*/
		GLuint position = [self.shader attribLocation:@"position"];
		GLuint inTexCoord = [self.shader attribLocation:@"inTexCoord"];
		
		glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
		glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, 5*sizeof(GLfloat), NULL);
		glVertexAttribPointer(inTexCoord, 2, GL_FLOAT, GL_FALSE, 5*sizeof(GLfloat), (void *)(3*sizeof(GLfloat)));
		
		if([[state valueForKey:@"texture"] unsignedIntValue] != self.tex.glTex){
			[self.tex bind:0];
			[state setValue:[NSNumber numberWithUnsignedInt:self.tex.glTex] forKey:@"texture"];
		}
		
/*#if defined(DEBUG)
		if(![self.shader validate]){
			NSLog(@"Failed to validate program: %d", self.shader.program);
			return;
		}
#endif*/
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
