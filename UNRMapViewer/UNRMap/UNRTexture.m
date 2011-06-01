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

@synthesize tex = tex_, width = width_, height = height_;

+ (id)textureWithObject:(UNRExport *)obj withFile:(UNRFile *)file{
	UNRTexture *tex = [[[self alloc] init] autorelease];
	if(tex){
		int format = 0;
		DataManager *manager = [[DataManager alloc] initWithFileData:[[[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"mipMap"]];
		tex.width = [[[[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"width"] intValue];
		tex.height = [[[[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"height"] intValue];
		NSArray *palette = nil;
		
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
		
		tex.tex = calloc(tex.width*tex.height, sizeof(color));
		//stored width first
		
		if(format == 0){
			//paletted
			for(int i = 0; i < tex.width; i++){
				for(int j = 0; j < tex.height; j++){
					Byte index = [manager loadByte];
					NSNumber *colorR = [[palette objectAtIndex:index] valueForKey:@"red"];
					NSNumber *colorG = [[palette objectAtIndex:index] valueForKey:@"green"];
					NSNumber *colorB = [[palette objectAtIndex:index] valueForKey:@"blue"];
					NSNumber *colorA = [[palette objectAtIndex:index] valueForKey:@"alpha"];
					tex.tex[j*tex.width + i] = (color){[colorR intValue], [colorG intValue], [colorB intValue], [colorA intValue]};
				}
			}
		}else{
			NSLog(@"Un-paletted textures are currently unsupported: %@\n", obj.name.string);
		}
		[manager release];
	}
	return tex;
}

- (void)setTex:(color *)tex{
	if(tex_){
		free(tex_);
		tex_ = NULL;
	}
	tex_ = tex;
}

- (void)dealloc{
	if(tex_){
		free(tex_);
		tex_ = NULL;
	}
	[super dealloc];
}

@end
