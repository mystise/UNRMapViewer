//
//  Vector4D.c
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Vector4D.h"

Vector4D Vector4DCreateEmpty(){
	Vector4D retVec;
	retVec.x = 0.0f;
	retVec.y = 0.0f;
	retVec.z = 0.0f;
	retVec.w = 0.0f;
	return retVec;
}

Vector4D Vector4DCreate(float x, float y, float z, float w){
	Vector4D retVec;
	retVec.x = x;
	retVec.y = y;
	retVec.z = z;
	retVec.w = w;
	return retVec;
}

Vector4D Vector4DCreateWithDictionary(NSMutableDictionary *vec){
	return Vector4DCreate([[vec valueForKey:@"x"] floatValue], [[vec valueForKey:@"y"] floatValue], [[vec valueForKey:@"z"] floatValue], [[vec valueForKey:@"w"] floatValue]);
}

float Vector4DMagnitude(Vector4D vec){
	return sqrtf(vec.x*vec.x + vec.y*vec.y + vec.z*vec.z + vec.w*vec.w);
}

Vector4D Vector4DAdd(Vector4D vec1, Vector4D vec2){
	return Vector4DCreate(vec1.x + vec2.x, vec1.y + vec2.y, vec1.z + vec2.z, vec1.w + vec2.w);
}

Vector4D Vector4DSubtract(Vector4D vec1, Vector4D vec2){
	return Vector4DCreate(vec1.x - vec2.x, vec1.y - vec2.y, vec1.z - vec2.z, vec1.w - vec2.w);
}

Vector4D Vector4DMultiply(Vector4D vec, float scale){
	return Vector4DCreate(vec.x*scale, vec.y*scale, vec.z*scale, vec.w*scale);
}

float Vector4DDot(Vector4D vec1, Vector4D vec2){
	return vec1.x*vec2.x + vec1.y*vec2.y + vec1.z*vec2.z + vec1.w*vec2.w;
}

Vector4D Vector4DDivide(Vector4D vec, float scale){
	return Vector4DCreate(vec.x/scale, vec.y/scale, vec.z/scale, vec.w/scale);
}

Vector4D Vector4DNegation(Vector4D vec){
	return Vector4DCreate(-vec.x, -vec.y, -vec.z, -vec.w);
}

Vector4D Vector4DNormalize(Vector4D vec){
	return Vector4DDivide(vec, Vector4DMagnitude(vec));
}

Vector4D Vector4DPlaneNormalize(Vector4D vec){
	float mag = sqrtf(vec.x*vec.x + vec.y*vec.y + vec.z*vec.z);
	Vector4D retVec;
	retVec.x = vec.x/mag;
	retVec.y = vec.y/mag;
	retVec.z = vec.z/mag;
	retVec.w = vec.w;
	return retVec;
}

float Vector4DDistance(Vector4D plane, Vector3D point){
	return plane.x*point.x + plane.y*point.y + plane.z*point.z - plane.w;
}

void Vector4DAddEqual(Vector4D *vec1, Vector4D vec2){
	*vec1 = Vector4DAdd(*vec1, vec2);
}

void Vector4DSubEqual(Vector4D *vec1, Vector4D vec2){
	*vec1 = Vector4DSubtract(*vec1, vec2);
}

void Vector4DMultEqual(Vector4D *vec, float scale){
	*vec = Vector4DMultiply(*vec, scale);
}

void Vector4DDivEqual(Vector4D *vec, float scale){
	*vec = Vector4DDivide(*vec, scale);
}

void Vector4DNormalizeEqual(Vector4D *vec){
	*vec = Vector4DNormalize(*vec);
}