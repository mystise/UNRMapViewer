//
//  Vector2D.c
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Vector2D.h"

Vector2D Vector2DCreateEmpty(){
	Vector2D retVec;
	retVec.x = 0.0f;
	retVec.y = 0.0f;
	return retVec;
}

Vector2D Vector2DCreate(float x, float y){
	Vector2D retVec;
	retVec.x = x;
	retVec.y = y;
	return retVec;
}

float Vector2DMagnitude(Vector2D vec){
	return sqrtf(vec.x*vec.x + vec.y*vec.y);
}

Vector2D Vector2DAdd(Vector2D vec1, Vector2D vec2){
	return Vector2DCreate(vec1.x + vec2.x, vec1.y + vec2.y);
}

Vector2D Vector2DSubtract(Vector2D vec1, Vector2D vec2){
	return Vector2DCreate(vec1.x - vec2.x, vec1.y - vec2.y);
}

Vector2D Vector2DMultiply(Vector2D vec, float scale){
	return Vector2DCreate(vec.x*scale, vec.y*scale);
}

float Vector2DDot(Vector2D vec1, Vector2D vec2){
	return vec1.x*vec2.x + vec1.y*vec2.y;
}

Vector2D Vector2DDivide(Vector2D vec, float scale){
	return Vector2DCreate(vec.x/scale, vec.y/scale);
}

Vector2D Vector2DNegation(Vector2D vec){
	return Vector2DCreate(-vec.x, -vec.y);
}

Vector2D Vector2DNormalize(Vector2D vec){
	return Vector2DDivide(vec, Vector2DMagnitude(vec));
}

void Vector2DAddEqual(Vector2D *vec1, Vector2D vec2){
	*vec1 = Vector2DAdd(*vec1, vec2);
}

void Vector2DSubEqual(Vector2D *vec1, Vector2D vec2){
	*vec1 = Vector2DSubtract(*vec1, vec2);
}

void Vector2DMultEqual(Vector2D *vec, float scale){
	*vec = Vector2DMultiply(*vec, scale);
}

void Vector2DDivEqual(Vector2D *vec, float scale){
	*vec = Vector2DDivide(*vec, scale);
}

void Vector2DNormalizeEqual(Vector2D *vec){
	*vec = Vector2DNormalize(*vec);
}