//
//  PencilPickerController.h
//  Slate
//
//  Created by Sumit Lonkar on 10/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PencilPickerDelegate
- (void)pencilSelected:(NSString *)pencil;
@end

@interface PencilPickerController : UITableViewController
{
    NSMutableArray *pencils;
    id<PencilPickerDelegate>delegate;
}
@property (nonatomic, retain) NSMutableArray *pencils;
@property (nonatomic, assign) id<PencilPickerDelegate> delegate;

@end
