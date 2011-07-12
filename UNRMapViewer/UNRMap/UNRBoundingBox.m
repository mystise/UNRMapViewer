//
//  UNRBoundingBox.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRBoundingBox.h"

@implementation UNRBoundingBox

- (id)initWithBox:(NSMutableDictionary *)box{
	self = [super init];
	if(self){
		Vector3D min = Vector3DCreateWithDictionary([box valueForKey:@"min"]);
		Vector3D max = Vector3DCreateWithDictionary([box valueForKey:@"max"]);
		
		points[0] = Vector3DCreate(min.x, min.y, min.z);
		points[1] = Vector3DCreate(min.x, min.y, max.z);
		points[2] = Vector3DCreate(min.x, max.y, min.z);
		points[3] = Vector3DCreate(min.x, max.y, max.z);
		points[4] = Vector3DCreate(max.x, min.y, min.z);
		points[5] = Vector3DCreate(max.x, min.y, max.z);
		points[6] = Vector3DCreate(max.x, max.y, min.z);
		points[7] = Vector3DCreate(max.x, max.y, max.z);
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
	
	//TODO: implement actual frustum culling
	int planeCount = 0;
	
	for(int i = 0; i < 6; i++){
		float pointDot0 = Vector4DDistance(frustum[i], points[0]);
		float pointDot1 = Vector4DDistance(frustum[i], points[1]);
		float pointDot2 = Vector4DDistance(frustum[i], points[2]);
		float pointDot3 = Vector4DDistance(frustum[i], points[3]);
		float pointDot4 = Vector4DDistance(frustum[i], points[4]);
		float pointDot5 = Vector4DDistance(frustum[i], points[5]);
		float pointDot6 = Vector4DDistance(frustum[i], points[6]);
		float pointDot7 = Vector4DDistance(frustum[i], points[7]);
		
		if(pointDot0 <= 0.0f && pointDot1 <= 0.0f && pointDot2 <= 0.0f && pointDot3 <= 0.0f &&
		   pointDot4 <= 0.0f && pointDot5 <= 0.0f && pointDot6 <= 0.0f && pointDot7 <= 0.0f){
			return C_Out;
		}else if(pointDot0 > 0.0f && pointDot1 > 0.0f && pointDot2 > 0.0f && pointDot3 > 0.0f &&
				 pointDot4 > 0.0f && pointDot5 > 0.0f && pointDot6 > 0.0f && pointDot7 > 0.0f){
			planeCount += 1;
		}else{
			return C_Part;
		}
	}
	
	if(planeCount == 6){
		return C_In;
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
