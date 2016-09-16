//
//  ViewController.h
//  24hrsApp
//
//  Created by Julie Kwon on 7/18/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableCell.h"
#import "simplePopUpView.h"
#import <EventKit/EventKit.h>

@class ViewController;
@protocol ViewControllerDelegate <NSObject>
- (NSInteger) getInterval;  //define delegate method to be implemented within another class
@end //end protocol

@interface ViewController : UIViewController <UIBarPositioningDelegate, UITableViewDelegate, UITableViewDataSource>{
    IBOutlet UILabel *dateDisplay;
    NSInteger starts;
    NSInteger ends;
    NSInteger hour;
    NSInteger minute;
    NSInteger numRow;
    //bool isIntervalChanged;
    NSMutableArray *tableData;
}

// Event properties
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *calendar;
@property (nonatomic, strong) NSString *selectedCalendarIdentifier;
@property (nonatomic) BOOL eventsAccessGranted;

// table view properties
@property (nonatomic, strong) NSDictionary *colorMap;
@property (strong, nonatomic) NSDate* dateSelected;
@property (strong, nonatomic) NSDate* today;
@property (assign, nonatomic)  NSInteger interval;

//view controller ui
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *setting;

@property (nonatomic, strong) NSIndexPath *savedIndexPathForThePressedCell;
@property (nonatomic, strong) id <ViewControllerDelegate> delegate;



//@property (nonatomic, strong) simplePopUpView *simple;
//@property (nonatomic, strong) UINavigationController *navi;
//@property (nonatomic, strong) NSArray *eventsArr;
//@property (assign, nonatomic)  BOOL dragging;
//@property (assign, nonatomic)  NSMutableArray* cellSelected;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *monthlyBarButton;
//@property (weak, nonatomic) IBOutlet UINavigationItem *title;

// events method
-(void)loadEventCalendars;
-(void)saveCustomCalendarIdentifier:(NSString *)identifier;
-(NSArray*)getLocalEvents;
-(NSArray*)getLocalEventCalendars;
-(void)setSelectedCalendarIdentifier:(NSString *)selectedCalendarIdentifier;
-(void)setEventsAccessGranted:(BOOL)eventsAccessGranted;
-(void) requestAccessToEvents;


//ibaction icons
-(IBAction)calendarClick:(id)sender;
-(IBAction)addClick:(id)sender;
-(IBAction)monthlyClick:(id)sender;
-(IBAction)settingClick:(id)sender;

//table view methods
-(void) indicatorMove;
-(void) autoScroll;
-(void)onShowMenu:(UIGestureRecognizer*) sender;

//helper function
-(NSDateFormatter *)dateFormatter;
-(NSString *)hexStringFromColor:(UIColor *)color;
-(NSComparisonResult) isToday: (NSDate*) today dateSelected:(NSDate*) dateSelected;
-(BOOL)checkIsDeviceVersionHigherThanRequiredVersion:(NSString *)requiredVersion;
-(void)setToday;


@end

