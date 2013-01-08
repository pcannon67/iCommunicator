//
//  AppDelegate.m
//  iCommunicator
//
//  Created by Sumit Lonkar on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "TranslatorViewController.h"
#import "WhiteBoardViewController.h"
#import "SettingsTableViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];

    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    //Alert Message To Set Up User Name and Translation Language
    
    
    //     
    netService = [[NSNetService alloc] initWithDomain:@""
                                                 type:@"_MyService._tcp."
                                                 name:@""
                                                 port:9876];	
    netService.delegate = self;	
    [netService publish];
    
    // Override point for customization after application launch.
    TranslatorViewController *translator = [[[TranslatorViewController alloc]initWithNibName:@"TranslatorViewController" bundle:nil]autorelease];
    UINavigationController *navTraslator=[[[UINavigationController alloc]initWithRootViewController:translator]autorelease];
    navTraslator.tabBarItem.title=@"Translator";
    navTraslator.tabBarItem.image=[UIImage imageNamed:@"translator"];
    WhiteBoardViewController *whiteBoard=[[[WhiteBoardViewController alloc]initWithNibName:@"WhiteBoardViewController" bundle:nil]autorelease];
    UINavigationController *navWhiteBoard=[[[UINavigationController alloc]initWithRootViewController:whiteBoard]autorelease];
    SettingsTableViewController *settings=[[[SettingsTableViewController alloc]initWithNibName:@"SettingsTableViewController" bundle:nil]autorelease];
    UINavigationController *navSettings=[[[UINavigationController alloc]initWithRootViewController:settings]autorelease];
    navSettings.tabBarItem.title=@"Settings";
    navSettings.tabBarItem.image=[UIImage imageNamed:@"settings"];
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:navTraslator,navWhiteBoard,navSettings, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)netService:(NSNetService *)aNetService
	didNotPublish:(NSDictionary *)dict {
    NSLog(@"Service did not publish: %@", dict);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [netService stop];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [netService stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [netService publish];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


@end
