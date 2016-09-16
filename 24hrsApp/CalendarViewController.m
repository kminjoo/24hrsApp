//
//  CalendarViewController.m
//  24hrsApp
//
//  Created by Julie Kwon on 8/17/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import "CalendarViewController.h"
#import "simplePopUpView.h"
#import "TableCell.h"
#import "EditEventViewController.h"

@interface CalendarViewController (){
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
    NSDate *_dateSelected;
    
    NSMutableArray *headData;
    NSMutableArray *leftTableData;
    NSMutableArray *rightTableData;
}

@end

@implementation CalendarViewController

#pragma - mark click methods
-(void)addClick:(id)sender{
    NSLog(@"ADD CLICK");
    
    simplePopUpView* simplePop = [self.storyboard   instantiateViewControllerWithIdentifier:@"simplePopUpView"] ;
    [self presentViewController:simplePop animated:nil completion:nil];
}
-(void) backclicked{
    UIViewController* viewController = [self.storyboard   instantiateViewControllerWithIdentifier:@"viewController"] ;
    NSUserDefaults *dateData = [NSUserDefaults standardUserDefaults];
    [dateData setObject:_today forKey:@"dateSelected"];
    [self presentViewController:viewController animated:NO completion:nil];
}

-(IBAction)DeleteClick:(id)sender{
    TableCell *cell = (TableCell *)[self.weeklyTableView cellForRowAtIndexPath:self.savedIndexPathForThePressedCell];
    NSLog(@"%@",cell.timeLabel.text);
    if(cell == nil)
        return;
    
    ViewController* view = [[ViewController alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSLog(@"%@",cell.timeLabel.text);
    NSDate *intervalStartTime = [dateFormat dateFromString:cell.timeLabel.text];
    
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger startSec = [tz secondsFromGMTForDate: intervalStartTime];
    intervalStartTime = [NSDate dateWithTimeInterval: startSec sinceDate: intervalStartTime];
    
    NSDateComponents *comps =[calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth|
                                                   NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:intervalStartTime];
    
    NSDateComponents *todayComps =[calendar components:( NSCalendarUnitYear| NSCalendarUnitMonth|
                                                        NSCalendarUnitDay) fromDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"]];
    NSInteger year = [todayComps year];
    NSInteger month = [todayComps month];
    NSInteger day = [todayComps day];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
    intervalStartTime = [calendar dateFromComponents:comps];
    NSDate *intervalEndTime= [NSDate dateWithTimeInterval:(intervalSaved*60) sinceDate:intervalStartTime];
    NSPredicate *predicate = [view.eventStore predicateForEventsWithStartDate:intervalStartTime
                                                                      endDate:intervalEndTime
                                                                    calendars:nil];
    
    NSArray *events = [view.eventStore eventsMatchingPredicate:predicate];
    if(events == nil)
        return;
    
    
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:@"ALERT"
                               message:@"You sure you want to delete this event?"
                              delegate:self
                     cancelButtonTitle:@"No"
                     otherButtonTitles:@"Yes", nil];
    [alertView show];
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editEvent"]) {
        
        // Get destination view
        EditEventViewController *editEventView = [segue destinationViewController];
        
        // Get button tag number (or do whatever you need to do here, based on your object
        
        
        TableCell *cell = (TableCell *)[self.weeklyTableView cellForRowAtIndexPath:self.savedIndexPathForThePressedCell];
        
        if(cell == nil)
            return;
        ViewController* view = [[ViewController alloc] init];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        NSLog(@"%@",cell.timeLabel.text);
        NSDate *intervalStartTime = [dateFormat dateFromString:cell.timeLabel.text];
        NSTimeZone *tz = [NSTimeZone localTimeZone];
        NSInteger startSec = [tz secondsFromGMTForDate: intervalStartTime];
        intervalStartTime = [NSDate dateWithTimeInterval: startSec sinceDate: intervalStartTime];
        
        NSDateComponents *comps =[calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth|
                                                       NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:intervalStartTime];
        
        
        NSDateComponents *todayComps =[calendar components:( NSCalendarUnitYear| NSCalendarUnitMonth|
                                                            NSCalendarUnitDay) fromDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"]];
        NSInteger year = [todayComps year];
        NSInteger month = [todayComps month];
        NSInteger day = [todayComps day];
        [comps setYear:year];
        [comps setMonth:month];
        [comps setDay:day];
        intervalStartTime = [calendar dateFromComponents:comps];
        NSDate *intervalEndTime= [NSDate dateWithTimeInterval:(intervalSaved*60) sinceDate:intervalStartTime];
        
        NSPredicate *predicate = [view.eventStore predicateForEventsWithStartDate:intervalStartTime
                                                                          endDate:intervalEndTime
                                                                        calendars:nil];
        
        NSArray *events = [view.eventStore eventsMatchingPredicate:predicate];
        if(events == nil)
            return;
        for(EKEvent* event in events){
            editEventView.title_in = event.title;
            editEventView.start_in = event.startDate;
            editEventView.end_in = event.endDate;
            editEventView.color_in = event.notes;
        }
        
    }
}


-(IBAction)EditClick:(id)sender{
    
    TableCell *cell = (TableCell *)[self.weeklyTableView cellForRowAtIndexPath:self.savedIndexPathForThePressedCell];
    
    if(cell == nil)
        return;
    ViewController* view = [[ViewController alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSLog(@"%@",cell.timeLabel.text);
    NSDate *intervalStartTime = [dateFormat dateFromString:cell.timeLabel.text];
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger startSec = [tz secondsFromGMTForDate: intervalStartTime];
    intervalStartTime = [NSDate dateWithTimeInterval: startSec sinceDate: intervalStartTime];
    
    NSDateComponents *comps =[calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth|
                                                   NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:intervalStartTime];
    
    NSDateComponents *todayComps =[calendar components:( NSCalendarUnitYear| NSCalendarUnitMonth|
                                                        NSCalendarUnitDay) fromDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"]];
    NSInteger year = [todayComps year];
    NSInteger month = [todayComps month];
    NSInteger day = [todayComps day];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
    intervalStartTime = [calendar dateFromComponents:comps];
    NSDate *intervalEndTime= [NSDate dateWithTimeInterval:(intervalSaved*60) sinceDate:intervalStartTime];
    
    NSPredicate *predicate = [view.eventStore predicateForEventsWithStartDate:intervalStartTime
                                                                      endDate:intervalEndTime
                                                                    calendars:nil];
    
    NSArray *events = [view.eventStore eventsMatchingPredicate:predicate];
    if(events == nil)
        return;
    
    [self performSegueWithIdentifier:@"editEvent" sender:sender];
    
}


#pragma - mark on show methods

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(EditClick:) || action == @selector(DeleteClick:))
        return YES;
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        return;
    }
    else{
        TableCell *cell = (TableCell *)[self.weeklyTableView cellForRowAtIndexPath:self.savedIndexPathForThePressedCell];
        NSLog(@"%@",cell.timeLabel.text);
        if(cell == nil)
            return;
        ViewController* view = [[ViewController alloc] init];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        NSLog(@"%@",cell.timeLabel.text);
        NSDate *intervalStartTime = [dateFormat dateFromString:cell.timeLabel.text];
        NSTimeZone *tz = [NSTimeZone localTimeZone];
        NSInteger startSec = [tz secondsFromGMTForDate: intervalStartTime];
        intervalStartTime = [NSDate dateWithTimeInterval: startSec sinceDate: intervalStartTime];
        
        NSDateComponents *comps =[calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth|
                                                       NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:intervalStartTime];
        NSDateComponents *todayComps =[calendar components:( NSCalendarUnitYear| NSCalendarUnitMonth|
                                                            NSCalendarUnitDay) fromDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"]];
        NSInteger year = [todayComps year];
        NSInteger month = [todayComps month];
        NSInteger day = [todayComps day];
        [comps setYear:year];
        [comps setMonth:month];
        [comps setDay:day];
        intervalStartTime = [calendar dateFromComponents:comps];
        NSDate *intervalEndTime= [NSDate dateWithTimeInterval:(intervalSaved*60) sinceDate:intervalStartTime];
        
        NSPredicate *predicate = [view.eventStore predicateForEventsWithStartDate:intervalStartTime
                                                                          endDate:intervalEndTime
                                                                        calendars:nil];
        
        NSArray *events = [view.eventStore eventsMatchingPredicate:predicate];
        if(events == nil)
            return;
        NSError *error;
        for(EKEvent* event in events){
            [view.eventStore removeEvent:event span: EKSpanFutureEvents error:&error];
        }
        _eventsArr = [self getEvents:_dateSelected];
        [_weeklyTableView reloadData];
        
    }
    }



-(void)onShowMenu:(UIGestureRecognizer*) sender{
    CGPoint location = [sender locationInView:self.weeklyTableView];
    NSIndexPath *indexPath = [self.weeklyTableView indexPathForRowAtPoint:location];
    
    if(indexPath == nil) return ;
    
    UIMenuItem* delete = [[UIMenuItem alloc] initWithTitle: @"delete" action:@selector( DeleteClick:)];
    UIMenuItem* edit = [[UIMenuItem alloc] initWithTitle: @"edit" action:@selector( EditClick: )];
    UIMenuController* mc = [UIMenuController sharedMenuController];
    
    NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
    [mc setMenuItems:[NSArray arrayWithObjects: delete, edit, nil]];
    [mc setTargetRect: CGRectMake(location.x, location.y, 0.0f, 0.0f) inView:[sender view]];
    [mc setMenuVisible: YES animated: YES];
    self.savedIndexPathForThePressedCell = indexPath;
}

#pragma - mark view methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableData];
    
    _vc = [[ViewController alloc] init];
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    
    [_weeklyTableView setUserInteractionEnabled:YES];
    UILongPressGestureRecognizer* gr = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector( onShowMenu: ) ];
    gr.minimumPressDuration = .5;
    [_weeklyTableView addGestureRecognizer: gr];
    [self.weeklyTableView reloadData];
    
    // Create a min and max date for limit the calendar, optional
    [self createMinAndMaxDate];
    
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];
    self.weeklyTableView.allowsSelection = NO;
    UIImage* image4 = [UIImage imageNamed:@"Back-48.png"];
    CGRect frameBack = CGRectMake(0, 0, 30, 30);
    UIButton *backButton = [[UIButton alloc] initWithFrame:frameBack];
    [backButton setBackgroundImage:image4 forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backclicked) forControlEvents:UIControlEventTouchUpInside];
    [backButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *backbuttonItem =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.naviItem.leftBarButtonItem = backbuttonItem;
    
    UIImage *addImage = [UIImage imageNamed:@"plus.png"];
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.bounds = CGRectMake( 0, 0, 30, 30);
    [addButton setImage:addImage forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.naviItem.rightBarButtonItem = addBarButton;
    [self setToday];
    if(_dateSelected == nil){
        
        _dateSelected = _today;
    }
    _eventsArr = [self getEvents:_dateSelected];
    [self.tableView reloadData];
    _tableView.delegate= self;
    _tableView.dataSource=self;
    [self.weeklyTableView reloadData];
    _weeklyTableView.delegate= self;
    _weeklyTableView.dataSource=self;
}

#pragma - mark Helper methods
-(void)setToday{
    _today = [NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:_today];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:_today];
    NSTimeInterval intervalToday = destinationGMTOffset - sourceGMTOffset;
    
    _today = [[NSDate alloc] initWithTimeInterval:intervalToday sinceDate:_today];
}

