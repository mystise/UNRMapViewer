//
//  UNRFrustum.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRFrustum.h"

void UNRFrustumCreate(UNRFrustum frustum, Matrix3D matrix){
	Vector4D plane;
	
	//right
	plane.x = matrix[3] - matrix[0];
	plane.y = matrix[7] - matrix[4];
	plane.z = matrix[11] - matrix[8];
	plane.w = matrix[15] - matrix[12];
	plane.w = -plane.w;
	//plane = Vector4DPlaneNormalize(plane);
	frustum[0] = plane;
	//left
	plane.x = matrix[3] + matrix[0];
	plane.y = matrix[7] + matrix[4];
	plane.z = matrix[11] + matrix[8];
	plane.w = matrix[15] + matrix[12];
	plane.w = -plane.w;
	//plane = Vector4DPlaneNormalize(plane);
	frustum[1] = plane;
	//bottom
	plane.x = matrix[3] + matrix[1];
	plane.y = matrix[7] + matrix[5];
	plane.z = matrix[11] + matrix[9];
	plane.w = matrix[15] + matrix[13];
	plane.w = -plane.w;
	//plane = Vector4DNormalize(plane);
	frustum[2] = plane;
	//top
	plane.x = matrix[3] - matrix[1];
	plane.y = matrix[7] - matrix[5];
	plane.z = matrix[11] - matrix[9];
	plane.w = matrix[15] - matrix[13];
	plane.w = -plane.w;
	//plane = Vector4DNormalize(plane);
	frustum[3] = plane;
	//far
	plane.x = matrix[3] - matrix[2];
	plane.y = matrix[7] - matrix[6];
	plane.z = matrix[11] - matrix[10];
	plane.w = matrix[15] - matrix[14];
	plane.w = -plane.w;
	//plane = Vector4DNormalize(plane);
	frustum[4] = plane;
	//near
	plane.x = matrix[3] + matrix[2];
	plane.y = matrix[7] + matrix[6];
	plane.z = matrix[11] + matrix[10];
	plane.w = matrix[15] + matrix[14];
	plane.w = -plane.w;
	//plane = Vector4DNormalize(plane);
	frustum[5] = plane;
}