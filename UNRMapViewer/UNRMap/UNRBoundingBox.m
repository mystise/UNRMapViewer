//
//  UNRBoundingBox.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRBoundingBox.h"

@implementation UNRBoundingBox

@synthesize min = min_, max = max_;

- (id)initWithBox:(NSMutableDictionary *)box{
	self = [super init];
	if(self){
		self.min = Vector3DCreateWithDictionary([box valueForKey:@"min"]);
		self.max = Vector3DCreateWithDictionary([box valueForKey:@"max"]);
	}
	return self;
}

- (CollType)classify:(UNRFrustum)frustum{
	//Implement the frustum cull
	//go through each plane,
	//	record which of the points is in each plane
	//end plane iter
	//if both points are inside all planes
	//	return C_In
	//else if both points are on opposite sides of one of the planes
	//	return C_Part
	//else
	//	return C_Out
	//end
	/*Vector4D frustumPlanes[6];
	
	Vector4D plane;
	
	//right
	plane.x = frustum[3] - frustum[0];
	plane.y = frustum[7] - frustum[4];
	plane.z = frustum[11] - frustum[8];
	plane.w = frustum[15] - frustum[12];
	plane.w = -plane.w;
	plane = Vector4DPlaneNormalize(plane);
	frustumPlanes[0] = plane;
	//left
	plane.x = frustum[3] + frustum[0];
	plane.y = frustum[7] + frustum[4];
	plane.z = frustum[11] + frustum[8];
	plane.w = frustum[15] + frustum[12];
	plane.w = -plane.w;
	plane = Vector4DPlaneNormalize(plane);
	frustumPlanes[1] = plane;
	//bottom
	plane.x = frustum[3] + frustum[1];
	plane.y = frustum[7] + frustum[5];
	plane.z = frustum[11] + frustum[9];
	plane.w = frustum[15] + frustum[13];
	plane.w = -plane.w;
	plane = Vector4DNormalize(plane);
	frustumPlanes[2] = plane;
	//top
	plane.x = frustum[3] - frustum[1];
	plane.y = frustum[7] - frustum[5];
	plane.z = frustum[11] - frustum[9];
	plane.w = frustum[15] - frustum[13];
	plane.w = -plane.w;
	plane = Vector4DNormalize(plane);
	frustumPlanes[3] = plane;
	//far
	plane.x = frustum[3] - frustum[2];
	plane.y = frustum[7] - frustum[6];
	plane.z = frustum[11] - frustum[10];
	plane.w = frustum[15] - frustum[14];
	plane.w = -plane.w;
	plane = Vector4DNormalize(plane);
	frustumPlanes[4] = plane;
	//near
	plane.x = frustum[3] + frustum[2];
	plane.y = frustum[7] + frustum[6];
	plane.z = frustum[11] + frustum[10];
	plane.w = frustum[15] + frustum[14];
	plane.w = -plane.w;
	plane = Vector4DNormalize(plane);
	frustumPlanes[5] = plane;*/
//	float planeDotMin = Vector4DDistance(rightPlaneNormal, self.min);
	/*Vector3D viewDir = Vector3DNegation(Vector3DCreate(frustum[8], frustum[9], frustum[10]));
	 Vector3D camPos = Vector3DCreate(frustum[12], frustum[13], frustum[14]);
	 float dot1 = Vector3DDot(viewDir, Vector3DSubtract(self.min, camPos));
	 float dot2 = Vector3DDot(viewDir, Vector3DSubtract(self.max, camPos));
	 if(dot1 < 0.0f && dot2 < 0.0f){
	 return C_In;
	 }else if(dot1 < 0.0f || dot2 < 0.0f){
	 return C_Part;
	 }
	 return C_Out;*/
	
	int planeCount = 0;
	
	for(int i = 0; i < 6; i++){
		//if both are out
		//	return C_Out
		//else if both are in
		//	increment plane count twice
		//else
		//	increment plane count once
		//endif
		float minDot = Vector4DDistance(frustum[i], self.min);
		float maxDot = Vector4DDistance(frustum[i], self.max);
		
		if(minDot < 0.0f && maxDot < 0.0f){
			//return C_Out;
		}else if(minDot > 0.0f && maxDot > 0.0f){
			planeCount += 1;
		}else{
			//return C_Part;
		}
	}
	
	if(planeCount == 6){
		return C_In;
	}else if(planeCount != 0){
		return C_Part;
	}
	
	return C_Out;
	
	/*int planeCount = 0;
	
	for(int i = 0; i < 6; i++){
		//if both are out
		//	return C_Out
		//else if both are in
		//	increment plane count twice
		//else
		//	increment plane count once
		//endif
		float minDot = Vector4DDistance(frustum[i], self.min);
		float maxDot = Vector4DDistance(frustum[i], self.max);
		
		if(minDot < 0.0f && maxDot < 0.0f){
			return C_Out;
		}else if(minDot > 0.0f && maxDot > 0.0f){
			planeCount += 1;
		}else{
			return C_Part;
		}
	}
	
	if(planeCount == 6){
		return C_In;
	}
	
	return C_Part;*/
}

@end