- (NSDate*) convertTimezone: (NSDate*)input{
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:input];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:input];
    NSTimeInterval intervalToday = destinationGMTOffset - sourceGMTOffset;
    
    input = [[NSDate alloc] initWithTimeInterval:intervalToday sinceDate:input];
    return input;
}
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}
- (NSString *) changeFormat: (NSString *) input {
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc] init];
    [dateFormatter3 setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter3 setDateFormat:@"HH : mm"];
    NSDate *date1 = [dateFormatter3 dateFromString:input];
    NSLog(@"date1 : %@", date1);
    
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"h:mm a"];
    NSLog(@"Current Date: %@", [form stringFromDate:date1]);
    return [form stringFromDate:date1];
}
- (NSDate*) stringToDate :(NSString*) input{
    
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mm a"];
    NSDate *date = [dateFormat dateFromString:input];
    return date;
}


#pragma mark - JT Calendar methods - Buttons callback

- (IBAction)didGoTodayTouch
{
    [_calendarManager setDate:_today];
    _eventsArr = [self getEvents:_today];
    _dateSelected = _today;
    [_tableView reloadData];
    [_weeklyTableView reloadData];
    [_calendarManager reload];
    
}

-(IBAction)expandTouch{
    ViewController *viewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"viewController"];
    NSUserDefaults *dateData = [NSUserDefaults standardUserDefaults];
    [dateData setObject:_dateSelected forKey:@"dateSelected"];
    [self presentViewController:viewController animated:nil completion:nil];
    
}


