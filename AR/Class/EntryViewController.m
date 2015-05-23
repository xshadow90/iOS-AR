//
//  EntryViewController.m
//  AR
//
//  Created by Jiyue Wang on 5/16/15.
//  Copyright (c) 2015 Jiyue Wang. All rights reserved.
//

#import "EntryViewController.h"
#import "GameViewController.h"

static NSString *TAG = @"EntryViewController";

@interface EntryViewController () {
    
    GameViewController *gameViewController;
    UIWindow *gameWindow;
}

@end

@implementation EntryViewController

#pragma mark protocal

- (void)dealloc {
    
    NSLog(@"%@: deallocating...", TAG);
    [gameViewController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    gameViewController = [[GameViewController alloc] initWithNibName:nil bundle:nil];
    NSLog(@"%@: finish view loading", TAG);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark function

- (IBAction)didButtomPressed: (id)sender {
    
    [gameViewController printCamIntrinsicFile];
    
    NSLog(@"%@:Button pressed: %@", TAG, [sender currentTitle]);
    if ([[sender currentTitle] isEqualToString: @"Single Mode"]) {
        NSLog(@"%@: start single mode", TAG);
    } else if ([[sender currentTitle] isEqualToString: @"Multi Mode"]) {
        NSLog(@"%@: start multi mode", TAG);
    }
    [self showViewController: gameViewController];
}

- (void)showViewController:(GameViewController *)vc {
    
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    vc.view.frame = self.view.bounds;

}

- (void)hideViewController:(GameViewController *)vc {
    
    [vc willMoveToParentViewController:nil];
    [vc removeFromParentViewController];
    
    [vc.view removeFromSuperview];
    
}

@end
