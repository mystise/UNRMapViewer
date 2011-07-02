//
//  UNRMapViewerViewController.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "Unreal.h"
#import "UNRMap.h"

@interface UNRMapViewerViewController : UIViewController{
@private
	EAGLContext *context;
	
	BOOL animating;
	NSInteger animationFrameInterval;
	CADisplayLink *displayLink;
}

@property(nonatomic, readonly, getter=isAnimating) BOOL animating;
@property(nonatomic, assign) NSInteger animationFrameInterval;
@property(nonatomic, retain) UNRFile *file;
@property(nonatomic, retain) UNRMap *map;
@property(nonatomic, assign) float aspect;

- (void)startAnimation;
- (void)stopAnimation;

- (void)loadMap:(NSString *)mapPath;

@end
