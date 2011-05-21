//
//  UNRGuid.h
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 1/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataManager.h"

@interface UNRGuid : NSObject {
	
}

+ (id)guidWithManager:(DataManager *)manager;

@property(nonatomic, assign) Byte *guid;

@end
