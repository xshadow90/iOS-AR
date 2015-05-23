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
    
    GameViewController *rtViewController;
}

@end

@implementation EntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWindow* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.backgroundColor = [UIColor whiteColor];
    
    rtViewController = [[[GameViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [window setRootViewController:rtViewController];

    NSLog(@"%@: finish view loading", TAG);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didButtomPressed: (id)sender {
    
    NSLog(@"%@:Button pressed: %@", TAG, [sender currentTitle]);
    if ([[sender currentTitle] isEqualToString: @"Single Mode"]) {
        NSLog(@"%@: start single mode", TAG);
    } else if ([[sender currentTitle] isEqualToString: @"Multi Mode"]) {
        NSLog(@"%@: start multi mode", TAG);
    }
    [self showViewController: rtViewController];
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
