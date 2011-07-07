//
//  Vector4D.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#ifndef Vector4D_h
#define Vector4D_h

#import <math.h>
#import "Vector3D.h"

typedef struct{
	float x, y, z, w;
}Vector4D;

Vector4D Vector4DCreateEmpty();
Vector4D Vector4DCreate(float x, float y, float z, float w);
Vector4D Vector4DCreateWithDictionary(NSMutableDictionary *vec);
float Vector4DMagnitude(Vector4D vec);
Vector4D Vector4DAdd(Vector4D vec1, Vector4D vec2);
Vector4D Vector4DSubtract(Vector4D vec1, Vector4D vec2);
Vector4D Vector4DMultiply(Vector4D vec, float scale);
float Vector4DDot(Vector4D vec1, Vector4D vec2);
Vector4D Vector4DDivide(Vector4D vec, float scale);
Vector4D Vector4DNegation(Vector4D vec);
Vector4D Vector4DNormalize(Vector4D vec);
Vector4D Vector4DPlaneNormalize(Vector4D vec);
float Vector4DDistance(Vector4D plane, Vector3D point);
void Vector4DAddEqual(Vector4D *vec1, Vector4D vec2);
void Vector4DSubEqual(Vector4D *vec1, Vector4D vec2);
void Vector4DMultEqual(Vector4D *vec, float scale);
void Vector4DDivEqual(Vector4D *vec, float scale);
void Vector4DNormalizeEqual(Vector4D *vec);

#endif