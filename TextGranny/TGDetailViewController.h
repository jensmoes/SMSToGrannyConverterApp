//
//  TGDetailViewController.h
//  TextGranny
//
//  Created by Jens Troest on 9/3/14.
//  Copyright (c) 2014 Jens Troest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
