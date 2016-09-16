//
//  TableViewController.h
//  24hrsApp
//
//  Created by Julie Kwon on 7/19/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface TableViewController : UITableViewController <ViewControllerDelegate>{
    CGFloat startHeight;
    CGFloat endHeight;
    CGFloat intervalHeight;
    BOOL startHidden;
    bool endHidden;
    BOOL intervalHidden;
    NSString *selectedValue;
}
@property (nonatomic, strong) ViewController *viewController;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic, assign) NSInteger interval;
@property (strong, nonatomic) NSIndexPath *expandedIndexPath;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
-(IBAction)doneClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *intervalTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *endPicker;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *startPicker;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UIPickerView *intervalPicker;
- (NSInteger) getInterval;

@end
