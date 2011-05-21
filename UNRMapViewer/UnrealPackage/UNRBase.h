//
//  UNRBase.h
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UNRFile, UNRName;

@interface UNRBase : NSObject {
	
}

- (void)resolveRefrences:(UNRFile *)file;
- (NSUInteger)subObjectsCount;

@property(nonatomic, assign) UNRBase *package;//package is the one who owns the subObjects array that this is contained in
@property(nonatomic, retain) UNRName *name;
@property(nonatomic, retain) NSMutableArray *subObjects;
@property(nonatomic, assign) int packageRef, nameRef;

@end
