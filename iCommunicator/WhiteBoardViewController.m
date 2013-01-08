//
//  WhiteBoardViewController.m
//  iCommunicator
//
//  Created by Sumit Lonkar on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WhiteBoardViewController.h"

@implementation WhiteBoardViewController
@synthesize lineWidth,drawcolor,prelineWidth,preColor ;
@synthesize colorPicker,colorPickerPopover;
@synthesize pencilPicker,pencilPickerPopover;
@synthesize whiteBoardSession;

-(void)dealloc
{
    [super dealloc];
    [colorPicker release];
    [colorPickerPopover release];
    [pencilPicker release];
    [pencilPickerPopover release];
    [whiteBoardSession release];
}

-(void)connect
{
    NSLog(@"Connect is tapped");
    
    if (isConnected)
    {
        [whiteBoardSession sendData:[@"Disconnect" dataUsingEncoding:NSASCIIStringEncoding] toPeers:whiteBoardPeers withDataMode:GKSendDataReliable error:nil];
        [whiteBoardSession disconnectFromAllPeers];
        [whiteBoardSession setAvailable:NO];
        [whiteBoardSession setDelegate:nil];
        [whiteBoardSession setDataReceiveHandler:nil withContext:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected" message:@"You are no longer connected to your peers." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        isConnected=NO;
    }
    else
    {
     whiteBoardPikcer=[[GKPeerPickerController alloc]init];
     whiteBoardPikcer.delegate=self;
    /*
    if(([[NSUserDefaults standardUserDefaults]boolForKey:@"bluetoothKey"])&& ([[NSUserDefaults standardUserDefaults]boolForKey:@"wiFiKey"]))
    {
        whiteBoardPikcer.connectionTypesMask=GKPeerPickerConnectionTypeNearby|GKPeerPickerConnectionTypeOnline;
    }
    else if([[NSUserDefaults standardUserDefaults]boolForKey:@"bluetoothKey"])
    {
        whiteBoardPikcer.connectionTypesMask=GKPeerPickerConnectionTypeNearby;
    }
    else if([[NSUserDefaults standardUserDefaults]boolForKey:@"wiFiKey"])
    {
        whiteBoardPikcer.connectionTypesMask=GKPeerPickerConnectionTypeOnline;
    }
     */
     whiteBoardPikcer.connectionTypesMask=GKPeerPickerConnectionTypeNearby;
     whiteBoardPeers=[[NSMutableArray alloc]init];
     [whiteBoardPikcer show];   
    }
}


-(void)eraseIt
{
    NSLog(@"Eraser Selected");
    self.preColor=self.drawcolor;
    self.prelineWidth=self.lineWidth;
    self.drawcolor = [UIColor whiteColor];
    self.lineWidth = 50.0;
    NSString *test=@"Eraser";
    [whiteBoardSession sendData:[test dataUsingEncoding:NSASCIIStringEncoding] toPeers:whiteBoardPeers withDataMode:GKSendDataReliable error:nil];
}


-(void)saveImage
{
    UIAlertView *saveAlert= [[UIAlertView alloc]initWithTitle:@"Message" message:@"Your white board  is saved in Photo Gallary !!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [saveAlert show];
    [saveAlert release];
    UIImage* imageToSave = [slateImage image];
    UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil); 
}

-(void)clearAll
{
    
    UIAlertView *clearAllAlert= [[UIAlertView alloc]initWithTitle:@"Wait..." message:@"Are you sure you want to clean your white baord ? " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
    [clearAllAlert show];
    [clearAllAlert release];
    
}
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1)
    {
        slateImage.image = nil;
        NSString *test=@"Clear";
        [whiteBoardSession sendData:[test dataUsingEncoding:NSASCIIStringEncoding] toPeers:whiteBoardPeers withDataMode:GKSendDataReliable error:nil];
    }
}



