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

// Uniform index.
enum{
	UNIFORM_TRANSLATE,
	NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum{
	ATTRIB_VERTEX,
	ATTRIB_COLOR,
	NUM_ATTRIBUTES
};

@interface UNRMapViewerViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation UNRMapViewerViewController

@synthesize animating, context, displayLink, file = file_, level = level_;

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
	
	[(EAGLView *)self.view setContext:context];
	[(EAGLView *)self.view setFramebuffer];
	
	[self loadShaders];
	
	animating = FALSE;
	animationFrameInterval = 1;
	self.displayLink = nil;
}

- (void)dealloc{
	if(program){
		glDeleteProgram(program);
		program = 0;
	}
	
	// Tear down context.
	if([EAGLContext currentContext] == context)
		[EAGLContext setCurrentContext:nil];
	
	[context release];
	
	[file_ release];
	file_ = nil;
	[level_ release];
	level_ = nil;
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated{
	//[self startAnimation];
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
	[self stopAnimation];
	
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload{
	[super viewDidUnload];
	
	if(program){
		glDeleteProgram(program);
		program = 0;
	}
	
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
	
	// Replace the implementation of this method to do your own custom drawing.
	static const GLfloat squareVertices[] ={
		-0.5f, -0.33f,
		0.5f, -0.33f,
		-0.5f,  0.33f,
		0.5f,  0.33f,
	};
	
	static const GLubyte squareColors[] ={
		255, 255,   0, 255,
		0,   255, 255, 255,
		0,	 0,   0,   0,
		255,   0, 255, 255,
	};
	
	static float transY = 0.0f;
	
	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Use shader program.
	glUseProgram(program);
	
	// Update uniform value.
	glUniform1f(uniforms[UNIFORM_TRANSLATE], (GLfloat)transY);
	transY += 0.075f;	
	
	// Update attribute values.
	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, 1, 0, squareColors);
	glEnableVertexAttribArray(ATTRIB_COLOR);
	
	// Validate program before drawing. This is a good check, but only really necessary in a debug build.
	// DEBUG macro must be defined in your debug configurations ifthat's not already the case.
#if defined(DEBUG)
	if(![self validateProgram:program]){
		NSLog(@"Failed to validate program: %d", program);
		return;
	}
#endif
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	[(EAGLView *)self.view presentFramebuffer];
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
	GLint status;
	const GLchar *source;
	
	source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if(!source){
		NSLog(@"Failed to load vertex shader");
		return FALSE;
	}
	
	*shader = glCreateShader(type);
	glShaderSource(*shader, 1, &source, NULL);
	glCompileShader(*shader);
	
#if defined(DEBUG)
	GLint logLength;
	glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
	if(logLength > 0){
		GLchar *log = (GLchar *)malloc(logLength);
		glGetShaderInfoLog(*shader, logLength, &logLength, log);
		NSLog(@"Shader compile log:\n%s", log);
		free(log);
	}
#endif
	
	glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	if(status == 0){
		glDeleteShader(*shader);
		return FALSE;
	}
	
	return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog{
	GLint status;
	
	glLinkProgram(prog);
	
#if defined(DEBUG)
	GLint logLength;
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if(logLength > 0){
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program link log:\n%s", log);
		free(log);
	}
#endif
	
	glGetProgramiv(prog, GL_LINK_STATUS, &status);
	if(status == 0)
		return FALSE;
	
	return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog{
	GLint logLength, status;
	
	glValidateProgram(prog);
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if(logLength > 0){
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s", log);
		free(log);
	}
	
	glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
	if(status == 0)
		return FALSE;
	
	return TRUE;
}

- (BOOL)loadShaders{
	GLuint vertShader, fragShader;
	NSString *vertShaderPathname, *fragShaderPathname;
	
	// Create shader program.
	program = glCreateProgram();
	
	// Create and compile vertex shader.
	vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
	if(![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]){
		NSLog(@"Failed to compile vertex shader");
		return FALSE;
	}
	
	// Create and compile fragment shader.
	fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
	if(![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]){
		NSLog(@"Failed to compile fragment shader");
		return FALSE;
	}
	
	// Attach vertex shader to program.
	glAttachShader(program, vertShader);
	
	// Attach fragment shader to program.
	glAttachShader(program, fragShader);
	
	// Bind attribute locations.
	// This needs to be done prior to linking.
	glBindAttribLocation(program, ATTRIB_VERTEX, "position");
	glBindAttribLocation(program, ATTRIB_COLOR, "color");
	
	// Link program.
	if(![self linkProgram:program]){
		NSLog(@"Failed to link program: %d", program);
		
		if(vertShader)
		{
			glDeleteShader(vertShader);
			vertShader = 0;
		}
		if(fragShader)
		{
			glDeleteShader(fragShader);
			fragShader = 0;
		}
		if(program)
		{
			glDeleteProgram(program);
			program = 0;
		}
		
		return FALSE;
	}
	
	// Get uniform locations.
	uniforms[UNIFORM_TRANSLATE] = glGetUniformLocation(program, "translate");
	
	// Release vertex and fragment shaders.
	if(vertShader)
		glDeleteShader(vertShader);
	if(fragShader)
		glDeleteShader(fragShader);
	
	return TRUE;
}

- (void)loadMap:(NSString *)mapPath{
	self.file = [[UNRFile alloc] initWithFileData:[NSData dataWithContentsOfFile:mapPath] pluginsDirectory:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Default Plugins"]];
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
			printf("v %f %f %f\n", [[point valueForKeyPath:@"point.x"] floatValue]/256.0f, [[point valueForKeyPath:@"point.y"] floatValue]/256.0f, [[point valueForKeyPath:@"point.z"] floatValue]/256.0f);
		}
		int currentCoord = 1;
		for(NSMutableDictionary *node in nodes){
			NSMutableDictionary *surf = [surfs objectAtIndex:[[node valueForKey:@"iSurf"] intValue]];
			vector coordU = [[vectors objectAtIndex:[[surf valueForKey:@"vTextureU"] intValue]] valueForKey:@"vector"];
			vector coordV = [[vectors objectAtIndex:[[surf valueForKey:@"vTextureV"] intValue]] valueForKey:@"vector"];
			int panU = [[surf valueForKey:@"panU"] intValue];
			int panV = [[surf valueForKey:@"panV"] intValue];
			vector pBase = [[points objectAtIndex:[[surf valueForKey:@"pBase"] intValue]] valueForKey:@"point"];
			int iVertPool = [[node valueForKey:@"iVertPool"] intValue];
			int vertCount = [[node valueForKey:@"vertCount"] intValue];
			
			//triangle fans
			if(vertCount != 0){
				//for each vertex, find its displacement from pBase, then dot-product with U and V to get the coords
				//add panU and panV to get the final tex Coord
				int ind1, ind2, ind3;
				ind1 = [[[verts objectAtIndex:0+iVertPool] valueForKey:@"pVertex"] intValue]+1;
				ind2 = [[[verts objectAtIndex:1+iVertPool] valueForKey:@"pVertex"] intValue]+1;
				ind3 = [[[verts objectAtIndex:2+iVertPool] valueForKey:@"pVertex"] intValue]+1;
				
				vector dv1 = [vecSub([[points objectAtIndex:ind1-1] valueForKey:@"point"], pBase) retain];
				vector dv2 = vecSub([[points objectAtIndex:ind2-1] valueForKey:@"point"], pBase);
				vector dv3 = vecSub([[points objectAtIndex:ind3-1] valueForKey:@"point"], pBase);
				
				float v1U = vecDot(dv1, coordU)+panU;
				float v1V = vecDot(dv1, coordV)+panV;
				printf("vt %f %f\n", v1U, v1V);
				
				float v2U = vecDot(dv2, coordU)+panU;
				float v2V = vecDot(dv2, coordV)+panV;
				printf("vt %f %f\n", v2U, v2V);
				
				float v3U = vecDot(dv3, coordU)+panU;
				float v3V = vecDot(dv3, coordV)+panV;
				printf("vt %f %f\n", v3U, v3V);
				
				printf("f %i/%i %i/%i %i/%i\n", ind1, currentCoord, ind2, currentCoord+1, ind3, currentCoord+2);
				currentCoord += 3;
				for(int i = 3; i < vertCount; i++){
					ind2 = ind3;
					ind3 = [[[verts objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue]+1;
					
					dv2 = vecSub([[points objectAtIndex:ind2-1] valueForKey:@"point"], pBase);
					dv3 = vecSub([[points objectAtIndex:ind3-1] valueForKey:@"point"], pBase);
					
					printf("vt %f %f\n", v1U, v1V);
					
					v2U = vecDot(dv2, coordU)+panU;
					v2V = vecDot(dv2, coordV)+panV;
					printf("vt %f %f\n", v2U, v2V);
					
					v3U = vecDot(dv3, coordU)+panU;
					v3V = vecDot(dv3, coordV)+panV;
					printf("vt %f %f\n", v3U, v3V);
					
					printf("f %i/%i %i/%i %i/%i\n", ind1, currentCoord, ind2, currentCoord+1, ind3, currentCoord+2);
					currentCoord += 3;
				}
			}
			/*//triangle strip
			 if(vertCount != 0){
			 int ind1, ind2, ind3;
			 ind1 = [[[verts objectAtIndex:0+iVertPool] valueForKey:@"pVertex"] intValue]+1;
			 ind2 = [[[verts objectAtIndex:1+iVertPool] valueForKey:@"pVertex"] intValue]+1;
			 ind3 = [[[verts objectAtIndex:2+iVertPool] valueForKey:@"pVertex"] intValue]+1;
			 printf("f %i %i %i\n", ind1, ind2, ind3);
			 for(int i = 3; i < vertCount; i++){
			 ind1 = ind2;
			 ind2 = ind3;
			 ind3 = [[[verts objectAtIndex:i+iVertPool] valueForKey:@"pVertex"] intValue]+1;
			 printf("f %i %i %i\n", ind1, ind2, ind3);
			 }
			 }*/
			/*//n-gons
			 if(vertCount != 0){
			 printf("f");
			 for(int i = iVertPool; i < iVertPool+vertCount; i++){
			 int pointIndex = [[[verts objectAtIndex:i] valueForKey:@"pVertex"] intValue];
			 printf(" %i", pointIndex+1);
			 }
			 printf("\n");
			 }*/
		}
		//export to obj:
		//print the point list
		//for each face:
		//get each vertex index, use the vertex list to redirect to a point
		//print each point index
		//end for
	}
}

@end
