//
//  TGSelectionViewController.h
//  TextGranny
//
//  Created by Jens Troest on 9/3/14.
//  Copyright (c) 2014 Jens Troest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGSelectionViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSString* clientName;
@property (weak, nonatomic) IBOutlet UILabel *clientLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatus;
@property (weak, nonatomic) IBOutlet UIButton *textGrannyButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@end