- (BOOL)haveEventForDay:(NSDate *)date
{
    
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:key]){
        return YES;
    }
    
    return NO;
    
}

- (IBAction)didChangeModeTouch
{
    _calendarManager.settings.weekModeEnabled = !_calendarManager.settings.weekModeEnabled;
    [_calendarManager reload];
    
    CGFloat newHeight = 300;
    if(_calendarManager.settings.weekModeEnabled){
        newHeight = 85.;
        _tableView.hidden = YES;
        _weeklyTableView.hidden = NO;
        CGRect weeklyFrame = _weeklyTableView.frame;
        weeklyFrame.origin.y = 194;
        
        _weeklyTableView.frame = weeklyFrame;
        [self autoScroll];
    }else{
        _weeklyTableView.hidden = YES;
        _tableView.hidden = NO;
    }
    self.calendarContentViewHeight.constant = newHeight;
    [self.view layoutIfNeeded];
    
}





#pragma mark - JT Calendar - CalendarManager delegate

// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    NSLog(@"%@",_today);
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor blueColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([self haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    NSUserDefaults *dateData = [NSUserDefaults standardUserDefaults];
    [dateData setObject:_dateSelected forKey:@"dateSelected"];
    NSLog(@"DATE SELECTED *********************************%@",_dateSelected);
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    _eventsArr = [self getEvents:_dateSelected];
    [_tableView reloadData];
    [_weeklyTableView reloadData];
    // Don't change page in week mode because block the selection of days in first and last weeks of the month
    if(_calendarManager.settings.weekModeEnabled){
        [self autoScroll];
        return;
        
    }
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
}

#pragma mark - CalendarManager delegate - Page mangement

// Used to limit the date for the calendar, optional
- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date
{
    return [_calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Next page loaded");
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Previous page loaded");
}

#pragma mark - Fake data

- (void)createMinAndMaxDate
{
    _todayDate = [NSDate date];
    _todayDate = [self convertTimezone:_todayDate];
    // Min date will be 2 month before today
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-2];
    
    // Max date will be 2 month after today
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:2];
}




