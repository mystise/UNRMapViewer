//
//  UNRBoundingBox.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Vector3D.h"
#import "Vector4D.h"
#import "Matrix3D.h"
#import "UNRFrustum.h"

typedef enum{
	C_Out = -1,
	C_In = 0,
	C_Part = 1
}CollType;

@interface UNRBoundingBox : NSObject {
    Vector3D points[8];
}

- (id)initWithBox:(NSMutableDictionary *)box;

- (CollType)classify:(UNRFrustum)frustum;

@end
