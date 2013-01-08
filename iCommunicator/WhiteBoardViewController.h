//
//  WhiteBoardViewController.h
//  iCommunicator
//
//  Created by Sumit Lonkar on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ColorPickerController.h"
#import "PencilPickerController.h"

@interface WhiteBoardViewController : UIViewController <ColorPickerDelegate,PencilPickerDelegate,UIAlertViewDelegate,GKSessionDelegate,GKPeerPickerControllerDelegate>
{
    CGPoint lastPoint;
    float lineWidth;
    float prelineWidth;
    UIColor *drawcolor;
    UIColor *preColor;
    BOOL fingerSwiped;
    IBOutlet UIImageView *slateImage;
    
    GKSession *whiteBoardSession;
    GKPeerPickerController *whiteBoardPikcer;
    NSMutableArray *whiteBoardPeers;
    
    ColorPickerController *colorPicker;
    UIPopoverController *colorPickerPopover;
    PencilPickerController *pencilPicker;
    UIPopoverController *pencilPickerPopover;
    
    BOOL isConnected;
}

@property(retain)GKSession *whiteBoardSession;

@property float lineWidth;
@property float prelineWidth;
@property (retain) UIColor *drawcolor;
@property (retain) UIColor *preColor;
@property (nonatomic, retain) ColorPickerController *colorPicker;
@property (nonatomic, retain) UIPopoverController *colorPickerPopover;
@property (nonatomic, retain) PencilPickerController *pencilPicker;
@property (nonatomic, retain) UIPopoverController *pencilPickerPopover;

@end
