//
//  UNRTextureExporter.m
//  UNRTextureExporter
//
//  Created by Adalynn Dudney on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRTextureExporter.h"
#import "UNRProperty.h"

@implementation UNRTextureExporter

- (color *)glDataFromTexture:(UNRExport *)obj withFile:(UNRFile *)file{
	int format = 0;
	DataManager *manager = [[DataManager alloc] initWithFileData:[[[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"mipMap"]];
	int width = [[[[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"width"] intValue];
	int height = [[[[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"height"] intValue];
	NSArray *palette;
	
	for(UNRProperty *prop in [obj.objectData valueForKey:@"props"]){
		DataManager *manager = [[DataManager alloc] initWithFileData:prop.data];
		if([[prop.name.string lowercaseString] isEqualToString:@"format"]){
			format = [manager loadByte];
		}else if([[prop.name.string lowercaseString] isEqualToString:@"palette"]){
			UNRExport *obj = [file resolveObjectReference:[UNRFile readCompactIndex:manager]];
			palette = [obj.objectData valueForKey:@"palette"];
		}
		[manager release];
	}
	
	color *cData = calloc(width*height, sizeof(color));
	//stored width first
	
	if(format == 0){
		//paletted
		for(int i = 0; i < width; i++){
            for(int j = 0; j < height; j++){
                Byte index = [manager loadByte];
				NSNumber *colorR = [[palette objectAtIndex:index] valueForKey:@"red"];
				NSNumber *colorG = [[palette objectAtIndex:index] valueForKey:@"green"];
				NSNumber *colorB = [[palette objectAtIndex:index] valueForKey:@"blue"];
				NSNumber *colorA = [[palette objectAtIndex:index] valueForKey:@"alpha"];
                cData[j*width + i] = (color){[colorR intValue], [colorG intValue], [colorB intValue], [colorA intValue]};
            }
        }
	}else{
		printf("Un-paletted textures are currently unsupported.\n");
	}
	return cData;
}

@end
