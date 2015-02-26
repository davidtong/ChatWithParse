//
//  ChatViewController.m
//  chatParse
//
//  Created by David Tong on 2/25/15.
//  Copyright (c) 2015 David Tong. All rights reserved.
//

#import "ChatViewController.h"
#import "MessageCell.h"
#import "Parse/Parse.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendChatButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *allMessages;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self onRefresh];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UINib *cell = [UINib nibWithNibName:@"MessageCell" bundle:nil];
    [self.tableView registerNib:cell forCellReuseIdentifier:@"MessageCell"];
    [self.tableView reloadData];

    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSendChat:(id)sender {
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"text"] = self.chatTextField.text;
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //[self onRefresh];
        } else {
            // There was a problem, check error.description
            NSLog(@"Msg not sent:%@", error);
        }
    }];
}

- (void) onTimer {
    [self onRefresh];
    NSLog(@"timer refreshed");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    cell.messageLabel.text = self.allMessages[indexPath.row][@"text"];
    NSLog(@"Messages:%@ and at %@", self.allMessages, self.allMessages[indexPath.row]);
    return cell;
}

- (void)onRefresh {
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    //[query whereKey:@"text" equalTo:@"Dan Stemkoski"];
    [query selectKeys:@[@"text"]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            /*
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
             */
            self.allMessages = objects;
            [self.tableView reloadData];
            NSLog(@"Messages:%@", self.allMessages);
            
        } else {
            
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
