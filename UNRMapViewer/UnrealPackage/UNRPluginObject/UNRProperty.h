//
//  UNRProperty.h
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Unreal.h"
#import "DataManager.h"

@interface UNRProperty : NSObject {
	
}

- (id)initWithManager:(DataManager *)manager file:(UNRFile *)newFile;

+ (int)readIndex:(DataManager *)manager;

//- (NSString *)shortDescription;

@property(nonatomic, retain) UNRName *name, *structName;
@property(nonatomic, assign) BOOL special;
@property(nonatomic, assign) Byte type;
@property(nonatomic, assign) int index;
@property(nonatomic, retain) NSData *data;
@property(nonatomic, retain) UNRBase *object;
//@property(nonatomic, assign) UNRFile *file;

@end
