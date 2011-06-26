//
//  UNRMapViewerViewController.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UNRMapViewerViewController.h"
#import "EAGLView.h"

@interface UNRMapViewerViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
@end

@implementation UNRMapViewerViewController

@synthesize animating, context, displayLink, file = file_, map = map_, aspect = aspect_;

- (void)awakeFromNib{
	EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	if(!aContext){
		NSLog(@"Unsupported platform!!!");
		return;
	}
	
	if(!aContext)
		NSLog(@"Failed to create ES context");
	else if(![EAGLContext setCurrentContext:aContext])
		NSLog(@"Failed to set ES context current");
	
	self.context = aContext;
	[aContext release];
	
	self.view.multipleTouchEnabled = YES;
	
	EAGLView *view = (EAGLView *)self.view;
	[view setContext:context];
	[view setFramebuffer];
	
	animating = FALSE;
	animationFrameInterval = 2;
	self.displayLink = nil;
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_STENCIL_TEST);
}

- (void)dealloc{
	// Tear down context.
	if([EAGLContext currentContext] == context)
		[EAGLContext setCurrentContext:nil];
	
	[context release];
	
	[file_ release];
	file_ = nil;
	[map_ release];
	map_ = nil;
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Memory alert!" message:@"Alert!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	// Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated{
	[self startAnimation];
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
	[self stopAnimation];
	
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload{
	[super viewDidUnload];
	[self.map release];
	[self.file release];
	// Tear down context.
	if([EAGLContext currentContext] == context)
		[EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval{
	return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval{
	/*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
	if(frameInterval >= 1){
		animationFrameInterval = frameInterval;
		
		if(animating){
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void)startAnimation{
	if(!animating){
		CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(drawFrame)];
		[aDisplayLink setFrameInterval:animationFrameInterval];
		[aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		self.displayLink = aDisplayLink;
		
		animating = TRUE;
		EAGLView *view = (EAGLView *)self.view;
		float width = view.framebufferWidth;
		float height = view.framebufferHeight;
		float aspect = height/width;
		self.aspect = aspect;
	}
}

- (void)stopAnimation{
	if(animating){
		[self.displayLink invalidate];
		self.displayLink = nil;
		animating = FALSE;
	}
}

- (void)drawFrame{
	[(EAGLView *)self.view setFramebuffer];
	
	glClearColor(0.1f, 0.5f, 0.5f, 1.0f);
	glClear(GL_DEPTH_BUFFER_BIT|GL_COLOR_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
	
	[self.map draw:self.aspect withTimestep:animationFrameInterval/60.0f];
	
	[(EAGLView *)self.view presentFramebuffer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
		return YES;
	}
	return NO;
}

- (void)loadMap:(NSString *)mapPath{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	UNRFile *file = [[UNRFile alloc] initWithFileData:[NSData dataWithContentsOfMappedFile:mapPath] pluginsDirectory:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Default Plugins"]];
	self.file = file;
	[file release];
	[self.file resolveImportReferences:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Maps/Depend"]];
	[pool drain];
	pool = [[NSAutoreleasePool alloc] init];
	NSMutableDictionary *level = nil;
	for(UNRExport *obj in self.file.objects){
		if([obj.classObj.name.string isEqualToString:@"Level"]){
			[obj loadPlugin:self.file];
			level = [[obj.objectData valueForKey:@"bspModel"] objectData];
			obj.objectData = nil;
		}
	}
	if(level){
		UNRMap *theMap = [[UNRMap alloc] initWithModel:level andFile:self.file];
		self.map = theMap;
		[theMap release];
	}
	self.file = nil;
	[pool drain];
	/*self.file = [[UNRFile alloc] initWithFileData:[NSData dataWithContentsOfFile:mapPath] pluginsDirectory:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Default Plugins"]];
	[self.file resolveImportReferences:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Maps/Depend"]];
	for(UNRExport *obj in self.file.objects){
		if([obj.classObj.name.string isEqualToString:@"Level"]){
			[obj loadPlugin:self.file];
			self.level = [[obj.objectData valueForKey:@"bspModel"] objectData];
		}
	}
	if(self.level){
		NSMutableArray *points = [self.level valueForKey:@"points"];
		NSMutableArray *vectors = [self.level valueForKey:@"vectors"];
		NSMutableArray *nodes = [self.level valueForKey:@"nodes"];
		NSMutableArray *surfs = [self.level valueForKey:@"surfs"];
		NSMutableArray *verts = [self.level valueForKey:@"verts"];
		
		for(NSMutableDictionary *point in points){
			printf("v %f %f %f\n", [[point valueForKeyPath:@"point.x"] floatValue], [[point valueForKeyPath:@"point.y"] floatValue], [[point valueForKeyPath:@"point.z"] floatValue]);
		}
		int currentCoord = 1;
		for(NSMutableDictionary *node in nodes){
			NSMutableDictionary *surf = [surfs objectAtIndex:[[node valueForKey:@"iSurf"] intValue]];
			vector coordU = vec([[vectors objectAtIndex:[[surf valueForKey:@"vTextureU"] intValue]] valueForKey:@"vector"]);
			float Uscale = vecMag(coordU);
			vector coordV = vec([[vectors objectAtIndex:[[surf valueForKey:@"vTextureV"] intValue]] valueForKey:@"vector"]);
			float Vscale = vecMag(coordV);
			int panU = [[surf valueForKey:@"panU"] intValue];
			int panV = [[surf valueForKey:@"panV"] intValue];
			vector pBase = vec([[points objectAtIndex:[[surf valueForKey:@"pBase"] intValue]] valueForKey:@"point"]);
			int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
			int vertCount = [[node valueForKey:@"vertCount"] intValue];
			
			id texture = [self.file resolveObjectReference:[[surf valueForKey:@"texture"] intValue]];
			if([texture isKindOfClass:[UNRImport class]]){
				UNRImport *import = texture;
				texture = import.obj;
			}
			
			UNRExport *export = texture;
			texture = export.objectData;
			
			NSMutableDictionary *mipMap = [[texture valueForKey:@"mipMapLevels"] objectAtIndex:0];
			
			float texWidth = [[mipMap valueForKey:@"width"] floatValue];
			float texHeight = [[mipMap valueForKey:@"height"] floatValue];
			if(texWidth <= 0.0f){
				texWidth = 1.0f;
			}
			if(texHeight <= 0.0f){
				texHeight = 1.0f;
			}
			
			//triangle fans
			if(vertCount != 0){
				//for each vertex, find its displacement from pBase, then dot-product with U and V to get the coords
				//add panU and panV to get the final tex Coord
				int ind1, ind2, ind3;
				ind1 = [[[verts objectAtIndex:0+iVertPool] valueForKey:@"pVertex"] intValue]+1;
				ind2 = [[[verts objectAtIndex:1+iVertPool] valueForKey:@"pVertex"] intValue]+1;
				ind3 = [[[verts objectAtIndex:2+iVertPool] valueForKey:@"pVertex"] intValue]+1;
				
				vector dv1 = vecSub(vec([[points objectAtIndex:ind1-1] valueForKey:@"point"]), pBase);
				vector dv2 = vecSub(vec([[points objectAtIndex:ind2-1] valueForKey:@"point"]), pBase);
				vector dv3 = vecSub(vec([[points objectAtIndex:ind3-1] valueForKey:@"point"]), pBase);
				
				float v1U = vecDot(dv1, coordU)-panU*Uscale;
				float v1V = vecDot(dv1, coordV)-panV*Vscale;
				printf("vt %f %f\n", v1U/texWidth, v1V/texHeight);
				
				float v2U = vecDot(dv2, coordU)-panU*Uscale;
				float v2V = vecDot(dv2, coordV)-panV*Vscale;
				printf("vt %f %f\n", v2U/texWidth, v2V/texHeight);
				
				float v3U = vecDot(dv3, coordU)-panU*Uscale;
				float v3V = vecDot(dv3, coordV)-panV*Vscale;
				printf("vt %f %f\n", v3U/texWidth, v3V/texHeight);
				
				printf("f %i/%i %i/%i %i/%i\n", ind1, currentCoord, ind2, currentCoord+1, ind3, currentCoord+2);
				currentCoord += 3;
				for(int i = 3; i < vertCount; i++){
					ind2 = ind3;
					ind3 = [[[verts objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue]+1;
					
					dv2 = vecSub(vec([[points objectAtIndex:ind2-1] valueForKey:@"point"]), pBase);
					dv3 = vecSub(vec([[points objectAtIndex:ind3-1] valueForKey:@"point"]), pBase);
					
					printf("vt %f %f\n", v1U/texWidth, v1V/texHeight);
					
					v2U = vecDot(dv2, coordU)-panU*Uscale;
					v2V = vecDot(dv2, coordV)-panV*Vscale;
					printf("vt %f %f\n", v2U/texWidth, v2V/texHeight);
					
					v3U = vecDot(dv3, coordU)-panU*Uscale;
					v3V = vecDot(dv3, coordV)-panV*Vscale;
					printf("vt %f %f\n", v3U/texWidth, v3V/texHeight);
					
					printf("f %i/%i %i/%i %i/%i\n", ind1, currentCoord, ind2, currentCoord+1, ind3, currentCoord+2);
					currentCoord += 3;
				}
			}
		}
		//export to obj:
		//print the point list
		//for each face:
		//get each vertex index, use the vertex list to redirect to a point
		//print each point index
		//end for
	}*/
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[self.map touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[self.map touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[self.map touchesEnded:touches withEvent:event];
}

@end
