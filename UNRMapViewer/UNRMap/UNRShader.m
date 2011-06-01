//
//  UNRShader.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRShader.h"


@implementation UNRShader

/*- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
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
 
 // Release vertex and fragment shaders.
 if(vertShader)
 glDeleteShader(vertShader);
 if(fragShader)
 glDeleteShader(fragShader);
 
 return TRUE;
 }*/

@end
