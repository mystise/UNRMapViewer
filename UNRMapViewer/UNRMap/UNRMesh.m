//
//  UNRMesh.c
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "UNRMesh.h"

UNRMesh *UNRMeshCreate(NSMutableDictionary *lodMesh){
	UNRMesh *mesh = malloc(sizeof(UNRMesh));
	
	return mesh;
}

void UNRMeshDraw(UNRMesh *mesh, Matrix3D mat, UNRFrustum frustum){
	
}

void UNRMeshDelete(UNRMesh *mesh){
	
}