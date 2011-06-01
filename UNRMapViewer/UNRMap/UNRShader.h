//
//  UNRShader.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface UNRShader : NSObject {
	
}

- (id)initWithShader:(NSString *)name;
- (BOOL)validate;
- (void)use;

- (void)addAttribute:(NSString *)name;
- (void)addUniform:(NSString *)name;
- (GLuint)attribLocation:(NSString *)name;
- (GLuint)uniformLocation:(NSString *)name;

@property(nonatomic, retain) NSMutableDictionary *attributes;
@property(nonatomic, retain) NSMutableDictionary *uniforms;
@property(nonatomic, assign) GLuint program;

@end
