//
//  SettingsTableViewController.h
//  iCommunicator
//
//  Created by Sumit Lonkar on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController <UIPickerViewDelegate,UIPickerViewDataSource,UITextViewDelegate>
{
    UILabel *languageLable;
    UITextField *userName;
    NSArray *languageArray;
    NSDictionary *languageDict;
    
    IBOutlet UIPickerView *languagePicker;
    IBOutlet UIBarButtonItem *hideLangPicker;
    
    IBOutlet UISwitch *bluetooth;
    IBOutlet UISwitch *wiFi;
    
   IBOutlet UITableViewCell *userNameCell;
   IBOutlet UITableViewCell *userLanguageCell;
   IBOutlet UITableViewCell *bluetoothNetworkCell;
   IBOutlet UITableViewCell *wiFiNetworkCell; 
}

@property(nonatomic,retain)IBOutlet  UITextField *userName;
@property(nonatomic,retain)IBOutlet UILabel *languageLable;

@property(nonatomic,retain) NSArray *languageArray;
@property(nonatomic,retain) NSDictionary *languageDict;

@property(nonatomic,retain) IBOutlet UIPickerView *languagePicker;
@property(nonatomic,retain) UIBarButtonItem *hideLangPicker;

@property(nonatomic,assign) IBOutlet UITableViewCell *userNameCell;
@property(nonatomic,assign) IBOutlet UITableViewCell *userLanguageCell;
@property(nonatomic,assign) IBOutlet UITableViewCell *bluetoothNetworkCell;
@property(nonatomic,assign) IBOutlet UITableViewCell *wiFiNetworkCell;
@property(nonatomic,assign) IBOutlet UISwitch *bluetooth;
@property(nonatomic,assign) IBOutlet UISwitch *wiFi;

-(IBAction)textFieldDoneEditing:(id)sender;
-(IBAction)selectBluetoothNetwork:(UISwitch *)sender;
-(IBAction)selectWiFiNetwork:(UISwitch *)sender;
-(IBAction)hideLangPicker:(id)sender;
@end
