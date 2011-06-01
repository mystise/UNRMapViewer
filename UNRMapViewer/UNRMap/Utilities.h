//
//  Utilities.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSMutableDictionary *vector;

typedef struct{
	float x, y, z;
}vec3;

vec3 vec3Create(vector vec);

vec3 vec3Add(vec3 v1, vec3 v2);
vec3 vec3Sub(vec3 v1, vec3 v2);
vec3 vec3Mult(vec3 v1, float v2);
vec3 vec3Norm(vec3 v1);

float vec3Mag(vec3 v1);
float vec3Dot(vec3 v1, vec3 v2);

typedef struct{
	float x, y;
}vec2;

vec2 vec2Create(vector vec);

vec2 vec2Add(vec2 v1, vec2 v2);
vec2 vec2Sub(vec2 v1, vec2 v2);
vec2 vec2Mult(vec2 v1, float v2);
vec2 vec2Norm(vec2 v1);

float vec2Mag(vec2 v1);
float vec2Dot(vec2 v1, vec2 v2);