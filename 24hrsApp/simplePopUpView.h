//
//  simplePopUpView.h
//  24hrsApp
//
//  Created by Julie Kwon on 7/26/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@protocol simplePopUpViewDelegate

-(void)eventWasSuccessfullySaved;

@end


@interface simplePopUpView : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *eventTitle;

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@property (nonatomic, strong) EKEventStore *eventStore;
@property(assign, nonatomic) NSString *pressedTime;
@property(assign, nonatomic) NSString *eventTitleString;
@property (nonatomic, strong) NSDate *eventStartDate;
@property (nonatomic, strong) NSDate *eventEndDate;
@property (nonatomic, strong) NSDate *eventDate;
@property (nonatomic, strong) NSDate *rightNowTime;

@property (weak, nonatomic) IBOutlet UIView *color12;
@property (weak, nonatomic) IBOutlet UIView *color11;
@property (weak, nonatomic) IBOutlet UIView *color10;
@property (weak, nonatomic) IBOutlet UIView *color9;
@property (weak, nonatomic) IBOutlet UIView *color8;
@property (weak, nonatomic) IBOutlet UIView *color7;
@property (weak, nonatomic) IBOutlet UIView *color6;
@property (weak, nonatomic) IBOutlet UIView *color5;
@property (weak, nonatomic) IBOutlet UIView *color4;
@property (weak, nonatomic) IBOutlet UIView *color3;
@property (weak, nonatomic) IBOutlet UIView *color2;
@property (weak, nonatomic) IBOutlet UIView *color1;
@property (weak, nonatomic) IBOutlet UIView *defaultColor;

@property (weak, nonatomic) IBOutlet UILabel *endsTime;
@property (weak, nonatomic) IBOutlet UILabel *startsTime;
@property (weak, nonatomic) IBOutlet UILabel *dateDisplay;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (strong, nonatomic) IBOutlet UIDatePicker *startPicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *endPicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITableView *tblEvent;

@property (nonatomic, strong) id<simplePopUpViewDelegate> delegate;

-(void) backclicked:(id)sender;

@end
