//
//  Vector3D.c
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Vector3D.h"

Vector3D Vector3DCreateEmpty(){
	Vector3D retVec;
	retVec.x = 0.0f;
	retVec.y = 0.0f;
	retVec.z = 0.0f;
	return retVec;
}

Vector3D Vector3DCreate(float x, float y, float z){
	Vector3D retVec;
	retVec.x = x;
	retVec.y = y;
	retVec.z = z;
	return retVec;
}

Vector3D Vector3DCreateWithDictionary(NSMutableDictionary *vec){
	return Vector3DCreate([[vec valueForKey:@"x"] floatValue], [[vec valueForKey:@"y"] floatValue], [[vec valueForKey:@"z"] floatValue]);
}

float Vector3DMagnitude(Vector3D vec){
	return sqrtf(vec.x*vec.x + vec.y*vec.y + vec.z*vec.z);
}

Vector3D Vector3DAdd(Vector3D vec1, Vector3D vec2){
	return Vector3DCreate(vec1.x + vec2.x, vec1.y + vec2.y, vec1.z + vec2.z);
}

Vector3D Vector3DSubtract(Vector3D vec1, Vector3D vec2){
	return Vector3DCreate(vec1.x - vec2.x, vec1.y - vec2.y, vec1.z - vec2.z);
}

Vector3D Vector3DMultiply(Vector3D vec, float scale){
	return Vector3DCreate(vec.x*scale, vec.y*scale, vec.z*scale);
}

float Vector3DDot(Vector3D vec1, Vector3D vec2){
	return vec1.x*vec2.x + vec1.y*vec2.y + vec1.z*vec2.z;
}

Vector3D Vector3DCross(Vector3D vec1, Vector3D vec2){
	return Vector3DCreate(vec1.y*vec2.z - vec1.z*vec2.y, vec1.z*vec2.x - vec1.x*vec2.z, vec1.x*vec2.y - vec1.y*vec2.x);
}

Vector3D Vector3DDivide(Vector3D vec, float scale){
	return Vector3DCreate(vec.x/scale, vec.y/scale, vec.z/scale);
}

Vector3D Vector3DNegation(Vector3D vec){
	return Vector3DCreate(-vec.x, -vec.y, -vec.z);
}

Vector3D Vector3DNormalize(Vector3D vec){
	return Vector3DDivide(vec, Vector3DMagnitude(vec));
}

void Vector3DAddEqual(Vector3D *vec1, Vector3D vec2){
	*vec1 = Vector3DAdd(*vec1, vec2);
}

void Vector3DSubEqual(Vector3D *vec1, Vector3D vec2){
	*vec1 = Vector3DSubtract(*vec1, vec2);
}

void Vector3DMultEqual(Vector3D *vec, float scale){
	*vec = Vector3DMultiply(*vec, scale);
}

void Vector3DDivEqual(Vector3D *vec, float scale){
	*vec = Vector3DDivide(*vec, scale);
}

void Vector3DNormalizeEqual(Vector3D *vec){
	*vec = Vector3DNormalize(*vec);
}