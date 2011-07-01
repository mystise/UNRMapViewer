//
//  Vector2D.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#ifndef Vector2D_h
#define Vector2D_h

#import <math.h>

typedef struct{
	float x, y;
}Vector2D;

Vector2D Vector2DCreateEmpty();
Vector2D Vector2DCreate(float x, float y);
float Vector2DMagnitude(Vector2D vec);
Vector2D Vector2DAdd(Vector2D vec1, Vector2D vec2);
Vector2D Vector2DSubtract(Vector2D vec1, Vector2D vec2);
Vector2D Vector2DMultiply(Vector2D vec, float scale);
float Vector2DDot(Vector2D vec1, Vector2D vec2);
Vector2D Vector2DDivide(Vector2D vec, float scale);
Vector2D Vector2DNegation(Vector2D vec);
void Vector2DAddEqual(Vector2D *vec1, Vector2D vec2);
void Vector2DSubEqual(Vector2D *vec1, Vector2D vec2);
void Vector2DMultEqual(Vector2D *vec, float scale);
void Vector2DDivEqual(Vector2D *vec, float scale);
void Vector2DNormalize(Vector2D *vec);

#endif