#pragma mark - table view methods
-(void) autoScroll{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSLog(@"today: %@",_today);
    if(_today ==  nil)
        [self setToday];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:_today];
    NSInteger starthour = [components hour];
    NSInteger startminute = [components minute];
    
    NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
    
    long startIndex = ((starthour*60 + startminute))/ intervalSaved;
    if(startIndex + 8 < 60*24/intervalSaved){
        startIndex += 8;
    }
    else{
        if(intervalSaved == 30){
            startIndex = 60*24/intervalSaved - 2;
        }
        else
            startIndex = 60*24/intervalSaved - 1;
    }
    
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:startIndex inSection:0];
    
    [_weeklyTableView scrollToRowAtIndexPath: startIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath{
    
    TableCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil)
        return;
    else{
        NSLog(@"%@",cell.timeLabel.text);
        NSUserDefaults *selectExpand = [NSUserDefaults standardUserDefaults];
        [selectExpand setBool:YES forKey:@"isExpanded"];
        
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.timeZone = [NSTimeZone localTimeZone];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[self stringToDate:cell.timeLabel.text]];
        NSInteger starthour = [components hour];
        NSInteger startminute = [components minute];
        
        NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
        
        long startIndex = ((starthour*60 + startminute))/ intervalSaved;
        if(startIndex + 8 < 60*24/intervalSaved){
            startIndex += 8;
        }
        else{
            startIndex = 60*24/intervalSaved - 1 ;
        }
        [selectExpand setObject:_dateSelected forKey:@"dateSelected"];
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"]);
        NSLog(@"%@",_dateSelected);
        [selectExpand setInteger:startIndex forKey:@"indexPathExpand"];
        ViewController *viewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"viewController"];
        [self presentViewController:viewController animated:nil completion:nil];
    }
}

