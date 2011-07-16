//
//  UNRMesh.c
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "UNRMesh.h"

UNRMesh *UNRMeshCreate(NSMutableDictionary *lodMesh, int nameIndex){
	UNRMesh *mesh = malloc(sizeof(UNRMesh));
	
	mesh->vbos = NULL;
	mesh->nameIndex = nameIndex;
	
	NSMutableArray *faces = [lodMesh valueForKey:@"faces"];
	NSMutableArray *wedges = [lodMesh valueForKey:@"wedges"];
	NSMutableArray *textures = [lodMesh valueForKey:@"textures"];
	NSMutableArray *materials = [lodMesh valueForKey:@"materials"];
	
	if([materials count] > 0){
		printf("oh's noes!\n");
	}
	
	float *data = calloc([faces count], sizeof(float)*4);
	
	for(int i = 0; i < [faces count]; i++){
		NSMutableDictionary *face = [faces objectAtIndex:i];
		int vertIndex1 = [[face valueForKey:@"wedgeIndex1"] intValue];
		int vertIndex2 = [[face valueForKey:@"wedgeIndex2"] intValue];
		int vertIndex3 = [[face valueForKey:@"wedgeIndex3"] intValue];
		int materialIndex = [[face valueForKey:@"materialIndex"] intValue];
	}
	
	return mesh;
}

void UNRMeshDraw(UNRMesh *mesh, Matrix3D mat, UNRFrustum frustum){
	
}

void UNRMeshDelete(UNRMesh *mesh){
	
}