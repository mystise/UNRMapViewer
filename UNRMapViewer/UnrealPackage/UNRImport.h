//
//  UNRImport.h
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UNRBase.h"

#import "DataManager.h"

@interface UNRImport : UNRBase {
	
}

+ (id)importWithManager:(DataManager *)manager;

@property(nonatomic, retain) UNRName *classPackage, *className;
@property(nonatomic, assign) int classPackageRef, classNameRef;

@end
