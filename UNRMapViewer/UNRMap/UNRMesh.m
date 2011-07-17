//
//  UNRMesh.c
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRMesh.h"
#import "UNRTexture.h"

typedef struct{
	float x, y, z;
	float u, v;
}UNRVertDat;

UNRMesh *UNRMeshCreate(NSMutableDictionary *lodMesh, int nameIndex, int animIndex){
	UNRMesh *mesh = malloc(sizeof(UNRMesh));
	
	mesh->vbos = NULL;
	mesh->nameIndex = nameIndex;
	
	mesh->scale = Vector3DCreateWithDictionary([lodMesh valueForKey:@"scale"]);
	//mesh->rotation = Vector3DCreateWithDictionary([lodMesh valueForKey:@"originRot"]);
	mesh->rotation.x = [[[lodMesh valueForKey:@"originRot"] valueForKey:@"yaw"] floatValue]*45/8192;
	mesh->rotation.y = [[[lodMesh valueForKey:@"originRot"] valueForKey:@"pitch"] floatValue]*45/8192;
	mesh->rotation.z = [[[lodMesh valueForKey:@"originRot"] valueForKey:@"roll"] floatValue]*45/8192;
	mesh->box = [[UNRBoundingBox alloc] initWithBox:[lodMesh valueForKey:@"meshBoundingBox"]];
	
	NSMutableArray *verts = [lodMesh valueForKey:@"verts"];
	NSMutableArray *faces = [lodMesh valueForKey:@"faces"];
	NSMutableArray *wedges = [lodMesh valueForKey:@"wedges"];
	NSMutableArray *textures = [lodMesh valueForKey:@"textures"];
	NSMutableArray *materials = [lodMesh valueForKey:@"materials"];
	
	int specialVerts = [[lodMesh valueForKey:@"specialVerts"] intValue];
	int vertsPerFrame = [[lodMesh valueForKey:@"vertsPerFrame"] intValue];
	mesh->vertPerFrame = vertsPerFrame;
	NSMutableDictionary *anim = [[lodMesh valueForKey:@"animSequences"] objectAtIndex:animIndex];
	int startFrame = [[anim valueForKey:@"startFrame"] intValue];
	
	mesh->frameCount = [[anim valueForKey:@"numFrames"] intValue];
	mesh->frameRate = 1.0f/[[anim valueForKey:@"frameRate"] floatValue];
	mesh->frame = 0.0f;
	mesh->texCount = [materials count];
	
	mesh->vertCount = calloc(mesh->texCount, sizeof(int));
	int *curVert = calloc(mesh->texCount, sizeof(int));
	
	for(NSMutableDictionary *face in faces){
		int materialIndex = [[face valueForKey:@"materialIndex"] intValue];
		
		mesh->vertCount[materialIndex] += 3;
	}
	
	mesh->tex = calloc(mesh->texCount, sizeof(UNRTexture *));
	for(int i = 0; i < mesh->texCount; i++){
		UNRExport *obj = [[textures objectAtIndex:[[[materials objectAtIndex:i] valueForKey:@"textureIndex"] intValue]] valueForKey:@"texture"];
		if(obj == nil){
			for(UNRExport *obj2 in [textures valueForKey:@"texture"]){
				if(![obj2 isKindOfClass:[NSNull class]]){
					obj = obj2;
					break;
				}
			}
		}
		if([obj isKindOfClass:[UNRImport class]]){
			UNRImport *imp = (UNRImport *)obj;
			obj = imp.obj;
		}
		mesh->tex[i] = [[UNRTexture textureWithObject:obj.objectData attributes:nil] retain];
	}
	
	UNRVertDat ***data = calloc(mesh->frameCount, sizeof(UNRVertDat **)); //[frame][texture][vertex]
	mesh->vbos = calloc(mesh->frameCount, sizeof(GLuint *));
	mesh->vaos = calloc(mesh->frameCount, sizeof(GLuint *));
	for(int i = 0; i < mesh->frameCount; i++){
		data[i] = calloc(mesh->texCount, sizeof(UNRVertDat *));
		mesh->vbos[i] = calloc(mesh->texCount, sizeof(GLuint));
		mesh->vaos[i] = calloc(mesh->texCount, sizeof(GLuint));
		glGenBuffers(mesh->texCount, mesh->vbos[i]);
		glGenVertexArraysOES(mesh->texCount, mesh->vaos[i]);
		for(int j = 0; j < mesh->texCount; j++){
			data[i][j] = calloc(mesh->vertCount[j], sizeof(UNRVertDat));
		}
	}
	
	for(int frame = startFrame; frame < mesh->frameCount+startFrame; frame++){
		for(int i = 0; i < [faces count]; i++){
			NSMutableDictionary *face = [faces objectAtIndex:i];
			UNRVertDat v1, v2, v3;
			{
				int wedgeIndex1 = [[face valueForKey:@"wedgeIndex1"] intValue];
				NSMutableDictionary *wedge1 = [wedges objectAtIndex:wedgeIndex1];
				int vertIndex = [[wedge1 valueForKey:@"vertexIndex"] intValue] + specialVerts + vertsPerFrame*frame;
				Vector3D vec = Vector3DCreateWithDictionary([[verts objectAtIndex:vertIndex] valueForKey:@"vert"]);
				v1.x = vec.x;
				v1.y = vec.y;
				v1.z = vec.z;
				v1.u = [[wedge1 valueForKey:@"s"] unsignedCharValue]/255.0f;
				v1.v = [[wedge1 valueForKey:@"t"] unsignedCharValue]/255.0f;
			}
			
			{
				int wedgeIndex2 = [[face valueForKey:@"wedgeIndex2"] intValue];
				NSMutableDictionary *wedge2 = [wedges objectAtIndex:wedgeIndex2];
				int vertIndex = [[wedge2 valueForKey:@"vertexIndex"] intValue] + specialVerts + vertsPerFrame*frame;
				Vector3D vec = Vector3DCreateWithDictionary([[verts objectAtIndex:vertIndex] valueForKey:@"vert"]);
				v2.x = vec.x;
				v2.y = vec.y;
				v2.z = vec.z;
				v2.u = [[wedge2 valueForKey:@"s"] unsignedCharValue]/255.0f;
				v2.v = [[wedge2 valueForKey:@"t"] unsignedCharValue]/255.0f;
			}
			
			{
				int wedgeIndex3 = [[face valueForKey:@"wedgeIndex3"] intValue];
				NSMutableDictionary *wedge3 = [wedges objectAtIndex:wedgeIndex3];
				int vertIndex = [[wedge3 valueForKey:@"vertexIndex"] intValue] + specialVerts + vertsPerFrame*frame;
				Vector3D vec = Vector3DCreateWithDictionary([[verts objectAtIndex:vertIndex] valueForKey:@"vert"]);
				v3.x = vec.x;
				v3.y = vec.y;
				v3.z = vec.z;
				v3.u = [[wedge3 valueForKey:@"s"] unsignedCharValue]/255.0f;
				v3.v = [[wedge3 valueForKey:@"t"] unsignedCharValue]/255.0f;
			}
			
			int materialIndex = [[face valueForKey:@"materialIndex"] intValue];
			data[frame][materialIndex][curVert[materialIndex]] = v1;
			data[frame][materialIndex][curVert[materialIndex]+1] = v2;
			data[frame][materialIndex][curVert[materialIndex]+2] = v3;
			
			curVert[materialIndex] += 3;
		}
	}
	
	mesh->shader = [[UNRShader alloc] initWithShader:@"Mesh"];
	
	for(int i = 0; i < mesh->frameCount; i++){
		for(int j = 0; j < mesh->texCount; j++){
			glBindVertexArrayOES(mesh->vaos[i][j]);
			
			[mesh->shader use];
			
			glBindBuffer(GL_ARRAY_BUFFER, mesh->vbos[i][j]);
			glBufferData(GL_ARRAY_BUFFER, mesh->vertCount[j]*sizeof(UNRVertDat), data[i][j], GL_STATIC_DRAW);
			
			GLuint position = [mesh->shader attribLocation:@"position"];
			glEnableVertexAttribArray(position);
			glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(UNRVertDat), NULL);
			
			GLuint texCoords = [mesh->shader attribLocation:@"inTexCoord"];
			glEnableVertexAttribArray(texCoords);
			glVertexAttribPointer(texCoords, 2, GL_FLOAT, GL_FALSE, sizeof(UNRVertDat), (GLvoid *)(sizeof(float)*3));
			
			GLuint texture = [mesh->shader uniformLocation:@"texture"];
			glUniform1i(texture, 5);
		}
	}
	
	for(int i = 0; i < mesh->frameCount; i++){
		for(int j = 0; j < mesh->texCount; j++){
			free(data[i][j]);
		}
		free(data[i]);
	}
	free(data);
	
	return mesh;
}

void UNRMeshUpdate(UNRMesh *mesh, float dt){
	mesh->frame += dt/mesh->frameRate;
	if((int)floorf(mesh->frame) > mesh->frameCount){
		mesh->frame = 0.0f;
	}
}

void UNRMeshDraw(UNRMesh *mesh, Matrix3D mat, UNRFrustum frustum){
	[mesh->shader use];
	GLuint matrix = [mesh->shader uniformLocation:@"modelViewProjection"];
	glUniformMatrix4fv(matrix, 1, GL_FALSE, mat);
	for(int i = 0; i < mesh->texCount; i++){
		[mesh->tex[i] bind:5];
		glBindVertexArrayOES(mesh->vaos[(int)floorf(mesh->frame)][i]);
		glDrawArrays(GL_TRIANGLES, 0, mesh->vertCount[i]);
		glBindVertexArrayOES(0);
	}
}

void UNRMeshDelete(UNRMesh *mesh){
	
}