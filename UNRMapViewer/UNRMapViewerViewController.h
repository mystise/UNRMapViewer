//
//  UNRMapViewerViewController.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class UNRFile;

@interface UNRMapViewerViewController : UIViewController{
@private
	EAGLContext *context;
	GLuint program;
	
	BOOL animating;
	NSInteger animationFrameInterval;
	CADisplayLink *displayLink;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property(nonatomic, retain) UNRFile *file;
@property(nonatomic, retain) NSMutableDictionary *level;

- (void)startAnimation;
- (void)stopAnimation;

- (void)loadMap:(NSString *)mapPath;

@end
