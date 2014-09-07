//
//  TGSelectionViewController.m
//  TextGranny
//
//  Created by Jens Troest on 9/3/14.
//  Copyright (c) 2014 Jens Troest. All rights reserved.
//

#import "TGSelectionViewController.h"
#import "TGMakeCallViewController.h"
#import "TGTwilioManager.h"
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>

@interface TGSelectionViewController () <TGTwilioManagerDelegate>

@end

@implementation TGSelectionViewController {
    TCConnection* _incomingConnection;
    BOOL speaker;//Semaphore for speaker output
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
    speaker = YES;
    // Do any additional setup after loading the view.
    _clientName = [[NSUserDefaults standardUserDefaults] stringForKey:@"clientName"];
    if([_clientName length] > 0)
    {
        _clientLabel.text = _clientName;
        [_activityIndicator startAnimating];
        _connectionStatus.text = @"Connecting...";
        TGTwilioManager* tw = [TGTwilioManager sharedInstance];
        tw.clientName = _clientName;
        tw.delegate = self;
    }
    if([MFMessageComposeViewController canSendText])
    {
        NSLog(@"Texting capability present");
        _textGrannyButton.hidden = NO;
    }
    else{
        NSLog(@"Texting capability NOT present");
        _textGrannyButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateCallButton:(NSNumber*) hide
{
    _callButton.hidden = [hide boolValue];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)unwindToSelection:(UIStoryboardSegue*) segue
{
    if([[segue identifier] isEqualToString:@"unwindFromClientNameSegue"])
    {
        //We have changed the name
        //You can also detect this by subsribing to userdefaults changes....
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if(defaults != Nil)
        {
            _clientName = [defaults stringForKey:@"clientName"];
            if([_clientName length])
            {
                _clientLabel.text = _clientName;
            }
            else
            {
                _clientLabel.text = @"No client name set";
            }
            [_clientLabel setNeedsDisplay];
            TGTwilioManager* twg = [TGTwilioManager sharedInstance];
            twg.clientName = _clientName;
        }
    }
    
}

- (void) unwindToRoot
{
    //Go to root view. This is a bit hacky assuming that the presented one is a navigation controller. Should really check first before casting
    UINavigationController * nv = (UINavigationController*) self.presentedViewController;
    UIViewController *vis = [nv visibleViewController];
    [vis dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)callButtonPressed:(id)sender {
    //Hang up incoming call
    [[TGTwilioManager sharedInstance] resetConnection];
    _callButton.hidden = YES;
}
- (IBAction)soundButtonPress:(id)sender {
    AVAudioSession* av = [AVAudioSession sharedInstance];
    if(speaker)
    {
        [av overrideOutputAudioPort:kAudioSessionOverrideAudioRoute_None error:nil];
        [_soundButton setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
        speaker = NO;
    }
    else{
        [av overrideOutputAudioPort:kAudioSessionOverrideAudioRoute_Speaker error:nil];
        [_soundButton setImage:[UIImage imageNamed:@"speaker"] forState:UIControlStateNormal];
        speaker = YES;
    }
}

#pragma mark - TGTwilioManagerDelegate

-(void) didStartListening
{
    [_activityIndicator stopAnimating];
    _connectionStatus.text = @"Listening";
}

-(void) didNotListen
{
    [_activityIndicator stopAnimating];
    _connectionStatus.text = @"Not Listening";
    
}

-(void) didStopListening
{
    [_activityIndicator stopAnimating];
    _connectionStatus.text = @"Listening disconnected";
}

-(void) incomingConnection:(TCConnection *)connection
{
    NSLog(@"Incoming call");
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                initWithTitle:nil
                      delegate:self
             cancelButtonTitle:@"Cancel"
        destructiveButtonTitle:@"Decline"
             otherButtonTitles:@"Accept", nil];
    [actionSheet showInView:self.view];
    [self unwindToRoot];
}

-(void) connectionStateChanged:(TCConnectionState)state
{
    NSNumber* hide = [[NSNumber alloc]initWithBool:YES];
    if(state == TCConnectionStateConnected)
    {
        NSLog(@"Showing END key");
        hide = NO;
    }
    [self performSelectorOnMainThread:@selector(updateCallButton:) withObject:hide waitUntilDone:NO];
}

#pragma mark - UIActionSheetDelegate

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TGTwilioManager *tw = [TGTwilioManager sharedInstance];
    if(buttonIndex == 0)
    {
        [tw.connection reject];
    }
    else
    {
        [tw.connection accept];
    }
}

//#pragma mark - UIAlertViewDelegate
//-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    TGTwilioManager* twg = [TGTwilioManager sharedInstance];
//    if (buttonIndex == 1) {
//        if(twg.connection)
//        {
//            [twg resetConnection];
//        }
//        twg.connection = _incomingConnection;
//        _incomingConnection = Nil;
//        //Go to root view. This is a bit hacky assuming that the presented one is a navigation controller. Should really check first before casting
//        UINavigationController * nv = (UINavigationController*) self.presentedViewController;
//        UIViewController *vis = [nv visibleViewController];
//        [vis dismissViewControllerAnimated:YES completion:nil];
//        [twg.connection accept];
//    }
//    else{
//        [_incomingConnection disconnect];
//        _incomingConnection = Nil;
//    }
//}


@end
