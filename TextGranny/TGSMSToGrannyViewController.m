//
//  TGSMSToGrannyViewController.m
//  TextGranny
//
//  Created by Jens Troest on 9/5/14.
//  Copyright (c) 2014 Jens Troest. All rights reserved.
//

#import "TGSMSToGrannyViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface TGSMSToGrannyViewController () <ABPeoplePickerNavigationControllerDelegate,MFMessageComposeViewControllerDelegate>

@end

@implementation TGSMSToGrannyViewController{
}

static NSString* kDestinationSMSNumber = @"6197223236";

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
}

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

- (IBAction)addContactButtonPress:(id)sender {
    ABPeoplePickerNavigationController* picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.displayedProperties = @[ [NSNumber numberWithInt:kABPersonPhoneProperty] ];
    [self presentViewController:picker animated:YES completion:^{
        //
    }];
}

- (IBAction)composeMessage:(id)sender {
    MFMessageComposeViewController *smsPicker = [[MFMessageComposeViewController alloc]init];
    smsPicker.messageComposeDelegate = self;
    smsPicker.recipients = @[kDestinationSMSNumber];
    smsPicker.body = [NSString stringWithFormat:@"%@ ",_textInputField.text];
    [self presentViewController:smsPicker animated:YES completion:^{
        //<#code#>
    }];
    
}


#pragma mark - ABPeoplePickerNavigationControllerDelegate

-(void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}
-(BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if(property == kABPersonPhoneProperty)
    {
//        NSLog(@"%@", identifier);
        ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSArray* phoneNumbers = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(phoneNumberProperty);
        if([phoneNumbers count])
        {
            _textInputField.text = [phoneNumbers firstObject];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

#pragma mark - TextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    //Dismiss keyboard on return
    [_textInputField resignFirstResponder];
    return YES;
}
#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
