//
//  MasterViewController.m
//  TeamBEN-A4-ObjC
//
//  Created by Nicole Sliwa on 3/11/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    
    if(indexPath.section==0){
        // this is for section 1:
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ModuleA" forIndexPath:indexPath];
        
        cell.textLabel.text = @"Module A";
        cell.detailTextLabel.text = @"Face Detection";
    }
    else if(indexPath.section==1){
        
        // this is for section 1:
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ModuleB" forIndexPath:indexPath];
        
        cell.textLabel.text = @"Module B";
        cell.detailTextLabel.text = @"Heart Rate Monitor";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyBoard;
    UIViewController *controller;
    
    if(indexPath.section == 0) {
        NSLog(@"row 0 selected");
        storyBoard = [UIStoryboard storyboardWithName:@"ModuleA_Storyboard" bundle:nil];
        NSLog(@"found storyboard a");
        controller = [storyBoard instantiateViewControllerWithIdentifier:
                      //@"ModuleA_NavigationController"];
                      @"ModuleA_MasterViewController"];
        NSLog(@"ModuleA_MasterViewController");
        
        //[controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self.navigationController pushViewController:controller animated:YES];
        //[self presentViewController:controller animated:YES completion:nil];
        NSLog(@"presented view");
    }
    
    else if(indexPath.section == 1) {
        NSLog(@"row 1 selected");
        storyBoard = [UIStoryboard storyboardWithName:@"ModuleB_Storyboard" bundle:nil];
        NSLog(@"found storyboard b");
        controller = [storyBoard instantiateViewControllerWithIdentifier:
                      //@"ModuleB_NavigationController"];
                      @"ModuleB_MasterViewController"];
        NSLog(@"ModuleB_RootViewController");
        
        [self.navigationController pushViewController:controller animated:YES];
        //[controller setModalPresentationStyle:UIModalPresentationFullScreen];
        //[self presentViewController:controller animated:YES completion:nil];
        NSLog(@"presented view");
    }
}

@end
