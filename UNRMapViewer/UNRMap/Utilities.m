//
//  Utilities.c
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Utilities.h"

vec3 vec3Create(vector vec){
	return (vec3){[[vec valueForKey:@"x"] floatValue],
		[[vec valueForKey:@"y"] floatValue],
		[[vec valueForKey:@"z"] floatValue]};
}

vec3 vec3Add(vec3 v1, vec3 v2){
	return (vec3){v1.x + v2.x, v1.y + v2.y, v1.z + v2.z};
}

vec3 vec3Sub(vec3 v1, vec3 v2){
	return (vec3){v1.x - v2.x, v1.y - v2.y, v1.z - v2.z};
}

vec3 vec3Mult(vec3 v1, float s){
	return (vec3){v1.x * s, v1.y * s, v1.z * s};
}

vec3 vec3Norm(vec3 v1){
	float mag = vec3Mag(v1);
	if(mag != 0){
		return (vec3){v1.x/mag, v1.y/mag, v1.z/mag};
	}
	return (vec3){0.0f, 0.0f, 0.0f};
}

float vec3Mag(vec3 v1){
	return sqrtf(v1.x*v1.x + v1.y*v1.y + v1.z*v1.z);
}

float vec3Dot(vec3 v1, vec3 v2){
	return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
}


vec2 vec2Create(vector vec){
	return (vec2){[[vec valueForKey:@"x"] floatValue],
		[[vec valueForKey:@"y"] floatValue]};
}

vec2 vec2Add(vec2 v1, vec2 v2){
	return (vec2){v1.x + v2.x, v1.y + v2.y};
}

vec2 vec2Sub(vec2 v1, vec2 v2){
	return (vec2){v1.x - v2.x, v1.y - v2.y};
}

vec2 vec2Mult(vec2 v1, float s){
	return (vec2){v1.x * s, v1.y * s};
}

vec2 vec2Norm(vec2 v1){
	float mag = vec2Mag(v1);
	if(mag != 0){
		return (vec2){v1.x/mag, v1.y/mag};
	}
	return (vec2){0.0f, 0.0f};
}

float vec2Mag(vec2 v1){
	return sqrtf(v1.x*v1.x + v1.y*v1.y);
}

float vec2Dot(vec2 v1, vec2 v2){
	return v1.x*v2.x + v1.y*v2.y;
}