//
//  UNRMapViewerAppDelegate.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UNRMapViewerViewController;

@interface UNRMapViewerAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UNRMapViewerViewController *viewController;

@end
