//
//  CalendarViewController.h
//  24hrsApp
//
//  Created by Julie Kwon on 8/17/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar/JTCalendar.h"
#import "ViewController.h"

@interface CalendarViewController : UIViewController<JTCalendarDelegate, UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *tableData;
    NSInteger numRow;
}

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;
@property (strong, nonatomic) JTCalendarManager *calendarManager;
@property (nonatomic, strong) NSIndexPath *savedIndexPathForThePressedCell;

// view
@property (nonatomic, strong) ViewController *vc;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *weeklyTableView;

// events
@property (nonatomic, strong) NSArray *eventsArr;
@property (assign, nonatomic) NSInteger numEvent;
@property (strong, nonatomic) NSDate* today;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end
