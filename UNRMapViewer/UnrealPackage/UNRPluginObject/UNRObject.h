//
//  UNRObject.h
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataManager.h"
#import "UNRFile.h"
#import "UNRExport.h"
#import "UNRProperty.h"
#import "UNRUtilities.h"

@interface UNRObject : NSObject {
	
}

- (id)initWithFile:(UNRFile *)newFile object:(UNRExport *)newObj;

- (void)addByteWithAttributes:(NSDictionary *)attrib;
- (void)addShortWithAttributes:(NSDictionary *)attrib;
- (void)addIntWithAttributes:(NSDictionary *)attrib;
- (void)addLongWithAttributes:(NSDictionary *)attrib;
- (void)addFloatWithAttributes:(NSDictionary *)attrib;
- (void)addPropertiesWithAttributes:(NSDictionary *)attrib;
- (void)addCompactIndexWithAttributes:(NSDictionary *)attrib;
- (void)addStringWithAttributes:(NSDictionary *)attrib;
- (void)addDataWithAttributes:(NSDictionary *)attrib;
- (void)addObjectReferenceWithAttributes:(NSDictionary *)attrib;
- (void)addNameReferenceWithAttributes:(NSDictionary *)attrib;

- (void)addIntVectorWithAttributes:(NSDictionary *)attrib;
- (void)addVectorWithAttributes:(NSDictionary *)attrib;
- (void)addPlaneWithAttributes:(NSDictionary *)attrib;
- (void)addSphereWithAttributes:(NSDictionary *)attrib;
- (void)addBoxWithAttributes:(NSDictionary *)attrib;
- (void)addRotatorWithAttributes:(NSDictionary *)attrib;

- (void)beginArrayWithAttributes:(NSDictionary *)attrib;
- (void)endArrayWithAttributes:(NSDictionary *)attrib;

- (void)beginConditionalWithAttributes:(NSDictionary *)attrib;
- (void)endConditionalWithAttributes:(NSDictionary *)attrib;

- (void)processArray:(NSString *)methodName attribs:(NSDictionary *)attrib;

@property(nonatomic, retain) UNRFile *file;
@property(nonatomic, retain) UNRExport *obj;
@property(nonatomic, retain) DataManager *manager;
@property(nonatomic, retain) NSMutableArray *currentCommands, *currentArray, *currentData;

@end
