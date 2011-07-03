//
//  UNRBoundingBox.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Vector3D.h"
#import "Matrix3D.h"

typedef enum{
	C_Out,
	C_In,
	C_Part
}CollType;

@interface UNRBoundingBox : NSObject {
    
}

- (id)initWithBox:(NSMutableDictionary *)box;

- (CollType)classify:(Matrix3D)frustum;

@property(nonatomic, assign) Vector3D min, max;

@end
