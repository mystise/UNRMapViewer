//
//  UNRMapViewerAppDelegate.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UNRMapViewerViewController, UNRMapSelectionViewController;

@interface UNRMapViewerAppDelegate : NSObject <UIApplicationDelegate>{

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UNRMapViewerViewController *viewController;
@property (nonatomic, retain) IBOutlet UNRMapSelectionViewController *listController;

@end