-(void) initTableData{
    tableData = [[NSMutableArray alloc]init];
    NSInteger hour = 0;
    NSInteger minute = 0;
    NSInteger starts = 8;
    NSInteger ends = 31;
    NSInteger interval= [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
    NSLog(@"Interval: %ld", (long)interval);
    if(!interval)
        interval = 30;
    
    numRow = ABS(((starts)*60 - (ends)*60))/(interval) + 1;
    if(interval == 30)
        numRow+=1;
    for(int i =0; i < numRow; ++i){
        if(hour >= 24){
            hour -=24;
        }
        [tableData addObject: [NSString stringWithFormat:@"%ld:%02ld",(long)hour, (long)minute]];
        minute += interval;
        if(minute >= 60){
            minute-=60;
            hour++;
        }
    }
    
    NSInteger intervalSave = (interval);
    [[NSUserDefaults standardUserDefaults] setInteger:intervalSave forKey:(@"interval")];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSInteger)tableView: (UITableView *) tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == _tableView)
        return _numEvent * 2;
    else if(tableView == _weeklyTableView)
        return numRow;
    return numRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSArray * colorKeys = [NSArray arrayWithObjects:@"0xFF6E58", @"0x7C9BFF",
                           @"0x26A86C", @"0xE5C953", @"0xE577D6", @"0x4FD6E5",
                           @"0xE54254",@"0x5E00E5",@"0xC1D7E5",@"0xC4E572",
                           @"0x82EA54",@"0x424242", nil];
    NSArray * colorValues = [NSArray arrayWithObjects:
                             [UIColor colorWithRed:255.0/255 green:110.0/255 blue:88.0/255 alpha:.66f],
                             [UIColor colorWithRed:124.0/255 green:155.0/255 blue:255.0/255 alpha:.75f],
                             [UIColor colorWithRed:38.0/255 green:168.0/255 blue:108.0/255 alpha:.66f],
                             [UIColor colorWithRed:229.0/255 green:201.0/255 blue:83.0/255 alpha:.75f],
                             [UIColor colorWithRed:229.0/255 green:119.0/255 blue:214.0/255 alpha:.66f],
                             [UIColor colorWithRed:79.0/255 green:214.0/255 blue:229.0/255 alpha:.75f],
                             [UIColor colorWithRed:229.0/255 green:66.0/255 blue:84.0/255 alpha:.66f],
                             [UIColor colorWithRed:94.0/255 green:0.0 blue:229.0/255 alpha:.66f],
                             [UIColor colorWithRed:193.0/255 green:215.0/255 blue:229.0/255 alpha:.75f],
                             [UIColor colorWithRed:196.0/255 green:229.0/255 blue:114.0/255 alpha:.66f],
                             [UIColor colorWithRed:0.51 green:0.92 blue:0.33 alpha:.66f],
                             [UIColor colorWithRed:66.0/255 green:66.0/255 blue:66.0/255 alpha:.66f],
                             nil];
    NSDictionary * colorMap = [NSDictionary dictionaryWithObjects:colorValues forKeys:colorKeys];
    
    if(tableView == _tableView){
        static NSString *simpleTableIdentifier = @"TableCell";
        TableCell *cell = (TableCell *)[_tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            cell.contentsLabel.text = @"";
            cell.timeLabel.text = @"";
            
        }
        if(indexPath.row >= _numEvent)
            return cell;
        
        EKEvent *event = [_eventsArr objectAtIndex: indexPath.row];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:event.startDate];
        NSInteger starthour = [components hour];
        NSInteger startminute = [components minute];
        
        NSDateComponents *components2 = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:event.endDate];
        NSInteger endhour = [components2 hour];
        NSInteger endminute = [components2 minute];
        
        cell.contentsLabel.text = event.title;
        cell.timeLabel.text = [self changeFormat:[NSString stringWithFormat: @"%ld : %ld", (long)starthour, (long)startminute]];
        cell.timeLabel.font=[cell.timeLabel.font fontWithSize:10];
        cell.endTimeLabel.text = [self changeFormat:[NSString stringWithFormat: @"%ld : %ld", (long)endhour, (long)endminute]];
        cell.endTimeLabel.font=[cell.endTimeLabel.font fontWithSize:10];
        
        
        CGRect frame = cell.upperOne.frame;
        CGRect frame2 = cell.upperTwo.frame;
        CGRect frame3 = cell.lowerOne.frame;
        CGRect frame4 = cell.lowerTwo.frame;
        frame.size.width = self.view.bounds.size.width;
        frame.origin.x = 60;
        frame2.size.width = self.view.bounds.size.width;
        frame2.origin.x = 60;
        frame3.size.width = self.view.bounds.size.width;
        frame3.origin.x = 60;
        frame4.size.width = self.view.bounds.size.width;
        frame4.origin.x = 60;
        cell.upperOne.frame = frame;
        cell.upperTwo.frame = frame2;
        cell.lowerOne.frame = frame3;
        cell.lowerTwo.frame = frame4;
        
        cell.upperOne.backgroundColor = [colorMap objectForKey:event.notes];
        cell.upperTwo.backgroundColor = [colorMap objectForKey:event.notes];
        cell.lowerOne.backgroundColor = [colorMap objectForKey:event.notes];
        cell.lowerTwo.backgroundColor = [colorMap objectForKey:event.notes];
        return cell;
    }
    else{
        static NSString *simpleTableIdentifier = @"TableCell";
        TableCell *cell = (TableCell *)[self.weeklyTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.timeLabel.text =[tableData objectAtIndex:indexPath.row];
        cell.contentsLabel.text = @"";
        
        
        NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
        
        if(_today ==  nil)
            [self setToday];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSDateComponents *componentsToday = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:_today];
        NSInteger starthourToday = [componentsToday hour];
        NSInteger startminuteToday = [componentsToday minute];
        
        
        long startIndexToday = ((starthourToday*60 + startminuteToday))/ intervalSaved;
        NSIndexPath *startIndexPathToday = [NSIndexPath indexPathForRow:startIndexToday inSection:0];
        if(indexPath == startIndexPathToday){
            cell.timeIndicator.backgroundColor = [UIColor redColor];
            CGRect frame = cell.timeIndicator.frame;
            frame.size.width  = self.view.bounds.size.width;
            if(intervalSaved == 30 && startminuteToday >= 30)
                startminuteToday -= 30;
            frame.origin.y = ((double)startminuteToday/ intervalSaved)*35;
            cell.timeIndicator.frame = frame;
        }
        
        
        NSInteger count = 0;
        NSArray *events = _eventsArr;
        for(EKEvent *event in events){
            NSLog(@"cOUNT: %ld",(long)count);
            count++;
            
            NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:event.startDate];
            NSInteger starthour = [components hour];
            NSInteger startminute = [components minute];
            
            NSDateComponents *components2 = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:event.endDate];
            NSInteger endhour = [components2 hour];
            NSInteger endminute = [components2 minute];
            
            
            
            long startIndex = ((starthour*60 + startminute))/ intervalSaved;
            long endIndex = (((endhour * 60 + endminute))/ intervalSaved);
            long duration = ((endhour*60 + endminute) - (starthour * 60 + startminute));
            if(duration == 30)
                endIndex += 1;
            if(intervalSaved == 30)
                endIndex -= 1;
            NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:startIndex inSection:0];
            NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:endIndex inSection:0];
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:startIndex+1 inSection:0];
            
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"HH:mm"];
            NSLog(@"%@",cell.timeLabel.text);
            NSDate *intervalStartTime = [dateFormat dateFromString:cell.timeLabel.text];
            
            NSTimeZone *tz = [NSTimeZone localTimeZone];
            NSInteger startSec = [tz secondsFromGMTForDate: intervalStartTime];
            intervalStartTime = [NSDate dateWithTimeInterval: startSec sinceDate: intervalStartTime];
            
            NSDateComponents *comps =[calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth|
                                                           NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:intervalStartTime];
            
            
            NSDateComponents *todayComps =[calendar components:( NSCalendarUnitYear| NSCalendarUnitMonth|
                                                                NSCalendarUnitDay) fromDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"]];
            NSInteger year = [todayComps year];
            NSInteger month = [todayComps month];
            NSInteger day = [todayComps day];
            [comps setYear:year];
            [comps setMonth:month];
            [comps setDay:day];
            intervalStartTime = [calendar dateFromComponents:comps];
            
            
            CGRect frame2 = cell.upperOne.frame;
            frame2.size.width = self.view.bounds.size.width;
            if(indexPath == startIndexPath){
                cell.contentsLabel.textColor = [UIColor whiteColor];
                [cell.contentsLabel setFont:[UIFont boldSystemFontOfSize:14]];
                if(intervalSaved == 30 && startminute >= 30){
                    frame2.origin.y =((double)(startminute-30)/ intervalSaved)*35;
                }
                else
                    frame2.origin.y =((double)startminute/ intervalSaved)*35;
                if(duration >= intervalSaved)
                    frame2.size.height = 36 - frame2.origin.y;
                else
                    frame2.size.height = ((double)duration / intervalSaved * 36);
                cell.upperOne.backgroundColor =[colorMap objectForKey:event.notes];
                if(startminute < 45){
                    CGRect contentFrame = cell.contentsLabel.frame;
                    contentFrame.origin.y = frame2.origin.y +1;
                    cell.contentsLabel.frame = contentFrame;
                    cell.contentsLabel.text = event.title;
                }
            }
            else if(indexPath == endIndexPath){
                
                frame2.origin.y = 0;
                if(intervalSaved == 60){
                    frame2.size.height = ((double)endminute/ intervalSaved)*35;
                }
                else{
                    if(endminute > 30)
                        frame2.size.height = ((double)(endminute-30)/intervalSaved*35);
                    else if(endminute == 0)
                        frame2.size.height = 36;
                    else
                        frame2.size.height = ((double)endminute/intervalSaved)*35;
                }
                cell.upperOne.backgroundColor = [colorMap objectForKey:event.notes];
            }
            cell.upperOne.frame = frame2;
            if(startminute >= 45 && indexPath == nextIndexPath){
                cell.contentsLabel.textColor = [UIColor whiteColor];
                cell.contentsLabel.text = event.title;
                [cell.contentsLabel setFont:[UIFont boldSystemFontOfSize:14]];
            }
            if(indexPath > startIndexPath && indexPath < endIndexPath){
                CGRect frame = cell.upperOne.frame;
                CGRect frame2 = cell.upperTwo.frame;
                CGRect frame3 = cell.lowerOne.frame;
                CGRect frame4 = cell.lowerTwo.frame;
                frame.size.width = self.view.bounds.size.width;
                frame2.size.width = self.view.bounds.size.width;
                frame3.size.width = self.view.bounds.size.width;
                frame4.size.width = self.view.bounds.size.width;
                cell.upperOne.frame = frame;
                cell.upperTwo.frame = frame2;
                cell.lowerOne.frame = frame3;
                cell.lowerTwo.frame = frame4;
                cell.upperOne.backgroundColor =[colorMap objectForKey:event.notes];
                cell.upperTwo.backgroundColor =[colorMap objectForKey:event.notes];
                cell.lowerOne.backgroundColor =[colorMap objectForKey:event.notes];
                cell.lowerTwo.backgroundColor =[colorMap objectForKey:event.notes];
                
            }//if
            
        }
        return cell;
        
    }
}
#pragma mark - EKevent methods

-(NSArray *)getEvents: (NSDate* )date{
    ViewController* view = [[ViewController alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    
    NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:date];
    NSDate *startTime = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
    NSDate *endTime = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:tomorrow options:0];
    
    
    NSPredicate *predicate = [view.eventStore predicateForEventsWithStartDate:startTime
                                                                      endDate:endTime
                                                                    calendars:nil];
    
    NSArray *events = [view.eventStore eventsMatchingPredicate:predicate];
    NSLog(@"***********************EVENT LIST*******************");
    for(EKEvent *event in events){
        NSLog(@"title: %@", event.title);
        NSLog(@"starttime: %@", event.startDate);
        NSLog(@"endtime: %@", event.endDate);
        NSLog(@"notes: %@", event.notes);
    }
    _numEvent = events.count;
    NSLog(@"*********************DONE************************");
    return events;
}



@end
