//
//  FERRYExampleAppDelegate.h
//  FERRYExample
//
//  Created by Jordi.Martinez on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FERRYExampleViewController;

@interface FERRYExampleAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet FERRYExampleViewController *viewController;

@end
