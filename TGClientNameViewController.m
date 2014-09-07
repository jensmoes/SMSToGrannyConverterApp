//
//  TGClientNameViewController.m
//  TextGranny
//
//  Created by Jens Troest on 9/3/14.
//  Copyright (c) 2014 Jens Troest. All rights reserved.
//

#import "TGClientNameViewController.h"

@interface TGClientNameViewController ()

@end

@implementation TGClientNameViewController

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
    _textField.delegate = self;
    // Do any additional setup after loading the view.
    NSString* clientName = [[NSUserDefaults standardUserDefaults] stringForKey:@"clientName"];
    if([clientName length] > 0)
    {
        self.textField.text = clientName;
    }
    
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

- (IBAction)saveButtonPressed:(id)sender {
//    if(_textField.text.length > 0)
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if(defaults != nil)
        {
            [defaults setValue:_textField.text forKey:@"clientName"];
            [defaults synchronize];
        }
        [self performSegueWithIdentifier:@"unwindFromClientNameSegue" sender:_textField.text];//You can use Nil or self for sender too but text could be useful in prepareForSegue
    }
}

#pragma mark - TextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    //Dismiss keyboard on return
    [_textField resignFirstResponder];
    return YES;
}

@end
