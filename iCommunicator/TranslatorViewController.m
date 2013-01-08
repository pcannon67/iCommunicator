//
//  TranslatorViewController.m
//  iCommunicator
//
//  Created by Sumit Lonkar on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <netinet/in.h>
#import <arpa/inet.h>
#import "SBJson.h"
#import "TranslatorViewController.h"

@implementation TranslatorViewController

@synthesize tbView;
@synthesize debug;
@synthesize browser;
@synthesize services;

@synthesize clientSocket;
@synthesize serviceIP;

@synthesize message;

@synthesize lastText = _lastText;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSData             *address = nil;
	struct sockaddr_in *socketAddress = nil;
	
	if ([[[services objectAtIndex:indexPath.row] addresses] count] > 0) {
		address = [[[services objectAtIndex:indexPath.row] addresses] objectAtIndex: 0];
		socketAddress = (struct sockaddr_in *) [address bytes];
		self.serviceIP = [NSString stringWithFormat: @"%s", inet_ntoa(socketAddress->sin_addr)];
	}	
}

-(IBAction) btnConnect:(id)sender {
	NSError *err;	
	debug.text = [debug.text stringByAppendingFormat:@"%@\n", serviceIP];
	
    AsyncSocket	*socket = [[AsyncSocket alloc] initWithDelegate:self];			
    if(![socket connectToHost:self.serviceIP onPort:12345 error:&err])
	{
		debug.text = [debug.text stringByAppendingString:@"Error connecting\n"];
	}
	else {
		debug.text = [debug.text stringByAppendingString:@"Connected\n"];
		self.clientSocket = socket;
	}
	[socket release];	
}

-(IBAction) btnSend:(id)sender 
{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //NSString *username = [defaults stringForKey:@"name_preference"];
    //NSString *lang = [defaults stringForKey:@"lang_preference"];
    
    NSString *username =[[NSUserDefaults standardUserDefaults]objectForKey:@"userKey"];
    NSString *lang =[[NSUserDefaults standardUserDefaults]objectForKey:@"languageKey"];
	NSString *msg =[NSString stringWithFormat:@"%@;%@;%@\r\n",message.text, username, lang];
    
	NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
	[self.clientSocket writeData:data withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
	[connectedSockets addObject:newSocket];
	debug.text = [debug.text stringByAppendingString:@"didAcceptNewSocket\n"];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
	debug.text = [debug.text stringByAppendingString:@"didConnectToHost\n"];
	self.clientSocket = sock;
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
	debug.text = [debug.text stringByAppendingString:@"didWriteDataWithTag\n"];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	debug.text = [debug.text stringByAppendingString:@"didReadData\n"];
	
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
	if (msg) {		
        
        NSArray *components = [msg componentsSeparatedByString:@";"];
        
        NSString *messageContent = [components objectAtIndex:0];
        NSString *from = [components objectAtIndex:1];
        NSString *sourceLang = [components objectAtIndex:2];
        
        NSString *translatedMessage = CWTranslatedString(messageContent, sourceLang);
        
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:from 
														message:translatedMessage
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];		
	}
	else {
		debug.text = [debug.text stringByAppendingString:@"Error converting received data into UTF-8 String\n"];
	}
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
	debug.text = [debug.text stringByAppendingString:@"willDisconnectWithError\n"];
	debug.text = [debug.text stringByAppendingFormat:@"Client Disconnected: %@:%hu\n", [sock connectedHost], [sock connectedPort]];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
	[connectedSockets removeObject:sock];
	debug.text = [debug.text stringByAppendingString:@"onSocketDidDisconnect\n"];
}

-(IBAction) doneEditing:(id) sender {
	[sender resignFirstResponder];	
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return [services count];   
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[services objectAtIndex:indexPath.row] hostName];
	
    return cell;	
}

