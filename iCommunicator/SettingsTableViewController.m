//
//  SettingsTableViewController.m
//  iCommunicator
//
//  Created by Sumit Lonkar on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsTableViewController.h"


@implementation SettingsTableViewController
@synthesize userNameCell,userLanguageCell;
@synthesize bluetoothNetworkCell,wiFiNetworkCell;
@synthesize languageLable,userName;
@synthesize languageArray,languagePicker,hideLangPicker;
@synthesize bluetooth,wiFi;
@synthesize languageDict;
-(void)dealloc
{
    [languageDict release];
    [bluetooth release];
    [wiFi release];
    [languageArray release];
    [languagePicker release];
    [hideLangPicker release];
    [userName release];
    [languageLable release];
    [userNameCell release];
    [userLanguageCell release];
    [bluetoothNetworkCell release];
    [wiFiNetworkCell release];
}
-(IBAction)textFieldDoneEditing:(id)sender
{   
    NSLog(@"User Name is %@",self.userName.text);
    
    NSUserDefaults *userSettings =[NSUserDefaults standardUserDefaults];
    [userSettings setObject:self.userName.text forKey:@"userKey"];
    [userSettings synchronize];
    
    [self.userName resignFirstResponder];
}
- (void)slideDownDidStop
{
    [self.languagePicker removeFromSuperview];
    self.languagePicker.hidden=YES;
}
-(IBAction)hideLangPicker:(id)sender
{
    CGRect screenRect = [self.tableView bounds];
    CGRect endFrame = CGRectMake(screenRect.origin.x, screenRect.origin.y + screenRect.size.height, screenRect.size.width, 216.0);
    CGRect startFrame = CGRectMake(screenRect.origin.x, screenRect.origin.y + screenRect.size.height-216.0, screenRect.size.width, 216.0);

    self.languagePicker.frame = startFrame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationOptionTransitionNone forView:self.tableView cache:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
    [self.languagePicker setFrame:endFrame];
    [UIView commitAnimations];
    
    self.navigationItem.rightBarButtonItem = nil;
}


-(IBAction)selectBluetoothNetwork:(UISwitch *)sender
{
   
    if (sender.on) 
    {
        NSUserDefaults *userSettings =[NSUserDefaults standardUserDefaults];
        //[userSettings setObject:YES forKey:@"bluetoothKey"];
        [userSettings setBool:YES forKey:@"bluetoothKey"];
        [userSettings synchronize];
    }
    else
    {
        NSUserDefaults *userSettings =[NSUserDefaults standardUserDefaults];
        [userSettings setBool:NO forKey:@"bluetoothKey"];
        [userSettings synchronize];
    }

    
}
-(IBAction)selectWiFiNetwork:(UISwitch *)sender
{
    if (sender.on) 
    {
        NSUserDefaults *userSettings =[NSUserDefaults standardUserDefaults];
        [userSettings setBool:YES forKey:@"wiFiKey"];
        [userSettings synchronize];
    }
    else
    {
        NSUserDefaults *userSettings =[NSUserDefaults standardUserDefaults];
        [userSettings setBool:NO forKey:@"wiFiKey"];
        [userSettings synchronize];
    }

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Settings";
    
    self.userName.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"userKey"];
    self.languageLable.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"languageKey"];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"bluetoothKey"])
    {
       [bluetooth setOn:YES];
    }
    else
    {
        [bluetooth setOn:NO];
    }
   
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"wiFiKey"])
    {
        [wiFi setOn:YES];
    }
    else
    {
        [wiFi setOn:NO];
    }
    
    NSString *languagePlist =[[NSBundle mainBundle] pathForResource:@"language" ofType:@"plist"];
    self.languageDict =[NSDictionary dictionaryWithContentsOfFile:languagePlist];
    self.languageArray =[[self.languageDict allKeys]sortedArrayUsingSelector:@selector(compare:)];
    self.navigationController.navigationBar.barStyle=UIBarStyleBlack;
    
    int index = [languageArray indexOfObject:languageLable.text];
    [languagePicker selectRow:index inComponent:0 animated:YES];
    [languagePicker reloadComponent:0];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"User Settings";
    }
    else
        return @"Network Settings";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section==0) {
        return @"User name will be used as communication entity name and transaltion language will be used for automatic translation of incoming messages.";
    }
    else
        return @"Select appropriate network to set up communication within group. If both networks are on then user will be given choice of selecting one of them at the start of session";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section]==0)
    {
        if ([indexPath row]==0)
        {
            return userNameCell;
        }
        else return userLanguageCell;
    }
    else
        if ([indexPath row]==0)
        {
            return bluetoothNetworkCell;
        }
    else
        return wiFiNetworkCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - PickerView delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component 
{
    
    return [languageArray count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component 
{
    return [languageArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.languageLable.text=[languageArray objectAtIndex:row];
    NSUserDefaults *userSettings =[NSUserDefaults standardUserDefaults];
    [userSettings setObject:self.languageLable.text forKey:@"languageKey"];
    [userSettings setObject:[self.languageDict valueForKey:self.languageLable.text] forKey:@"translationParameter"];
    [userSettings synchronize];

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section]==0 && [indexPath row]==1) 
    {

        CGRect screenRect = [self.tableView bounds];
        CGRect startFrame = CGRectMake(screenRect.origin.x, screenRect.origin.y + screenRect.size.height, screenRect.size.width, 216.0);
        CGRect endFram = CGRectMake(screenRect.origin.x, screenRect.origin.y + screenRect.size.height-216.0, screenRect.size.width, 216.0);
        self.languagePicker.frame=startFrame;
        self.languagePicker.hidden =NO;
        [self.view addSubview:self.languagePicker];
        self.languagePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationTransition:UIViewAnimationOptionTransitionNone forView:self.view cache:YES];
        [self.languagePicker setFrame:endFram];
        [UIView commitAnimations];
        
        self.navigationItem.rightBarButtonItem = self.hideLangPicker;
    }
}

@end
