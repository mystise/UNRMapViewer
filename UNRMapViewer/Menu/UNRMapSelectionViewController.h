//
//  UNRMapSelectionView.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UNRMapViewerViewController;


@interface UNRMapSelectionViewController : UITableViewController {
    
}

@property(retain, nonatomic) NSMutableArray *maps;
@property(retain, nonatomic) IBOutlet UNRMapViewerViewController *mapViewController;

@end
