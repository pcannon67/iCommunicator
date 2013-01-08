//
//  TranslatorViewController.h
//  iCommunicator
//
//  Created by Sumit Lonkar on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
/*
#import <UIKit/UIKit.h>
#import "AudioSessionManager.h"
#import "OpenEarsEventsObserver.h"
 
@class PocketsphinxController;
@class FliteController;

@interface TranslatorViewController : UIViewController <OpenEarsEventsObserverDelegate>
{
    AudioSessionManager *audioSessionManager; // This is OpenEars' AudioSessionManager class. 
    OpenEarsEventsObserver *openEarsEventsObserver; // A class whose delegate methods which will allow us to stay informed of changes in the Flite and Pocketsphinx statuses.
	PocketsphinxController *pocketsphinxController; // The controller for Pocketsphinx (voice recognition).
	FliteController *fliteController; // The controller for Flite (speech).
    
    IBOutlet UITextView *textView;
    IBOutlet UITextField *textField;
    IBOutlet UIButton *button;
    
    BOOL usingStartLanguageModel;
    
    NSString *pathToGrammarToStartAppWith;
	NSString *pathToDictionaryToStartAppWith;
	
	NSString *pathToDynamicallyGeneratedGrammar;
	NSString *pathToDynamicallyGeneratedDictionary;
    
    NSMutableData *responseData;
    NSMutableArray *translations;
    NSString *_lastText;

}
@property (nonatomic, retain) AudioSessionManager *audioSessionManager;
@property (nonatomic, copy) NSString * lastText;

@property (nonatomic, retain) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic, retain) PocketsphinxController *pocketsphinxController;
@property (nonatomic, retain) FliteController *fliteController;

@property (nonatomic, assign) BOOL usingStartLanguageModel;

@property (nonatomic, copy) NSString *pathToGrammarToStartAppWith;
@property (nonatomic, copy) NSString *pathToDictionaryToStartAppWith;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedGrammar;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedDictionary;

- (IBAction)doTranslation;
@end
*/

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

@interface TranslatorViewController : UIViewController 
<UITableViewDelegate, 
UITableViewDataSource,
NSNetServiceDelegate, 
NSNetServiceBrowserDelegate> {
    
    IBOutlet UITableView *tbView;
    IBOutlet UITextView *debug;
	
    
    NSNetServiceBrowser *browser;	
    NSMutableArray *services;
	
	IBOutlet UITextField *message;
	NSString *serviceIP;
    AsyncSocket *listenSocket;
	AsyncSocket *clientSocket;
	NSMutableArray *connectedSockets;	
    
    
    NSMutableData *responseData;
    NSMutableArray *translations;
    NSString *_lastText;
    
}

-(void) resolveIPAddress:(NSNetService *)service;
-(void) browseServices;


@property (nonatomic, retain) UITableView *tbView;
@property (nonatomic, retain) UITextView *debug;

@property (nonatomic, retain) UITextField *message;

@property (readwrite, retain) NSNetServiceBrowser *browser;
@property (readwrite, retain) NSMutableArray *services;

@property (nonatomic, retain) AsyncSocket *clientSocket;
@property (nonatomic, retain) NSString *serviceIP;

@property (nonatomic, copy) NSString * lastText;

NSString* CWCurrentLanguageIdentifier();
NSString* CWTranslatedString(NSString* string, NSString* sourceLanguageIdentifier);


-(IBAction) btnConnect:(id)sender;
-(IBAction) btnSend:(id)sender;
-(IBAction) doneEditing:(id) sender;


@end