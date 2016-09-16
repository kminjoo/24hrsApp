//
//  weekCell.h
//  24hrsApp
//
//  Created by Julie Kwon on 8/20/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface weekCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *contentsLabel;
@property (nonatomic, weak) IBOutlet UIView *upperOne;
@property (nonatomic, weak) IBOutlet UIView *upperTwo;
@property (nonatomic, weak) IBOutlet UIView *lowerOne;
@property (nonatomic, weak) IBOutlet UIView *lowerTwo;
@end