-(void) browseServices {
	services = [NSMutableArray new];
    self.browser = [[NSNetServiceBrowser new] autorelease];
    self.browser.delegate = self;	
    [self.browser searchForServicesOfType:@"_MyService._tcp." inDomain:@""];
}

-(void) viewDidLoad 
{
     self.navigationController.navigationBar.barStyle=UIBarStyleBlack;
    self.title=@"Translator";
	debug.text = @"";
	
	listenSocket = [[AsyncSocket alloc] initWithDelegate:self];		
	connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
	[listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
	
	NSError *error = nil;
	if(![listenSocket acceptOnPort:12345 error:&error])
	{
		debug.text = [debug.text stringByAppendingString:@"Error listening\n"];
	}
	else {
		debug.text = [debug.text stringByAppendingString:@"Listening...\n"];
	}	
	
    [self browseServices];
    [super viewDidLoad];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser
          didFindService:(NSNetService *)aService
              moreComing:(BOOL)more {	
	
    [services addObject:aService];	
    debug.text = [debug.text stringByAppendingString:				  
				  @"Found service. Resolving address...\n"];	
    [self resolveIPAddress:aService];	
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser
        didRemoveService:(NSNetService *)aService 
			  moreComing:(BOOL)more {
	
    [services removeObject:aService];
    debug.text = [debug.text stringByAppendingFormat:@"Removed: %@\n",				  
				  [aService hostName]];
	
    [self.tbView reloadData];	
}


-(void) resolveIPAddress:(NSNetService *)service {   
    NSNetService *remoteService = service;
    remoteService.delegate = self;
    [remoteService resolveWithTimeout:0];
}


-(void)netServiceDidResolveAddress:(NSNetService *)service {
    
    NSData             *address = nil;
    struct sockaddr_in *socketAddress = nil;
    NSString           *ipString = nil;
    int                port;
	
    for(int i=0;i < [[service addresses] count]; i++ ) {
        
        address = [[service addresses] objectAtIndex: i];
        socketAddress = (struct sockaddr_in *) [address bytes];
        ipString = [NSString stringWithFormat: @"%s",
					inet_ntoa(socketAddress->sin_addr)];
		
        port = socketAddress->sin_port;		
        debug.text = [debug.text stringByAppendingFormat:					  
					  @"Resolved: %@—>%@:%hu\n", [service hostName], ipString, port];		
    }
	
    [self.tbView reloadData];	
}

-(void)netService:(NSNetService *)service
    didNotResolve:(NSDictionary *)errorDict {
    debug.text = [debug.text stringByAppendingFormat:
				  @"Could not resolve: %@\n", errorDict];	
}

- (void)dealloc {
	[tbView release];
    [debug release];   
    [browser release];
    [services release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload {
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection release];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    [responseData release];
    
    NSMutableDictionary *luckyNumbers = [responseString JSONValue];
    [responseString release];
    if (luckyNumbers != nil) {
        
        NSDecimalNumber * responseStatus = [luckyNumbers objectForKey:@"responseStatus"];
        if ([responseStatus intValue] != 200) {
            return;
        }
        
        NSMutableDictionary *responseDataDict = [luckyNumbers objectForKey:@"responseData"];
        if (responseDataDict != nil) {
            NSString *translatedText = [responseDataDict objectForKey:@"translatedText"];
            [translations addObject:translatedText];
            self.lastText = translatedText;            
            
        }
    }
    
}

NSString* CWCurrentLanguageIdentifier() 
{
    static NSString* currentLanguage = nil;
    if (currentLanguage == nil) 
    {
        
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //currentLanguage = [defaults stringForKey:@"lang_preference"];
         NSString *langString  =[[NSUserDefaults standardUserDefaults]objectForKey:@"translationParameter"];
        NSLog(@"Language parameter 1 %@",langString);
        currentLanguage=[[NSUserDefaults standardUserDefaults]objectForKey:@"languageKey"];
        NSLog(@"Language parameter 2 %@",currentLanguage);
    }
    return currentLanguage;
}

NSString* CWTranslatedString(NSString* string, NSString* sourceLanguageIdentifier) {
    
    static NSString* queryURL = @"https://www.googleapis.com/language/translate/v2?key=AIzaSyBwPqnT7uRPfHrts2xVqw690_THYEMmpKA&q=%@&source=%@&target=%@";
    
    if (sourceLanguageIdentifier == nil) {
        
        sourceLanguageIdentifier = @"en";
        
    }
    
    if ([sourceLanguageIdentifier isEqual:CWCurrentLanguageIdentifier()] || string == nil) {
        
        return string;
        
    }
    
    NSString* escapedString = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* query = [NSString stringWithFormat:queryURL,
                       escapedString, sourceLanguageIdentifier, CWCurrentLanguageIdentifier()];
    
    NSString* response = [NSString stringWithContentsOfURL:[NSURL URLWithString:query]
                                                  encoding:NSUTF8StringEncoding error:NULL];
    
    if (response == nil) {
        
        return string;
        
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:response];
    
    if (![scanner scanUpToString:@"\"translatedText\": \"" intoString:NULL]) {
        
        return string;
        
    }
    
    if (![scanner scanString:@"\"translatedText\": \"" intoString:NULL]) {
        
        return string;
        
    }
    
    NSString* result = nil;
    if (![scanner scanUpToString:@"\"" intoString:&result]) {
        return string;
    }
    return result;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end


/*
#import "TranslatorViewController.h"
#import "AudioSessionManager.h"
#import "PocketsphinxController.h"
#import "FliteController.h"
#import "OpenEarsEventsObserver.h"
#import "LanguageModelGenerator.h"
#import "SBJson.h"

@implementation TranslatorViewController
@synthesize audioSessionManager;
@synthesize lastText = _lastText;

@synthesize pocketsphinxController;
@synthesize fliteController;

@synthesize openEarsEventsObserver;
@synthesize usingStartLanguageModel;

@synthesize pathToGrammarToStartAppWith;
@synthesize pathToDictionaryToStartAppWith;
@synthesize pathToDynamicallyGeneratedGrammar;
@synthesize pathToDynamicallyGeneratedDictionary;

-(void)dealloc
{
    [super dealloc];
    [audioSessionManager release];
    [_lastText release];
    [pocketsphinxController release];
    [fliteController release];
    [openEarsEventsObserver release];
    [pathToGrammarToStartAppWith release];
    [pathToGrammarToStartAppWith release];
    [pathToDynamicallyGeneratedGrammar release];
    [pathToDynamicallyGeneratedDictionary release];
    
}


-(void)connect
{ 
    NSLog(@"Connect Tapped");
}

-(void)record
{ 
    NSLog(@"Record Tapped");
}
-(void)transmit
{ 
    NSLog(@"Transmit Tapped");
}

// Lazily instantiated AudioSessionManager object. This class can definitely only be instantiated as an object once in the app, so this is a pretty safe way to allocate it.
- (AudioSessionManager *)audioSessionManager 
{
	if (audioSessionManager == nil) {
		audioSessionManager = [[AudioSessionManager alloc] init];
	}
	return audioSessionManager;
}

#pragma mark -
#pragma mark Lazy Allocation

// Lazily allocated PocketsphinxController.
- (PocketsphinxController *)pocketsphinxController { 
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
	}
	return pocketsphinxController;
}

// Lazily allocated FliteController.
- (FliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[FliteController alloc] init];
	}
	return fliteController;
}

// Lazily allocated OpenEarsEventsObserver.
- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title=@"Translator";
        self.tabBarItem.title=@"Translator";
        self.tabBarItem.image=[UIImage imageNamed:@"translator"];
        
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
    self.navigationController.navigationBar.barStyle=UIBarStyleBlack;
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.toolbarHidden=NO;
    self.navigationController.toolbar.barStyle=UIBarStyleBlack;
    // self.navigationController.toolbar.translucent=YES;
    
    UIBarButtonItem *flexiableSpace=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *connect=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"connect"] style:UIBarButtonItemStylePlain target:self action:@selector(connect)];
    UIBarButtonItem *record=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"record"] style:UIBarButtonItemStylePlain target:self action:@selector(record)];
    UIBarButtonItem *transmit=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"transmit"] style:UIBarButtonItemStylePlain target:self action:@selector(transmit)];

    
    NSArray *toolbarControls=[NSArray arrayWithObjects:flexiableSpace,connect,flexiableSpace,record,flexiableSpace,transmit,flexiableSpace,nil];
    self.toolbarItems=toolbarControls;
    [flexiableSpace release];
    [connect release];
    [record release];
    [transmit release];
   
    
    [self.audioSessionManager startAudioSession];
    [self.openEarsEventsObserver setDelegate:self];
    translations = [[NSMutableArray alloc] init];
    
	self.pathToGrammarToStartAppWith = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"OpenEars1.languagemodel"];    
    
	self.pathToDictionaryToStartAppWith = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"OpenEars1.dic"]; 
    
    self.usingStartLanguageModel = TRUE; 
    
    LanguageModelGenerator *languageModelGenerator = [[LanguageModelGenerator alloc] init]; 
    
    NSArray *languageArray = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects: // All capital letters.
															 @"CHANGE MODEL",
															 @"MONDAY",
															 @"TUESDAY",
															 @"WEDNESDAY",
															 @"THURSDAY",
															 @"FRIDAY",
															 @"SATURDAY",
															 @"SUNDAY",
															 @"QUIDNUNC",
															 nil]];  
    
	NSError *error = [languageModelGenerator generateLanguageModelFromArray:languageArray withFilesNamed:@"OpenEarsDynamicGrammar"]; 
	NSDictionary *dynamicLanguageGenerationResultsDictionary = nil;
	if([error code] != noErr) {
		NSLog(@"Dynamic language generator reported error %@", [error description]);	
	} else {
		dynamicLanguageGenerationResultsDictionary = [error userInfo];    
    }

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
- (void)performTranslation {
    
    responseData = [[NSMutableData data] retain];
    
    //NSString *langString = @"en|mr";
    NSString *langString  =[[NSUserDefaults standardUserDefaults]objectForKey:@"translationParameter"];
    NSLog(@"Language parameter %@",langString);
    NSString *textEscaped = [_lastText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *langStringEscaped = [langString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/language/translate?q=%@&v=1.0&langpair=%@",
                     textEscaped, langStringEscaped];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
    
}

- (IBAction)doTranslation 
{
    
    [translations removeAllObjects];
    [textField resignFirstResponder];
    button.enabled = NO;
    self.lastText = textField.text;
    [translations addObject:_lastText];
    textView.text = _lastText;    
    [self performTranslation];
    [self.fliteController say:textView.text withVoice:@"cmu_us_slt8k"];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    textView.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
    button.enabled = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection release];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    [responseData release];
    
    NSMutableDictionary *luckyNumbers = [responseString JSONValue];
    [responseString release];
    if (luckyNumbers != nil) {
        
        NSDecimalNumber * responseStatus = [luckyNumbers objectForKey:@"responseStatus"];
        if ([responseStatus intValue] != 200) {
            button.enabled = YES;
            return;
        }
        
        NSMutableDictionary *responseDataDict = [luckyNumbers objectForKey:@"responseData"];
        if (responseDataDict != nil) {
            NSString *translatedText = [responseDataDict objectForKey:@"translatedText"];
            [translations addObject:translatedText];
            self.lastText = translatedText;            
            textView.text = [textView.text stringByAppendingFormat:@"\n%@", translatedText];
            button.enabled = YES;
        }
    }
    
}

@end
 */
