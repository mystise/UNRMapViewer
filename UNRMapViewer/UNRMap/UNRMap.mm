//
//  UNRMap.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRMap.h"

#import "UNRFile.h"
#import "UNRTexture.h"
#import "UNRNode.h"
#import "Utilities.h"
#import "Matrix.h"
#import "GLCamera.h"

using Matrix::Matrix3D;
using Vector::Vector2D;

@interface UNRMap()
@property(nonatomic, assign) FPSCamera *cam;
@end

@implementation UNRMap

@synthesize rootNode = rootNode_, textures = textures_, shaders = shaders_, cam = cam_;

- (id)initWithModel:(NSMutableDictionary *)model andFile:(UNRFile *)file{
	self = [super init];
	if(self != nil){
		self.textures = [NSMutableDictionary dictionary];
		self.shaders = [NSMutableDictionary dictionary];
		UNRNode *node = [[UNRNode alloc] initWithModel:model nodeNumber:0 file:file map:self];
		self.rootNode = node;
		[node release];
		
		//setup vbo
		
		self.cam = new FPSCamera;
		self.cam->setUp(Vector3D(0.0f, 0.0f, 1.0f));
		self.cam->lookAt(Vector3D(0.0f, 10.0f, 0.0f));
	}
	return self;
}

- (void)draw:(float)aspect{
	//maybe do cool stuff
	//static float rotation = 0.0f;
	//rotation += 1.0f;
	
	Matrix3D modelView;
	Matrix3D projection;
	
	projection.perspective(60.0f, 0.1f, 10000.0f, aspect);
	
	//self.cam->rotateTo(0.0f, rotation);
	modelView = self.cam->glData();
	modelView.uniformScale(0.1f);
	
	modelView *= projection;
	
	[self.rootNode draw:aspect matrix:modelView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	NSArray *touches2 = [touches allObjects];
	for(UITouch *touch in touches2){
		Vector2D newPoint = [touch locationInView:nil];
		Vector2D origPoint = [touch previousLocationInView:nil];
		Vector2D disp = newPoint - origPoint;
		if(newPoint.y < 512){
			self.cam->rotate(-disp.x/10.0f, -disp.y/10.0f);
		}else{
			//self.cam->move(Vector3D());
			self.cam->moveRel(Vector3D(disp.x, disp.y, 0.0f));
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

- (void)setCam:(FPSCamera *)cam{
	if(cam_ != NULL){
		delete cam_;
	}
	cam_ = cam;
}

- (void)dealloc{
	if(cam_ != NULL){
		delete cam_;
	}
	cam_ = NULL;
	[rootNode_ release];
	rootNode_ = nil;
	[super dealloc];
}

@end
