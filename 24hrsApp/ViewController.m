//
//  ViewController.m
//  24hrsApp
//
//  Created by Julie Kwon on 7/18/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import "ViewController.h"
#import "simplePopUpView.h"
#import "AppDelegate.h"
#import "TableViewController.h"
#import "EditEventViewController.h"
#import "CalendarViewController.h"

@interface ViewController ()
@property (nonatomic, strong) AppDelegate *appDelegate;
@end

@implementation ViewController
@synthesize interval;
@synthesize delegate;
@synthesize tableView;
@synthesize eventStore;

#pragma mark - clickAction
-(IBAction)addClick:(id)sender{
    simplePopUpView* simplePop = [self.storyboard   instantiateViewControllerWithIdentifier:@"simplePopUpView"] ;
    [self presentViewController:simplePop animated:nil completion:nil];
}

-(IBAction)calendarClick:(id)sender{
    CalendarViewController* cal = [self.storyboard   instantiateViewControllerWithIdentifier:@"CalendarViewController"] ;
    [self presentViewController:cal animated:nil completion:nil];
    
}


-(IBAction)settingClick:(id)sender{
    TableViewController *settingPage =[self.storyboard   instantiateViewControllerWithIdentifier:@"SettingView"] ;
    [self presentViewController:settingPage animated:nil completion:nil];
    
}

