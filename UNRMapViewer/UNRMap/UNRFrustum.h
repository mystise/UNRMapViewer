//
//  UNRFrustum.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector4D.h"
#import "Matrix3D.h"

typedef Vector4D UNRFrustum[6];

void UNRFrustumCreate(UNRFrustum frustum, Matrix3D matrix);