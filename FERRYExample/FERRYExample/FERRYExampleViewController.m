//
//  FERRYExampleViewController.m
//  FERRYExample
//
//  Created by Jordi.Martinez on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FERRYExampleViewController.h"
#import <FERRYDocker/FERRYDocker.h>


@implementation FERRYExampleViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    FERRYDocker *_dock = [FERRYDocker buildFromFile:@"ferry.xml" toView:self.view];
    
    _boat = [_dock getViewWithName:@"boat"];
    [_boat.superview setClipsToBounds:YES];
    
    UIButton *_submit = (UIButton *)[_dock getViewWithName:@"but_BTN"];
    [_submit addTarget:self action:@selector(doSubmit) forControlEvents:UIControlEventTouchUpInside];    
}


-(void) doSubmit
{
    CGRect boatFrame = _boat.frame;
    boatFrame.origin.x = 360;
    
    [UIView animateWithDuration:1 
                          delay:0 
                        options:UIViewAnimationCurveEaseIn 
                     animations:^(void) {
                         _boat.frame = boatFrame;
                     }       
                     completion:^(BOOL finished) {
                         
                         CGRect backFrame = _boat.frame;
                         backFrame.origin.x = -backFrame.size.width;
                         
                         _boat.frame = backFrame;
                         
                         backFrame.origin.x = 96;
                         
                         [UIView animateWithDuration:1
                                               delay:0
                                             options:UIViewAnimationCurveEaseOut
                                          animations:^(void) {
                                              _boat.frame = backFrame;
                                          }
                                          completion:^(BOOL finished) {
                                              //
                                          }];
                     }];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
