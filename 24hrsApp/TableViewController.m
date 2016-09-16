//
//  TableViewController.m
//  24hrsApp
//
//  Created by Julie Kwon on 7/19/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

@synthesize startTime;
@synthesize startPicker;
@synthesize endTime;
@synthesize endPicker;
@synthesize pickerView;
@synthesize interval;
@synthesize  viewController;

#pragma mark - delegate method
- (NSInteger) getInterval{
    return interval;
}

#pragma mark - click methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowMainMenu"])
    {
        [self doneClicked:sender];
        viewController = segue.destinationViewController;
        viewController.delegate= self;
    }
    else{
        viewController = segue.destinationViewController;
        viewController.delegate= self;
    }
}

-(IBAction)doneClicked:(id)sender{
    
    NSInteger row;
    NSArray *repeatPickerData = @[ @(30),@(60) ];
    
    row = [pickerView selectedRowInComponent:0];
    NSLog(@"row value:%ld", (long)row);
    selectedValue = [repeatPickerData objectAtIndex:row];
    NSLog(@"selected value:%@", selectedValue);
    interval = [selectedValue intValue];
    [[NSUserDefaults standardUserDefaults]setInteger:interval forKey:@"interval"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSLog(@"interval: %ld", (long)interval);
    
    
}

#pragma mark - datepicker methods

- (IBAction)startTimeChanged:(id)sender{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"hh:mm a"]; //24hr time format
    NSString *dateString = [outputFormatter stringFromDate:startPicker.date];
    startTime.text = [NSString stringWithFormat:@"%@", dateString];
}


- (void)endHeightChange{
    //if you need hide the cell then
    
    if(endHidden == false){
        endHeight = 0;
        endHidden = true;
    }else{
        endHeight = 44;
        endHidden = false;
    }
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    switch(row) {
        case 0:
            title = @"30 min";
            break;
        case 1:
            title = @"1 hr";
            break;
    }
    return title;
}


- (IBAction)endTimeChange:(id)sender {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"hh:mm a"]; //24hr time format
    NSString *dateString = [outputFormatter stringFromDate:endPicker.date];
    endTime.text = [NSString stringWithFormat:@"%@", dateString];
    
    
    NSDateComponents *endComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[endPicker date]];
    NSDateComponents *startComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[startPicker date]];
    
    
    
    if (startComponent > endComponent) {
        [endComponent setHour:[startComponent hour]];
        [endComponent setMinute:[startComponent minute]];
        [endPicker setDate:[[NSCalendar currentCalendar] dateFromComponents:endComponent]];
    }
    
}

#pragma mark - table view methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.tag== 0){
        NSLog(@"histart");
        
    }else if(cell.tag == 2)
        [self endHeightChange];
}


#pragma mark - view methods

- (void)viewDidLoad {
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    intervalHidden = false;
    endHidden = false;
    startHidden = false;
    
    NSDate* chosen = [NSDate date];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:chosen];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSString *ampm;
    if(hour > 12){
        ampm = @"PM";
    }else{
        ampm = @"AM";
        if(hour == 0)
            hour = 12;
    }
    NSLog(@"chosen %ld: %ld",hour,(long)minute);
    minute -= minute%15;
    
    if(hour > 12){
        hour-=12;
    }
    startTime.text = [NSString stringWithFormat:@"%02ld:%02ld %@",(long)hour,(long)minute,ampm];
    endTime.text = [NSString stringWithFormat:@"%02ld:%02ld %@",(long)hour,(long)minute,ampm];
    [super viewDidLoad];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