-(IBAction)DeleteClick:(id)sender{
    TableCell *cell = (TableCell *)[self.tableView cellForRowAtIndexPath:self.savedIndexPathForThePressedCell];
    if(cell == nil)
        return;
    
    ViewController* view = [[ViewController alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
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

#pragma mark - EKEvent related methods
-(void)loadEventCalendars{
    // Reload the table view.
    [self.tableView reloadData];
}

-(void)setEventsAccessGranted:(BOOL)eventsAccessGranted{
    _eventsAccessGranted = eventsAccessGranted;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:eventsAccessGranted] forKey:@"eventkit_events_access_granted"];
}


-(void)setSelectedCalendarIdentifier:(NSString *)selectedCalendarIdentifier{
    _selectedCalendarIdentifier = selectedCalendarIdentifier;
    
    [[NSUserDefaults standardUserDefaults] setObject:selectedCalendarIdentifier forKey:@"eventkit_selected_calendar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSArray *)getLocalEvents{
    NSDate *date =[[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"];
    
    if(date == nil){
        [self setToday];
        [[NSUserDefaults standardUserDefaults] setObject:_today forKey:@"dateSelected"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        date = _today;
        dateDisplay.text= @"Today";
    }
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
    NSLog(@"*********************DONE************************");
    return events;
}

-(void)saveCustomCalendarIdentifier:(NSString *)identifier{
    self.selectedCalendarIdentifier = identifier;
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedCalendarIdentifier forKey:@"eventkit_cal_identifiers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSArray *)getLocalEventCalendars{
    NSArray *allCalendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSMutableArray *localCalendars = [[NSMutableArray alloc] init];
    
    for (int i=0; i<allCalendars.count; i++) {
        EKCalendar *currentCalendar = [allCalendars objectAtIndex:i];
        if (currentCalendar.type == EKCalendarTypeLocal) {
            [localCalendars addObject:currentCalendar];
        }
    }
    return (NSArray *)localCalendars;
}

-(void)requestAccessToEvents{
    if([self checkIsDeviceVersionHigherThanRequiredVersion:@"6.0"]){
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (error == nil) {
                // Store the returned granted value.
                self.eventsAccessGranted = granted;
            }
            else{
                // In case of error, just log its description to the debugger.
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

#pragma mark - init
-(id)init
{
    self = [super init];
    if (self) {
        self.eventStore = [[EKEventStore alloc] init];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        // Check if the access granted value for the events exists in the user defaults dictionary.
        if ([userDefaults valueForKey:@"eventkit_events_access_granted"] != nil) {
            // The value exists, so assign it to the property.
            self.eventsAccessGranted = [[userDefaults valueForKey:@"eventkit_events_access_granted"] intValue];
        }
        else{
            // Set the default value.
            self.eventsAccessGranted = NO;
        }
        // Load the selected calendar identifier.
        EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent
                                                      eventStore:self.eventStore];
        calendar.title = @"24hrs";
        self.selectedCalendarIdentifier = calendar.title;
        for (int i=0; i<self.eventStore.sources.count; i++) {
            EKSource *source = (EKSource *)[self.eventStore.sources objectAtIndex:i];
            EKSourceType currentSourceType = source.sourceType;
            
            if (currentSourceType == EKSourceTypeLocal) {
                calendar.source = source;
                calendar.title = self.selectedCalendarIdentifier;
                break;
            }
        }
        _calendar = calendar;
        
        NSError *error;
        EKEntityType type = EKEntityTypeEvent;
        NSArray *arrCal = [self.eventStore calendarsForEntityType:type];
        BOOL count = NO;
        for(EKCalendar *cal in arrCal){
            if([cal.title  isEqual: @"24hrs"])
                break;
            else
                count = YES;
        }
        if(count == NO)
            [self.eventStore saveCalendar:calendar commit:YES error:&error];
        
        // If no error occurs then turn the editing mode off, store the new calendar identifier and reload the calendars.
        if (error == nil) {
            // Turn off the edit mode.
            [self.tableView setEditing:NO animated:YES];
            
            // Store the calendar identifier.
            [self  saveCustomCalendarIdentifier:@"24hrs"];
            
            // Reload all calendars.
            [self loadEventCalendars];
        }
        else{
            // Display the error description to the debugger.
            NSLog(@"%@", [error localizedDescription]);
        }
        
        if ([userDefaults objectForKey:@"eventkit_selected_calendar"] != nil) {
            self.selectedCalendarIdentifier = @"24hrs";
        }
        else{
            self.selectedCalendarIdentifier = @"";
        }
    }
    return self;
}




- (BOOL)checkIsDeviceVersionHigherThanRequiredVersion:(NSString *)requiredVersion
{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:requiredVersion options:NSNumericSearch] != NSOrderedAscending)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(EditClick:) || action == @selector(DeleteClick:))
        return YES;
    return NO;
}


#pragma mark - show menu button methods

-(void)onShowMenu:(UIGestureRecognizer*) sender{
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
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

-(IBAction)EditClick:(id)sender{
    
    TableCell *cell = (TableCell *)[self.tableView cellForRowAtIndexPath:self.savedIndexPathForThePressedCell];
    
    if(cell == nil)
        return;
    ViewController* view = [[ViewController alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
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


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        return;
    }
    else{
        TableCell *cell = (TableCell *)[self.tableView cellForRowAtIndexPath:self.savedIndexPathForThePressedCell];
        if(cell == nil)
            return;
        ViewController* view = [[ViewController alloc] init];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
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
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[[self dateFormatter] stringFromDate:event.startDate]];
        }
        
        [self.tableView reloadData];
        
    }
}


#pragma mark - Helper functions

- (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
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

-(NSComparisonResult) isToday: (NSDate*) today dateSelected:(NSDate*) dateSelected{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger comps = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    NSDateComponents *date1Components = [calendar components:comps
                                                    fromDate: _today];
    NSDateComponents *date2Components = [calendar components:comps
                                                    fromDate: [[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"]];
    
    NSDate* todayCopy = [calendar dateFromComponents:date1Components];
    NSDate* dateSelectedCopy = [calendar dateFromComponents:date2Components];
    
    return [todayCopy compare:dateSelectedCopy];
}

-(void)setToday{
    _today = [NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:_today];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:_today];
    NSTimeInterval intervalToday = destinationGMTOffset - sourceGMTOffset;
    
    _today = [[NSDate alloc] initWithTimeInterval:intervalToday sinceDate:_today];
}

- (NSString *) changeFormat: (NSString *) input {
    NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc] init];
    [dateFormatter3 setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter3 setDateFormat:@"HH : mm"];
    NSDate *date1 = [dateFormatter3 dateFromString:input];
    
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"h a"];
    return [form stringFromDate:date1];
}


#pragma mark - present view controller methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editEvent"]) {
        
        // Get destination view
        EditEventViewController *editEventView = [segue destinationViewController];
        
        // Get button tag number (or do whatever you need to do here, based on your object
        //NSInteger tagIndex = [(UIButton *)sender tag];
        
        
        TableCell *cell = (TableCell *)[self.tableView cellForRowAtIndexPath:self.savedIndexPathForThePressedCell];
        
        if(cell == nil)
            return;
        ViewController* view = [[ViewController alloc] init];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
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

#pragma mark - design methods
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}


#pragma mark - table view methods

-(void) autoScroll{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    if(_today ==  nil)
        [self setToday];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:_today];
    NSInteger starthour = [components hour];
    NSInteger startminute = [components minute];
    
    NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
    
    if(intervalSaved == 0)
        intervalSaved = 60;
    long startIndex = ((starthour*60 + startminute))/ intervalSaved;
    if(startIndex + 8 < 60*24/intervalSaved){
        startIndex += 8;
    }
    else{
        if(intervalSaved == 30){
            startIndex = 60*24/intervalSaved - 2;
        }
        else
            startIndex = numRow - 1;
    }
    
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:startIndex inSection:0];
    
    [tableView scrollToRowAtIndexPath: startIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

-(void) indicatorMove{
    [self setToday];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateComponents *componentsToday = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:_today];
    NSInteger starthourToday = [componentsToday hour];
    NSInteger startminuteToday = [componentsToday minute];
    NSInteger intervalSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
    
    long startIndexToday = ((starthourToday*60 + startminuteToday))/ intervalSaved;
    NSIndexPath *startIndexPathToday = [NSIndexPath indexPathForRow:startIndexToday inSection:0];
    TableCell* cell = (TableCell *)[tableView cellForRowAtIndexPath:startIndexPathToday];
    cell.timeIndicator.backgroundColor = [UIColor redColor];
    CGRect frame = cell.timeIndicator.frame;
    frame.origin.y = ((double)startminuteToday/ intervalSaved)*35;
    cell.timeIndicator.frame = frame;
    NSLog(@"move~! %fd, %ld",frame.origin.y, (long)startminuteToday);
}

- (NSInteger)tableView: (UITableView *) tableView numberOfRowsInSection:(NSInteger)section{
    return (numRow);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *simpleTableIdentifier = @"TableCell";
    TableCell *cell = (TableCell *)[self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
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
    
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.timeLabel.text =[tableData objectAtIndex:indexPath.row];
    cell.contentsLabel.text = @"";
    cell.preservesSuperviewLayoutMargins=NO;
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
        if(intervalSaved == 30 && startminuteToday >= 30)
            startminuteToday -= 30;
        frame.origin.y = ((double)startminuteToday/ intervalSaved)*35;
        cell.timeIndicator.frame = frame;
    }
    
    
    NSInteger count = 0;
    NSArray *events = [self getLocalEvents];
    for(EKEvent *event in events){
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
        if(indexPath == startIndexPath){
            cell.contentsLabel.textColor = [UIColor whiteColor];
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
        }
        if(indexPath > startIndexPath && indexPath < endIndexPath){
            cell.upperOne.backgroundColor =[colorMap objectForKey:event.notes];
            cell.upperTwo.backgroundColor =[colorMap objectForKey:event.notes];
            cell.lowerOne.backgroundColor =[colorMap objectForKey:event.notes];
            cell.lowerTwo.backgroundColor =[colorMap objectForKey:event.notes];
        }//if
        
    }
    return cell;
}

#pragma mark - UI gesture methods
- (void)didSwipe:(UISwipeGestureRecognizer*)swipe{
    NSDate* date = [[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"];
    NSDate *dateAfter = [date dateByAddingTimeInterval:60*60*24*1];
    NSDate *dateBefore = [date dateByAddingTimeInterval:60*60*24*-1];
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"Swipe Left -- go back one day");
        [[NSUserDefaults standardUserDefaults] setObject:dateAfter forKey:@"dateSelected"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.view setNeedsDisplay];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        
        NSComparisonResult result = [self isToday:_today dateSelected:_dateSelected];
        if(result == NSOrderedSame){
            dateDisplay.text = @"Today";
            [self autoScroll];
        }
        else
            dateDisplay.text = [dateFormatter stringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"]];
        [tableView reloadData];
        
        
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Swipe Right -- one day later");
        [[NSUserDefaults standardUserDefaults] setObject:dateBefore forKey:@"dateSelected"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.view setNeedsDisplay];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        dateDisplay.text = [dateFormatter stringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"]];
        [tableView reloadData];
    }
}

#pragma mark - viewDidload

- (void)viewDidLoad {
    
    
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    [self requestAccessToEvents];
    
    self.tableView.allowsSelection = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    if(self.eventStore == nil){
        self.eventStore = [[EKEventStore alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // Check if the access granted value for the events exists in the user defaults dictionary.
        if ([userDefaults valueForKey:@"eventkit_events_access_granted"] != nil) {
            // The value exists, so assign it to the property.
            self.eventsAccessGranted = [[userDefaults valueForKey:@"eventkit_events_access_granted"] intValue];
        }
        else{
            // Set the default value.
            self.eventsAccessGranted = NO;
        }
        // Load the selected calendar identifier.
        EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent
                                                      eventStore:self.eventStore];
        calendar.title = @"24hrs";
        self.selectedCalendarIdentifier = calendar.title;
        for (int i=0; i<self.eventStore.sources.count; i++) {
            EKSource *source = (EKSource *)[self.eventStore.sources objectAtIndex:i];
            EKSourceType currentSourceType = source.sourceType;
            
            if (currentSourceType == EKSourceTypeLocal) {
                calendar.source = source;
                calendar.title = self.selectedCalendarIdentifier;
                break;
            }
        }
        if(self.eventStore.sources.count == 0){
            [self performSelector:@selector(requestAccessToEvents) withObject:nil afterDelay:0.4];
            EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent
                                                          eventStore:self.eventStore];
            // Set the calendar title.
            calendar.title = @"24hrs";
            
            // Set the calendar source.
            EKSource *theSource = nil;
            for (EKSource *source in self.eventStore.sources) {
                if (source.sourceType == EKSourceTypeLocal) {
                    theSource = source;
                    break;
                }
            }
            
            if (theSource) {
                calendar.source = theSource;
            } else {
                NSLog(@"Error: Local source not available");
                return;
            }
            NSError *error;
            [self.eventStore saveCalendar:calendar commit:YES error:&error];
            
            // If no error occurs then turn the editing mode off, store the new calendar identifier and reload the calendars.
            if (error == nil) {
                // Turn off the edit mode.
                
                // Store the calendar identifier.
                self.selectedCalendarIdentifier = calendar.title;
                [self saveCustomCalendarIdentifier:calendar.title];
                // Reload all calendars.
                [self loadEventCalendars];
            }
            else{
                // Display the error description to the debugger.
                NSLog(@"%@", [error localizedDescription]);
            }
        }
        _calendar = calendar;
        
        
        NSError *error;
        EKEntityType type = EKEntityTypeEvent;
        NSArray *arrCal = [self.eventStore calendarsForEntityType:type];
        if(arrCal.count <= 2)
            [self.eventStore saveCalendar:calendar commit:YES error:&error];
        
        // If no error occurs then turn the editing mode off, store the new calendar identifier and reload the calendars.
        if (error == nil) {
            // Turn off the edit mode.
            [self.tableView setEditing:NO animated:YES];
            
            // Store the calendar identifier.
            [self  saveCustomCalendarIdentifier:@"24hrs"];
            
            // Reload all calendars.
            [self loadEventCalendars];
        }
        else{
            // Display the error description to the debugger.
            NSLog(@"%@", [error localizedDescription]);
        }
        
        self.selectedCalendarIdentifier = @"24hrs";
        
    }
    
    [self setToday];
    NSDate *dateSelected = [[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"];
    if(dateSelected == nil){
        
        [[NSUserDefaults standardUserDefaults] setObject:_today forKey:@"dateSelected"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if([self isToday:_today dateSelected:dateSelected] != NSOrderedSame){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        dateDisplay.text = [dateFormatter stringFromDate:dateSelected];
    }
    if([dateDisplay.text  isEqual: @"Today"]){
        [[NSUserDefaults standardUserDefaults] setObject:_today forKey:@"dateSelected"];
    }
    
    
    [self loadEventCalendars];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    [super viewDidLoad];
    [tableView setUserInteractionEnabled:YES];
    UILongPressGestureRecognizer* gr = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector( onShowMenu: ) ];
    gr.minimumPressDuration = .5;
    [self.tableView addGestureRecognizer: gr];
    
    [self.tableView reloadData];
    
    UIImage *monthlyImage = [UIImage imageNamed:@"Calendar-48.png"];
    CGRect frameBack = CGRectMake(0, 0, 30, 30);
    UIButton *monthlyButton = [[UIButton alloc] initWithFrame:frameBack];
    [monthlyButton setBackgroundImage:monthlyImage forState:UIControlStateNormal];
    [monthlyButton setShowsTouchWhenHighlighted:YES];
    [monthlyButton addTarget:self action:@selector(calendarClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *monthlyBarButton = [[UIBarButtonItem alloc] initWithCustomView:monthlyButton];
    self.naviItem.leftBarButtonItem = monthlyBarButton;
    
    
    UIImage *addImage = [UIImage imageNamed:@"plus.png"];
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.bounds = CGRectMake( 0, 0, 30, 30);
    [addButton setImage:addImage forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.naviItem.rightBarButtonItem = addBarButton;
    
    UIImage *settingImage = [UIImage imageNamed:@"Settings-48.png"];
    CGRect frameimg = CGRectMake(0, 0, 30, 30);
    UIButton *settingButton = [[UIButton alloc] initWithFrame:frameimg];
    [settingButton setBackgroundImage:settingImage forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settingClick:) forControlEvents:UIControlEventTouchUpInside];
    [settingButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    
    NSArray *toolbarButtons = [NSArray arrayWithObjects:settingBarButton, nil];
    [self.toolBar setItems: toolbarButtons animated:NO];
    
    
    self.navigationController.toolbarHidden = NO;
    tableData = [[NSMutableArray alloc]init];
    hour = 0;
    minute = 0;
    starts = 8;
    ends = 31;
    if(delegate == nil)
        NSLog(@"DELEGATE IS NILL");
    interval= [[NSUserDefaults standardUserDefaults] integerForKey:@"interval"];
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
    
    
    
    [self performSelector:@selector(requestAccessToEvents) withObject:nil afterDelay:0.4];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"h:mm aa"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
}


-(void) viewDidAppear:(BOOL)animated{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    if(_today == nil)
        [self setToday];
    
    NSLog(@"today: %@ dateselected: %@",_today, [[NSUserDefaults standardUserDefaults] objectForKey:@"dateSelected"]);
    
    
    NSComparisonResult result = [self isToday:_today dateSelected:_dateSelected];
    
    NSUserDefaults *selectExpand = [NSUserDefaults standardUserDefaults];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isExpanded"] == YES &&
       result != NSOrderedSame){
        [selectExpand setBool:NO forKey:@"isExpanded"];
        
        NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"indexPathExpand"] inSection:0];
        [tableView scrollToRowAtIndexPath: startIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    }
    else if([[NSUserDefaults standardUserDefaults] boolForKey:@"isExpanded"] == NO &&
            result != NSOrderedSame)
        return;
    else{
        [self autoScroll];
    }
    
    
    
}

@end
