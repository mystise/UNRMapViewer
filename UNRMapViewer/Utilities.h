//
//  Utilities.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSMutableDictionary *vector;

vector vecAdd(vector v1, vector v2);
vector vecSub(vector v1, vector v2);
vector vecMult(vector v1, float v2);
vector vecNorm(vector v1);

float vecMag(vector v1);
float vecDot(vector v1, vector v2);