-(void)showHideNavbar
{
    NSLog(@"Hide Selected");
    /*if (self.navigationController.toolbarHidden)
    {
        //self.navigationController.navigationBarHidden=NO;
        self.navigationController.toolbarHidden=NO;
    }
    else
    {
        //self.navigationController.navigationBarHidden=YES;
        self.navigationController.toolbarHidden=YES;    
    }*/
}
- (void)colorSelected:(NSString *)color 
{
    if ([color isEqualToString:@"White"]) 
    {
        self.drawcolor = [UIColor whiteColor];
    } 
    else if ([color isEqualToString:@"Red"]) {
        self.drawcolor = [UIColor redColor];
    }
    else if ([color isEqualToString:@"Orange"]){
        self.drawcolor = [UIColor orangeColor];
    }
    else if ([color isEqualToString:@"Yellow"]){
        self.drawcolor = [UIColor yellowColor];
    }
    else if ([color isEqualToString:@"Green"]){
        self.drawcolor = [UIColor greenColor];
    }
    else if ([color isEqualToString:@"Blue"]){
        self.drawcolor = [UIColor blueColor];
    }
    else if ([color isEqualToString:@"Cyan"]){
        self.drawcolor = [UIColor cyanColor];
    }
    else if ([color isEqualToString:@"Black"]){
        self.drawcolor = [UIColor blackColor];
    }
    self.preColor=self.drawcolor;
    [whiteBoardSession sendData:[color dataUsingEncoding:NSASCIIStringEncoding] toPeers:whiteBoardPeers withDataMode:GKSendDataReliable error:nil];
    [self.colorPickerPopover dismissPopoverAnimated:YES];
}


