//
//  ColorPickerController.h
//  Slate
//
//  Created by Sumit Lonkar on 10/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorPickerDelegate
- (void)colorSelected:(NSString *)color;
@end

@interface ColorPickerController : UITableViewController
{
    NSMutableArray *slateColors;
    id<ColorPickerDelegate>delegate;
}
@property (nonatomic, retain) NSMutableArray *slateColors;
@property (nonatomic, assign) id<ColorPickerDelegate> delegate;
@end
