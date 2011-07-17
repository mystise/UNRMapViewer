//
//  UNRMesh.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "Matrix3D.h"
#import "Vector4D.h"
#import "Vector3D.h"
#import "Vector2D.h"
#import "UNRFrustum.h"
#import "UNRTexture.h"
#import "UNRBoundingBox.h"
#import "UNRShader.h"

typedef struct{
	GLuint **vbos; //[frame][texture]
	GLuint **vaos; //[frame][texture]
	int nameIndex;
	UNRTexture **tex; //[texture]
	Vector3D rotation;
	Vector3D scale;
	UNRBoundingBox *box;
	UNRShader *shader;
	int frameCount, texCount;
	int *vertCount; //[texture]
	float frame, frameRate;
	int vertPerFrame;
}UNRMesh;

UNRMesh *UNRMeshCreate(NSMutableDictionary *lodMesh, int nameIndex, int animIndex);

void UNRMeshUpdate(UNRMesh *mesh, float dt);
void UNRMeshDraw(UNRMesh *mesh, Matrix3D mat, UNRFrustum frustum);

void UNRMeshDelete(UNRMesh *mesh);