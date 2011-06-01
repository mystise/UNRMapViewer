//
//  UNRShader.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRShader.h"

@interface UNRShader()

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)link;

@end

@implementation UNRShader

@synthesize program = program_, uniforms = uniforms_, attributes = attributes_;

- (id)initWithShader:(NSString *)name{
	self = [super init];
	if(self){
		self.uniforms = [NSMutableDictionary dictionary];
		self.attributes = [NSMutableDictionary dictionary];
		
		GLuint vshader = 0;
		NSString *vPath = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
		if(![self compileShader:&vshader type:GL_VERTEX_SHADER file:vPath]){
			NSLog(@"Failed to compile Vertex Shader!");
		}
		
		GLuint fshader = 0;
		NSString *fPath = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
		if(![self compileShader:&fshader type:GL_FRAGMENT_SHADER file:fPath]){
			NSLog(@"Failed to compile Fragment Shader!");
		}
		
		self.program = glCreateProgram();
		glAttachShader(self.program, vshader);
		glAttachShader(self.program, fshader);
		if(![self link]){
			NSLog(@"Failed to link program: %d.", self.program);
			
			if(vshader)
			{
				glDeleteShader(vshader);
				vshader = 0;
			}
			if(fshader)
			{
				glDeleteShader(fshader);
				fshader = 0;
			}
			if(self.program)
			{
				glDeleteProgram(self.program);
				self.program = 0;
			}
		}
		
		// Release vertex and fragment shaders.
		if(vshader)
			glDeleteShader(vshader);
		if(fshader)
			glDeleteShader(fshader);
	}
	return self;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
	GLint status;
	const GLchar *source;
	
	source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if(!source){
		NSLog(@"Failed to load shader.");
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
		*shader = 0;
		return FALSE;
	}
	
	return TRUE;
}

- (BOOL)link{
	GLint status;
	
	glLinkProgram(self.program);
	
#if defined(DEBUG)
	GLint logLength;
	glGetProgramiv(self.program, GL_INFO_LOG_LENGTH, &logLength);
	if(logLength > 0){
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(self.program, logLength, &logLength, log);
		NSLog(@"Program link log:\n%s", log);
		free(log);
	}
#endif
	
	glGetProgramiv(self.program, GL_LINK_STATUS, &status);
	if(status == 0)
		return FALSE;
	
	return TRUE;
}

- (BOOL)validate{
	GLint logLength, status;
	
	glValidateProgram(self.program);
	glGetProgramiv(self.program, GL_INFO_LOG_LENGTH, &logLength);
	if(logLength > 0){
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(self.program, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s", log);
		free(log);
	}
	
	glGetProgramiv(self.program, GL_VALIDATE_STATUS, &status);
	if(status == 0)
		return FALSE;
	
	return TRUE;
}

- (void)use{
	glUseProgram(self.program);
}

- (void)addAttribute:(NSString *)name{
	GLuint attrib = glGetAttribLocation(self.program, [name UTF8String]);
	[self.attributes setValue:[NSNumber numberWithUnsignedInt:attrib] forKey:name];
}

- (void)addUniform:(NSString *)name{
	GLuint uniform = glGetUniformLocation(self.program, [name UTF8String]);
	[self.uniforms setValue:[NSNumber numberWithUnsignedInt:uniform] forKey:name];
}

- (GLuint)attribLocation:(NSString *)name{
	if(![self.attributes valueForKey:name]){
		[self addAttribute:name];
	}
	return [[self.attributes valueForKey:name] intValue];
}

- (GLuint)uniformLocation:(NSString *)name{
	if(![self.uniforms valueForKey:name]){
		[self addUniform:name];
	}
	return [[self.uniforms valueForKey:name] intValue];
}

- (void)dealloc{
	if(program_){
		glDeleteProgram(program_);
		program_ = 0;
	}
	[uniforms_ release];
	uniforms_ = nil;
	[attributes_ release];
	attributes_ = nil;
	[super dealloc];
}

@end
