//
//  Matrix3D.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#ifndef Matrix3D_h
#define Matrix3D_h

#define DEGREES_TO_RADIANS(x) ((x) / 180.0f * M_PI)
#define RADIANS_TO_DEGREES(x) ((x) / M_PI * 180.0f)

#import <math.h>

typedef float Matrix3D[16];

void Matrix3DIdentity(Matrix3D mat);
void Matrix3DCopy(Matrix3D mat, Matrix3D res);
void Matrix3DTranspose(Matrix3D mat);
void Matrix3DMultiply(Matrix3D mat1, Matrix3D mat2, Matrix3D res);
void Matrix3DMultEqual(Matrix3D mat1, Matrix3D mat2);
void Matrix3DRotateX(Matrix3D mat, float degrees);
void Matrix3DRotateY(Matrix3D mat, float degrees);
void Matrix3DRotateZ(Matrix3D mat, float degrees);
void Matrix3DRotate(Matrix3D mat, float degrees, float x, float y, float z);
void Matrix3DTranslate(Matrix3D mat, float x, float y, float z);
void Matrix3DScale(Matrix3D mat, float x, float y, float z);
void Matrix3DUniformScale(Matrix3D mat, float s);
void Matrix3DOrthographic(Matrix3D mat, float left, float right, float bottom, float top, float near, float far);
void Matrix3DFrustum(Matrix3D mat, float left, float right, float bottom, float top, float near, float far);
void Matrix3DPerspective(Matrix3D mat, float fov, float near, float far, float aspect);

#endif