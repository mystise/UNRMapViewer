//
//  Utilities.c
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Utilities.h"

vector vecAdd(vector v1, vector v2){
	vector retVec = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					 [NSNumber numberWithFloat:[[v1 valueForKey:@"x"] floatValue] + [[v2 valueForKey:@"x"] floatValue]], @"x",
					 [NSNumber numberWithFloat:[[v1 valueForKey:@"y"] floatValue] + [[v2 valueForKey:@"y"] floatValue]], @"y",
					 [NSNumber numberWithFloat:[[v1 valueForKey:@"z"] floatValue] + [[v2 valueForKey:@"z"] floatValue]], @"z",
					 nil];
	return retVec;
}

vector vecSub(vector v1, vector v2){
	vector retVec = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					 [NSNumber numberWithFloat:[[v1 valueForKey:@"x"] floatValue] - [[v2 valueForKey:@"x"] floatValue]], @"x",
					 [NSNumber numberWithFloat:[[v1 valueForKey:@"y"] floatValue] - [[v2 valueForKey:@"y"] floatValue]], @"y",
					 [NSNumber numberWithFloat:[[v1 valueForKey:@"z"] floatValue] - [[v2 valueForKey:@"z"] floatValue]], @"z",
					 nil];
	return retVec;
}

vector vecMult(vector v1, float s){
	vector retVec = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					 [NSNumber numberWithFloat:[[v1 valueForKey:@"x"] floatValue]*s], @"x",
					 [NSNumber numberWithFloat:[[v1 valueForKey:@"y"] floatValue]*s], @"y",
					 [NSNumber numberWithFloat:[[v1 valueForKey:@"z"] floatValue]*s], @"z",
					 nil];
	return retVec;
}

vector vecNorm(vector v1){
	float mag = vecMag(v1);
	if(mag != 0){
		vector retVec = [NSMutableDictionary dictionaryWithObjectsAndKeys:
						 [NSNumber numberWithFloat:[[v1 valueForKey:@"x"] floatValue]/mag], @"x",
						 [NSNumber numberWithFloat:[[v1 valueForKey:@"y"] floatValue]/mag], @"y",
						 [NSNumber numberWithFloat:[[v1 valueForKey:@"z"] floatValue]/mag], @"z",
						 nil];
		return retVec;
	}
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithFloat:0.0f], @"x",
			[NSNumber numberWithFloat:0.0f], @"y",
			[NSNumber numberWithFloat:0.0f], @"z",
			nil];
}

float vecMag(vector v1){
	float retVal = [[v1 valueForKey:@"x"] floatValue]*[[v1 valueForKey:@"x"] floatValue] + [[v1 valueForKey:@"y"] floatValue]*[[v1 valueForKey:@"y"] floatValue] + [[v1 valueForKey:@"z"] floatValue]*[[v1 valueForKey:@"z"] floatValue];
	return sqrtf(retVal);
}

float vecDot(vector v1, vector v2){
	float retVal = [[v1 valueForKey:@"x"] floatValue]*[[v2 valueForKey:@"x"] floatValue] + [[v1 valueForKey:@"y"] floatValue]*[[v2 valueForKey:@"y"] floatValue] + [[v1 valueForKey:@"z"] floatValue]*[[v2 valueForKey:@"z"] floatValue];
	return retVal;
}