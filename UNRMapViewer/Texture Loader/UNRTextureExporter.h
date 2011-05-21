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

@interface UNRTextureExporter : NSObject {
	
}

- (color *)glDataFromTexture:(UNRExport *)obj withFile:(UNRFile *)file;

@end
