//
//  UNRName.h
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataManager.h"

@interface UNRName : NSObject {
	
}

+ (id)nameWithManager:(DataManager *)manager version:(NSNumber *)version;

@property(nonatomic, copy) NSNumber *flags;
@property(nonatomic, copy) NSString *string;

@end
