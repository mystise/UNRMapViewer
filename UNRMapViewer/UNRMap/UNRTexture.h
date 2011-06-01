//
//  UNRTextureExporter.h
//  UNRTextureExporter
//
//  Created by Adalynn Dudney on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Unreal.h"

typedef struct{
	Byte r, g, b, a;
}color;

@interface UNRTexture : NSObject {
	
}

+ (id)textureWithObject:(UNRExport *)obj withFile:(UNRFile *)file;

@property(nonatomic, assign) color *tex;
@property(nonatomic, assign) int width, height;

@end
