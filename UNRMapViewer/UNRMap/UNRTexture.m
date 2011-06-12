//
//  UNRTextureExporter.m
//  UNRTextureExporter
//
//  Created by Adalynn Dudney on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRTexture.h"
#import "UNRProperty.h"

@implementation UNRTexture

@synthesize width = width_, height = height_, glTex = glTex_;

+ (id)textureWithObject:(UNRExport *)obj{
	UNRTexture *tex = [[self alloc] init];
	if(tex){
		NSArray *palette = nil;
		int format = 0;
		for(UNRProperty *prop in [obj.objectData valueForKey:@"props"]){
			DataManager *manager = [[DataManager alloc] initWithFileData:prop.data];
			if([[prop.name.string lowercaseString] isEqualToString:@"format"]){
				format = [manager loadByte];
			}else if([[prop.name.string lowercaseString] isEqualToString:@"palette"]){
				UNRExport *obj = (UNRExport *)prop.object;
				palette = [obj.objectData valueForKey:@"palette"];
			}
			[manager release];
		}
		
		GLuint glTex = 0;
		glGenTextures(1, &glTex);
		tex.glTex = glTex;
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, tex.glTex);
		
		tex.width = [[[[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"width"] intValue];
		tex.height = [[[[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"height"] intValue];
		//int i = 0;
		for(int i = 0; i < [[obj.objectData valueForKey:@"mipMapCount"] intValue]; i++){
			NSMutableDictionary *texLevel = [[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:i];
			DataManager *manager = [[DataManager alloc] initWithFileData:[texLevel valueForKey:@"mipMap"]];
			
			int levelWidth = [[texLevel valueForKey:@"width"] intValue];
			int levelHeight = [[texLevel valueForKey:@"height"] intValue];
			
			color *glTexData = calloc(levelWidth*levelHeight, sizeof(color));
			//stored width first
			
			if(format == 0){ //paletted
				for(int i = 0; i < levelHeight; i++){
					for(int j = 0; j < levelWidth; j++){
						Byte index = [manager loadByte];
						NSNumber *colorR = [[palette objectAtIndex:index] valueForKey:@"red"];
						NSNumber *colorG = [[palette objectAtIndex:index] valueForKey:@"green"];
						NSNumber *colorB = [[palette objectAtIndex:index] valueForKey:@"blue"];
						NSNumber *colorA = [[palette objectAtIndex:index] valueForKey:@"alpha"];
						glTexData[i*levelWidth + j] = (color){[colorR unsignedCharValue], [colorG unsignedCharValue], [colorB unsignedCharValue], [colorA unsignedCharValue]};
					}
				}
			}else{
				NSLog(@"Un-paletted textures are currently unsupported: %@\n", obj.name.string);
			}
			[manager release];
			
			glTexImage2D(GL_TEXTURE_2D, i, GL_RGBA, levelWidth, levelHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, glTexData);
			
			free(glTexData);
		}
		obj.objectData = nil;
	}
	return [tex autorelease];
}

+ (id)textureWithLightMap:(NSMutableDictionary *)lightMap data:(NSMutableData *)data{
	UNRTexture *tex = [[self alloc] init];
	if(tex){
		tex.width = [[lightMap valueForKey:@"vClamp"] unsignedIntValue];
		tex.height = [[lightMap valueForKey:@"uClamp"] unsignedIntValue];
		int dataOffset = [[lightMap valueForKey:@"dataOffset"] unsignedIntValue];
		if(tex.width*tex.height + dataOffset < [data length]){
			Byte *texDat;
			NSData *subDat = [data subdataWithRange:NSMakeRange(dataOffset, tex.width*tex.height)];
			texDat = (Byte *)[subDat bytes];
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, tex.width, tex.height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, texDat);
		}
	}
	return [tex autorelease];
}

- (void)bind:(int)index{
	glActiveTexture(GL_TEXTURE0+index);
	glBindTexture(GL_TEXTURE_2D, self.glTex);
}

- (void)dealloc{
	if(glTex_){
		glDeleteTextures(1, &glTex_);
		glTex_ = 0;
	}
	[super dealloc];
}

@end
