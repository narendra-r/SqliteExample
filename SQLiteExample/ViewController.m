//
//  ViewController.m
//  SQLiteExample
//
//  Created by Narendra Kumar on 3/23/16.
//  Copyright © 2016 Narendra. All rights reserved.
//

#import "ViewController.h"
#import <Parse.h>
#import "DBHandler.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *results=[[DBHandler handler] readDataFromPairTabel];
//    if (results.count==0) {
        PFQuery *query = [PFQuery queryWithClassName:@"Pair"];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [[DBHandler handler] insertDataToPairTabel:objects];
            
        }];
//    }
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
