//
//  Vector3D.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#ifndef Vector3D_h
#define Vector3D_h

#import <math.h>

typedef struct{
	float x, y, z;
}Vector3D;

Vector3D Vector3DCreateEmpty();
Vector3D Vector3DCreate(float x, float y, float z);
Vector3D Vector3DCreateWithDictionary(NSMutableDictionary *vec);
float Vector3DMagnitude(Vector3D vec);
Vector3D Vector3DAdd(Vector3D vec1, Vector3D vec2);
Vector3D Vector3DSubtract(Vector3D vec1, Vector3D vec2);
Vector3D Vector3DMultiply(Vector3D vec, float scale);
float Vector3DDot(Vector3D vec1, Vector3D vec2);
Vector3D Vector3DCross(Vector3D vec1, Vector3D vec2);
Vector3D Vector3DDivide(Vector3D vec, float scale);
Vector3D Vector3DNegation(Vector3D vec);
void Vector3DAddEqual(Vector3D *vec1, Vector3D vec2);
void Vector3DSubEqual(Vector3D *vec1, Vector3D vec2);
void Vector3DMultEqual(Vector3D *vec, float scale);
void Vector3DDivEqual(Vector3D *vec, float scale);
void Vector3DNormalize(Vector3D *vec);

#endif