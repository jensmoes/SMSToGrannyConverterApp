//
//  TGMakeCallViewController.m
//  TextGranny
//
//  Created by Jens Troest on 9/3/14.
//  Copyright (c) 2014 Jens Troest. All rights reserved.
//

#import "TGMakeCallViewController.h"
#import "TCConnection.h"
#import "TGTwilioManager.h"

@interface TGMakeCallViewController ()

@end

@implementation TGMakeCallViewController{
    TGTwilioManager* _callManager;//Private property to track connection
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _numberField.delegate = self;
    _callManager = [TGTwilioManager sharedInstance];
    [self updateConnectionStatus: [[NSNumber alloc]initWithInt:_callManager.connection.state]];
     
}

//-(void) dealloc
//{
//    if(_outgoingCall)
//    {
//        _outgoingCall = Nil;
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)connectButtonPressed:(id)sender {
    if(_callManager.connection.state == TCConnectionStateConnected || _callManager.connection.state == TCConnectionStateConnecting)
    {
        [_callManager.connection disconnect];
        [self updateConnectionStatus: [[NSNumber alloc]initWithInt:TCConnectionStateDisconnected]];//connection.state not thread safe
    }
    else{
        if(_numberField.text.length > 0)
        {
            [_callManager connectCall:_numberField.text withConnectionHandler:^void(TCConnectionState state) {
                NSNumber* stateObj = [[NSNumber alloc]initWithInt:state];
                [self performSelectorOnMainThread:@selector(updateConnectionStatus:) withObject:stateObj waitUntilDone:NO];
            }
             ];
            [_numberField resignFirstResponder];
        }
        else{
            [[[UIAlertView alloc] initWithTitle:@"No recipient" message:@"Please enter a phone number or name to call" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

//hack for demo account
- (IBAction)anyKeyPressed:(id)sender {
    if (_callManager.connection.state == TCConnectionStateConnected) {
        [_callManager.connection sendDigits:@"1"];
    }
}

- (void) updateConnectionStatus:(NSNumber*) stateObj
{
    TCConnectionState state = (TCConnectionState) [stateObj integerValue];

    switch (state) {
        case TCConnectionStateConnected:
            _statusLabel.text = @"Call active";
            break;
        case TCConnectionStateConnecting:
            _statusLabel.text = @"Calling";
            break;
        default:
            _statusLabel.text = @"Not connected";
    }
    
    [_statusLabel setNeedsDisplay];

    if (state == TCConnectionStateConnected || state == TCConnectionStateConnecting)
    {
        [_callButton setTitle:@"Hang Up" forState:UIControlStateNormal ];
        NSLog(@"Button hang up");
    }
    else{
        [_callButton setTitle:@"Dial" forState:UIControlStateNormal];
        NSLog(@"Button Dial");
    }
    [_callButton setNeedsDisplay];
    
}

#pragma mark - TextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    //Dismiss keyboard on return
    [_numberField resignFirstResponder];
    return YES;
}
@end
