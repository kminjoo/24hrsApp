//
//  TableCell.h
//  24hrsApp
//
//  Created by Julie Kwon on 7/22/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *endTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *contentsLabel;
@property (nonatomic, weak) IBOutlet UIView *upperOne;
@property (nonatomic, weak) IBOutlet UIView *upperTwo;
@property (nonatomic, weak) IBOutlet UIView *lowerOne;
@property (nonatomic, weak) IBOutlet UIView *lowerTwo;
@property (nonatomic, weak) IBOutlet UIView *timeIndicator;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end