- (void)setColorButtonTapped:(id)sender 
{
    if (colorPicker == nil) 
    {
        self.colorPicker = [[[ColorPickerController alloc] 
                             initWithStyle:UITableViewStylePlain] autorelease];
        colorPicker.delegate = self;
        self.colorPickerPopover = [[[UIPopoverController alloc]initWithContentViewController:colorPicker] autorelease];               
    }
    if (self.pencilPickerPopover != nil) 
    {
        [self.pencilPickerPopover dismissPopoverAnimated:NO];
    }
    [self.colorPickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)pencilSelected:(NSString *)pencil 
{
    self.drawcolor = self.preColor;
    self.lineWidth=self.prelineWidth;
    
    if ([pencil isEqualToString:@"Thin"]) 
    {
        self.lineWidth=2.5;
    } 
    else if ([pencil isEqualToString:@"Small"]) 
    {
        self.lineWidth=5.0;
    }
    else if ([pencil isEqualToString:@"Medium"]) 
    {
        self.lineWidth=7.5;
    }
    else if ([pencil isEqualToString:@"Large"]) 
    {
        self.lineWidth=10.0;
    }
    else if ([pencil isEqualToString:@"X-Large"]) 
    {
        self.lineWidth=12.5;
    }
  
    [whiteBoardSession sendData:[pencil dataUsingEncoding:NSASCIIStringEncoding] toPeers:whiteBoardPeers withDataMode:GKSendDataReliable error:nil];
    
    [self.pencilPickerPopover dismissPopoverAnimated:YES];
}

- (void)setPencilWidthButtonTapped:(id)sender 
{
    if (pencilPicker == nil) 
    {
        self.pencilPicker = [[[PencilPickerController alloc] 
                              initWithStyle:UITableViewStylePlain] autorelease];
        pencilPicker.delegate = self;
        self.pencilPickerPopover = [[[UIPopoverController alloc]initWithContentViewController:pencilPicker] autorelease];
    }
    if (self.colorPickerPopover != nil) 
    {
        [self.colorPickerPopover dismissPopoverAnimated:YES];
    }
    [self.pencilPickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	
	fingerSwiped = NO;
	UITouch *touch = [touches anyObject];
	lastPoint = [touch locationInView:self.view];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	fingerSwiped = YES;
	
	UITouch *touch = [touches anyObject];	
	CGPoint currentPoint = [touch locationInView:self.view];
    
	
	
	UIGraphicsBeginImageContext(self.view.frame.size);
	[slateImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
	CGContextSetLineWidth(UIGraphicsGetCurrentContext(), lineWidth);
	//CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),0,0,0, 1.0);
	CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.drawcolor.CGColor);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
	CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
	CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
	CGContextStrokePath(UIGraphicsGetCurrentContext());
	slateImage.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    lastPoint = currentPoint;
    
    //Sending Point Drawn on screen to other devices
    
    CGPoint temp=currentPoint;
    NSString *test= NSStringFromCGPoint(temp);
    [whiteBoardSession sendData:[test dataUsingEncoding:NSASCIIStringEncoding] toPeers:whiteBoardPeers withDataMode:GKSendDataReliable error:nil];

    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if(!fingerSwiped) 
    {
		UIGraphicsBeginImageContext(self.view.frame.size);
		[slateImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
		CGContextSetLineWidth(UIGraphicsGetCurrentContext(), lineWidth);
		//CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),0,0,0, 1.0);
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.drawcolor.CGColor);
		CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
		CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
		CGContextStrokePath(UIGraphicsGetCurrentContext());
		CGContextFlush(UIGraphicsGetCurrentContext());
		slateImage.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        //Sending Point Drawn on screen to other devices
        
        CGPoint temp=lastPoint;
        NSString *test= NSStringFromCGPoint(temp);
        [whiteBoardSession sendData:[test dataUsingEncoding:NSASCIIStringEncoding] toPeers:whiteBoardPeers withDataMode:GKSendDataReliable error:nil];
	}
}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title=@"White Board";
        self.tabBarItem.title=@"White Board";
        self.tabBarItem.image=[UIImage imageNamed:@"whiteBoard"];
      
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
    isConnected=NO;
    self.lineWidth=5.0;
    self.drawcolor = [UIColor blackColor];
    self.preColor=self.drawcolor;
    self.prelineWidth=self.lineWidth;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;  
    //self.navigationController.navigationBar.translucent = YES;
    
    self.navigationController.toolbarHidden=NO;
    self.navigationController.toolbar.barStyle=UIBarStyleBlack;
   // self.navigationController.toolbar.translucent=YES;
    
    UIBarButtonItem *flexiableSpace=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *connect=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"connect"] style:UIBarButtonItemStylePlain target:self action:@selector(connect)];
    UIBarButtonItem *pencil=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"pencil"] style:UIBarButtonItemStylePlain target:self action:@selector(setPencilWidthButtonTapped:)];
    UIBarButtonItem *eraser=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"eraser"] style:UIBarButtonItemStylePlain target:self action:@selector(eraseIt)];
    UIBarButtonItem *color=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"color"] style:UIBarButtonItemStylePlain target:self action:@selector(setColorButtonTapped:)];
    UIBarButtonItem *clearAll=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"clearAll"] style:UIBarButtonItemStylePlain target:self action:@selector(clearAll)];
    UIBarButtonItem *save=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"save"] style:UIBarButtonItemStylePlain target:self action:@selector(saveImage)];
    
    NSArray *toolbarControls=[NSArray arrayWithObjects:flexiableSpace,connect,flexiableSpace,pencil,flexiableSpace,eraser,flexiableSpace,color,flexiableSpace,clearAll,flexiableSpace,save,flexiableSpace, nil];
    self.toolbarItems=toolbarControls;
    
    [connect release];
    [pencil release];
    [eraser release];
    [color release];
    [clearAll release];
    [save release];
    [flexiableSpace release];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    slateImage.frame = self.view.frame;
	[self.view addSubview:slateImage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark GKPeerPickerControllerDelegate
// Implement This to do coustm connection between deveices over WiFi
- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type {
    
    if (type == GKPeerPickerConnectionTypeOnline) {
        
        picker.delegate = nil;
        
        [picker dismiss];
        
        [picker autorelease];
        
        // Implement your own internet user interface here.
        
    }
    
}
// This creates a unique Connection Type for this particular applictaion
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    // Create a session with a unique session ID - displayName:nil = Takes the iPhone Name
    GKSession* session = [[GKSession alloc] initWithSessionID:@"com.iSumit.iCommunicator" displayName:nil sessionMode:GKSessionModePeer];
    return [session autorelease];
}

// Tells us that the peer was connected
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    
    // Get the session and assign it locally
    self.whiteBoardSession = session;
    session.delegate = self;
    
    //No need of teh picekr anymore
    picker.delegate = nil;
    [picker dismiss];
    [picker autorelease];
}

// Function to receive data when sent from peer
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    NSString *whatDidIget = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    if ([whatDidIget isEqualToString:@"Clear"])
    {
        slateImage.image = nil;
    }
    else if([whatDidIget isEqualToString:@"Eraser"])
    {
        self.preColor=self.drawcolor;
        self.prelineWidth=self.lineWidth;
        self.drawcolor = [UIColor whiteColor];
        self.lineWidth = 50.0;
    }
    else if ([whatDidIget isEqualToString:@"Thin"]) 
    {
        self.drawcolor = self.preColor;
        self.lineWidth=self.prelineWidth;
        self.lineWidth=2.5;
    } 
    else if ([whatDidIget isEqualToString:@"Small"]) 
    {
        self.drawcolor = self.preColor;
        self.lineWidth=self.prelineWidth;
        self.lineWidth=5.0;
    }
    else if ([whatDidIget isEqualToString:@"Medium"]) 
    {
        self.drawcolor = self.preColor;
        self.lineWidth=self.prelineWidth;
        self.lineWidth=7.5;
    }
    else if ([whatDidIget isEqualToString:@"Large"]) 
    {
        self.drawcolor = self.preColor;
        self.lineWidth=self.prelineWidth;
        self.lineWidth=10.0;
    }
    else if ([whatDidIget isEqualToString:@"X-Large"]) 
    {
        self.drawcolor = self.preColor;
        self.lineWidth=self.prelineWidth;
        self.lineWidth=12.5;
    }

    else if ([whatDidIget isEqualToString:@"White"]) 
    {
        self.drawcolor = [UIColor whiteColor];
        self.preColor=self.drawcolor;

    } 
    else if ([whatDidIget isEqualToString:@"Red"]) {
        self.drawcolor = [UIColor redColor];
        self.preColor=self.drawcolor;

    }
    else if ([whatDidIget isEqualToString:@"Orange"]){
        self.drawcolor = [UIColor orangeColor];
        self.preColor=self.drawcolor;

    }
    else if ([whatDidIget isEqualToString:@"Yellow"]){
        self.drawcolor = [UIColor yellowColor];
        self.preColor=self.drawcolor;

    }
    else if ([whatDidIget isEqualToString:@"Green"]){
        self.drawcolor = [UIColor greenColor];
        self.preColor=self.drawcolor;

    }
    else if ([whatDidIget isEqualToString:@"Blue"]){
        self.drawcolor = [UIColor blueColor];
        self.preColor=self.drawcolor;

    }
    else if ([whatDidIget isEqualToString:@"Cyan"]){
        self.drawcolor = [UIColor cyanColor];
        self.preColor=self.drawcolor;

    }
    else if ([whatDidIget isEqualToString:@"Black"]){
        self.drawcolor = [UIColor blackColor];
        self.preColor=self.drawcolor;

    }
    else if ([whatDidIget isEqualToString:@"Disconnect"])
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected" message:@"You are no longer connected to your peers." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [whiteBoardSession disconnectFromAllPeers];
        [whiteBoardSession setAvailable:NO];
        [whiteBoardSession setDelegate:nil];
        [whiteBoardSession setDataReceiveHandler:nil withContext:nil];
        isConnected=NO;
    }
    CGPoint temp= CGPointFromString(whatDidIget);
    lastPoint=temp;
    UIGraphicsBeginImageContext(self.view.frame.size);
    [slateImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), lineWidth);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.drawcolor.CGColor);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    CGContextFlush(UIGraphicsGetCurrentContext());
    slateImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [whatDidIget release];
}

#pragma mark -
#pragma mark GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
    
    if(state == GKPeerStateConnected)
    {
        // Add the peer to the Array
        [whiteBoardPeers addObject:peerID];
        NSString *str = [NSString stringWithFormat:@"Connected with %@",[session displayNameForPeer:peerID]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connected" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        isConnected=YES;
        [alert show];
        [alert release];
        
        // Used to acknowledge that we will be sending data
        [session setDataReceiveHandler:self withContext:nil];
        
    }
    
}


@end
