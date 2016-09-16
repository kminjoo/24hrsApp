//
//  simplePopUpView.m
//  24hrsApp
//
//  Created by Julie Kwon on 7/26/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import "simplePopUpView.h"
#import "EventManager.h"
#import "AppDelegate.h"

@interface simplePopUpView ()

@property (nonatomic, strong) AppDelegate *appDelegate;

@end


@implementation simplePopUpView
@synthesize startPicker;
@synthesize startsTime;
@synthesize endsTime;
@synthesize color1;
@synthesize color2;
@synthesize color3;
@synthesize color4;
@synthesize color5;
@synthesize color6;
@synthesize color7;
@synthesize color8;
@synthesize color9;
@synthesize color10;
@synthesize color11;
@synthesize color12;
@synthesize defaultColor;
@synthesize endPicker;
@synthesize eventTitle;
@synthesize eventStartDate;
@synthesize eventEndDate;
@synthesize dateDisplay;
@synthesize datePicker;

#pragma mark - helper methods

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

-(NSDate*)convertToLocalTime:(NSDate*) input{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: input];
    return [NSDate dateWithTimeInterval: seconds sinceDate: input];
}

-(void)setToday{
    _rightNowTime = [NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:_rightNowTime];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:_rightNowTime];
    NSTimeInterval intervalToday = destinationGMTOffset - sourceGMTOffset;
    
    _rightNowTime = [[NSDate alloc] initWithTimeInterval:intervalToday sinceDate:_rightNowTime];
}

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

#pragma mark - datepicker methods
-(IBAction)endChanged:(id)sender{
    
    
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h : mm a"];
    
    NSDate *date=[formatter dateFromString:startsTime.text];
    NSString *dateString = [formatter stringFromDate:date];
    NSLog(@"%@",dateString);
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: date];
    date = [NSDate dateWithTimeInterval: seconds sinceDate: date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateComponents *comps =[calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth|
                                                   NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSDateComponents *dateComps =[calendar components:( NSCalendarUnitYear| NSCalendarUnitMonth|
                                                       NSCalendarUnitDay) fromDate:[self convertToLocalTime:datePicker.date]];
    NSInteger year = [dateComps year];
    NSInteger month = [dateComps month];
    NSInteger day = [dateComps day];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
    
    
    date = [calendar dateFromComponents:comps];
    eventStartDate = date;
    [startPicker setDate:date];
    
    _eventDate = eventStartDate;
    
    
    NSDate *end=[formatter dateFromString:endsTime.text];
    NSString *endstring = [formatter stringFromDate:end];
    NSLog(@"%@",endstring);
    NSTimeZone *tz2 = [NSTimeZone localTimeZone];
    NSInteger seconds2 = [tz2 secondsFromGMTForDate: end];
    end = [NSDate dateWithTimeInterval: seconds2 sinceDate: end];
    
    comps =[calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth|
                                 NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:end];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
    end = [calendar dateFromComponents:comps];
    
    [endPicker setDate:end];
    eventEndDate = end;
    
    
    NSDateComponents *startComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[startPicker date]];
    
    
    if ([date laterDate:end] == date) {
        NSString *newendtime = @"";
        newendtime = [NSString stringWithFormat:@"%ld : %ld PM",[startComponent hour] + 4, (long)[startComponent minute]];
        
        [endPicker setDate:[formatter dateFromString:newendtime]];
        NSDate *endtime = [endPicker date];
        endsTime.text = [formatter stringFromDate:endtime];
        [[[UIAlertView alloc] initWithTitle:@"OOPS!"
                                    message:@"Ends time is less than start time! \n Enter a different time."
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Okay", nil] show];
        eventEndDate = endtime;
        return;
    }
    NSLog(@"event title: %@", eventTitle.text);
    if([eventTitle.text  isEqual: @""]){
        [[[UIAlertView alloc] initWithTitle:@"OOPS!"
                                    message:@"Enter the name of the event."
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Okay", nil] show];
        return;
    }
    if(eventTitle.text.length == 0)
        return;
    if(eventStartDate == nil || eventEndDate == nil || _eventDate == nil)
        return;
    
    
    ViewController *view = [[ViewController alloc] init];
    // Create a new event object.
    EKEvent *event = [EKEvent eventWithEventStore:view.eventStore];
    
    event.title = eventTitle.text;
    NSLog(@"%@", event.title);
    
    EKCalendar *selectedCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:view.eventStore];
    
    //instead of getting calendar by identifier
    //get all calendars and check matching in the cycle
    NSArray *allCalendars = [view.eventStore calendarsForEntityType:EKEntityTypeEvent];
    for (EKCalendar *calendar in allCalendars) {
        if ([calendar.title isEqualToString:@"24hrs"]) {
            selectedCalendar = calendar;
            break;
        }
    }
    
    [event setCalendar:selectedCalendar];
    
    event.startDate = self.eventStartDate;
    event.endDate = self.eventEndDate;
    NSString *color = @"";
    color = [self hexStringFromColor:defaultColor.backgroundColor];
    NSLog(@"color: %@",color);
    if([color  isEqual: @"#FF6E58"])
        color = @"0xFF6E58";
    else if([color  isEqual: @"#7C9BFF"])
        color = @"0x7C9BFF";
    else if([color  isEqual: @"#26A86C"])
        color = @"0x26A86C";
    else if([color  isEqual: @"#E5C953"])
        color = @"0xE5C953";
    else if([color  isEqual: @"#E577D6"])
        color = @"0xE577D6";
    else if([color  isEqual: @"#4FD6E5"])
        color = @"0x4FD6E5";
    else if ([color  isEqual: @"#E54254"])
        color = @"0xE54254";
    else if ([color  isEqual: @"#5E00E5"])
        color = @"0x5E00E5";
    else if([color  isEqual: @"#C1D7E5"])
        color = @"0xC1D7E5";
    else if([color  isEqual: @"#C4E572"])
        color = @"0xC4E572";
    else if([color  isEqual: @"#82EA54"])
        color = @"0x82EA54";
    else if([color  isEqual: @"#424242"])
        color = @"0x424242";
    
    event.notes = color;
    
    NSError *error;
    NSPredicate *predicate = [view.eventStore predicateForEventsWithStartDate:event.startDate
                                                                      endDate:event.endDate
                                                                    calendars:nil];
    
    NSArray *events = [view.eventStore eventsMatchingPredicate:predicate];
    
    if(events != nil){
        [[[UIAlertView alloc] initWithTitle:@"OOPS!"
                                    message:@"There already exists an event during this period!"
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Okay", nil] show];
        return;
    }
    
    if ([view.eventStore saveEvent:event span:EKSpanFutureEvents commit:YES error:&error]) {
        // Call the delegate method6 to notify the caller class (the ViewController class) that the event was saved.
        [self.delegate eventWasSuccessfullySaved];
        NSString *key = [[self dateFormatter] stringFromDate:[NSDate date]];
        if(![[NSUserDefaults standardUserDefaults] objectForKey:key]){
            NSUserDefaults *eventsByDates = [NSUserDefaults standardUserDefaults];
            [eventsByDates setObject:event.startDate forKey:key];
        }
        // Pop the current view controller from the navigation stack.
        [self.navigationController popViewControllerAnimated:YES];
        //[view colorCells:event.startDate endTime:event.endDate color: defaultColor.backgroundColor tableView:self.tableView];
    }
    else{
        // An error occurred, so log the error description.
        NSLog(@"ERRROR!! COULDNT SAVE EVENT. %@", [error localizedDescription]);
    }
    
    self.eventTitleString = eventTitle.text;
    
    [view getLocalEvents];
    UIViewController* viewController = [self.storyboard   instantiateViewControllerWithIdentifier:@"viewController"] ;
    [self presentViewController:viewController animated:NO completion:nil];
}

-(void) backclicked:(id)sender{
    UIViewController* viewController = [self.storyboard   instantiateViewControllerWithIdentifier:@"viewController"] ;
    [self presentViewController:viewController animated:NO completion:nil];
}
-(IBAction)editingEnded:(id)sender{
    [sender resignFirstResponder];
}
- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
    
    startsTime.text = [self timeFormatter:[self convertToLocalTime:startPicker.date]];
}

- (void)dismissDatePicker:(id)sender {
    
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 380, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 380, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

- (IBAction)callDP:(id)sender {
    if ([self.view viewWithTag:9]) {
        return;
    }
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 380, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 380, 216);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds] ;
    darkView.alpha = 0;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    
    
    
    startPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    startPicker.tag = 10;
    
    NSDateFormatter *dateFormat;
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mm a"];
    
    
    [startPicker setDate:[dateFormat dateFromString:startsTime.text]];
    [self.view addSubview:startPicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.width, 320, 44)] ;
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] ;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    startPicker.frame = datePickerTargetFrame;
    startPicker.datePickerMode = UIDatePickerModeTime;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
}


- (IBAction)callDP2:(id)sender {
    if ([self.view viewWithTag:9]) {
        return;
    }
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 380, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 380, 216);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds] ;
    darkView.alpha = 0;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    
    endPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 360, 216)];
    endPicker.tag = 10;
    [self.view addSubview:endPicker];
    
    NSDateFormatter *dateFormat;
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mm a"];
    [endPicker setDate:[dateFormat dateFromString:endsTime.text]];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)] ;
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] ;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker2:)];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    endPicker.frame = datePickerTargetFrame;
    endPicker.datePickerMode = UIDatePickerModeTime;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
}

- (void)removeViews2:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
    endsTime.text = [self timeFormatter:[self convertToLocalTime:endPicker.date]];
}


- (void)removeViews3:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
    
    dateDisplay.text = [self dateFormatter:[self convertToLocalTime:datePicker.date]];
}

- (void)dismissDatePicker3:(id)sender {
    
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 380, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 380, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews3:)];
    [UIView commitAnimations];
}

- (IBAction)callDP3:(id)sender {
    if ([self.view viewWithTag:9]) {
        return;
    }
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 380, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 380, 216);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds] ;
    darkView.alpha = 0;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker3:)];
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    
    
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    datePicker.tag = 10;
    [self.view addSubview:datePicker];
    
    NSDateFormatter *dateFormat;
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    [datePicker setDate:[dateFormat dateFromString:dateDisplay.text]];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.width, 320, 44)] ;
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] ;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker3:)];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    datePicker.frame = datePickerTargetFrame;
    datePicker.datePickerMode = UIDatePickerModeDate;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
}

-(NSString*) timeFormatter:(NSDate*) input{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setDateFormat:@"h : mm a"]; //24hr time format
    [outputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateString = [outputFormatter stringFromDate:input];
    NSLog(@"@%@, %@",input, dateString);
    return dateString;
}

-(NSString*) dateFormatter:(NSDate*) input{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"]; //24hr time format
    [outputFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateString = [outputFormatter stringFromDate:input];
    return dateString;
}
- (void)dismissDatePicker2:(id)sender {
    
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 380, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 380, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews2:)];
    [UIView commitAnimations];
}


#pragma mark - color methods
-(void) colorChange:(id)sender{
    defaultColor.backgroundColor = [UIColor colorWithRed:255.0/255 green:110.0/255 blue:88.0/255 alpha:.66f];;
}
-(void) colorChange2:(id)sender{
    defaultColor.backgroundColor = [UIColor colorWithRed:124.0/255 green:155.0/255 blue:255.0/255 alpha:.75f];
}
-(void) colorChange3:(id)sender{
    defaultColor.backgroundColor = [UIColor colorWithRed:38.0/255 green:168.0/255 blue:108.0/255 alpha:.66f];
}
-(void) colorChange4:(id)sender{
    defaultColor.backgroundColor = [UIColor colorWithRed:229.0/255 green:201.0/255 blue:83.0/255 alpha:.75f];
}
-(void) colorChange5:(id)sender{
    defaultColor.backgroundColor = [UIColor colorWithRed:229.0/255 green:119.0/255 blue:214.0/255 alpha:.66f];
}
-(void) colorChange6:(id)sender{
    defaultColor.backgroundColor = [UIColor colorWithRed:79.0/255 green:214.0/255 blue:229.0/255 alpha:.75f];
}
-(void) colorChange7:(id)sender{
    defaultColor.backgroundColor = [UIColor colorWithRed:229.0/255 green:66.0/255 blue:84.0/255 alpha:.66f];
}
-(void) colorChange8:(id)sender{
    defaultColor.backgroundColor = [UIColor colorWithRed:94.0/255 green:0.0 blue:229.0/255 alpha:.66f];
}
-(void) colorChange9:(id)sender{
    defaultColor.backgroundColor = [UIColor colorWithRed:193.0/255 green:215.0/255 blue:229.0/255 alpha:.75f];
}-(void) colorChange10:(id)sender{
    defaultColor.backgroundColor = [UIColor colorWithRed:196.0/255 green:229.0/255 blue:114.0/255 alpha:.66f];
}
-(void) colorChange11:(id)sender{
    defaultColor.backgroundColor =[UIColor colorWithRed:129.9/255 green:233.9/255 blue:83.9/255 alpha:.66f];
}-(void) colorChange12:(id)sender{
    defaultColor.backgroundColor = [UIColor colorWithRed:66.0/255 green:66.0/255 blue:66.0/255 alpha:.66f];
}

#pragma mark - view methods
- (void)viewDidLoad {
    [self setToday];
    eventEndDate = nil;
    eventStartDate = nil;
    [super viewDidLoad];
    startsTime.userInteractionEnabled = YES;
    endsTime.userInteractionEnabled = YES;
    dateDisplay.userInteractionEnabled = YES;
    
    startsTime.text = [self timeFormatter:_rightNowTime];
    NSTimeInterval hourSecond = 60 * 60;
    NSDate *hourLaterDate = [_rightNowTime dateByAddingTimeInterval:hourSecond];
    endsTime.text = [self timeFormatter:hourLaterDate];
    dateDisplay.text = [self dateFormatter:_rightNowTime];
    
    UITapGestureRecognizer *tapGesture = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(callDP:)];
    UITapGestureRecognizer *tapGesture2 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(callDP2:)];
    UITapGestureRecognizer *tapGesture3 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(callDP3:)];
    [startsTime addGestureRecognizer:tapGesture];
    [endsTime addGestureRecognizer:tapGesture2];
    [dateDisplay addGestureRecognizer:tapGesture3];
    UITapGestureRecognizer *colorTap = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange:)];
    UITapGestureRecognizer *colorTap2 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange2:)];
    UITapGestureRecognizer *colorTap3 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange3:)];
    UITapGestureRecognizer *colorTap4 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange4:)];
    UITapGestureRecognizer *colorTap5 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange5:)];
    UITapGestureRecognizer *colorTap6 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange6:)];
    UITapGestureRecognizer *colorTap7 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange7:)];
    UITapGestureRecognizer *colorTap8 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange8:)];
    UITapGestureRecognizer *colorTap9 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange9:)];
    UITapGestureRecognizer *colorTap10 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange10:)];
    UITapGestureRecognizer *colorTap11 = \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange11:)];
    UITapGestureRecognizer *colorTap12= \
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(colorChange12:)];
    [color1 addGestureRecognizer:colorTap];
    [color2 addGestureRecognizer:colorTap2];
    [color3 addGestureRecognizer:colorTap3];
    [color4 addGestureRecognizer:colorTap4];
    [color5 addGestureRecognizer:colorTap5];
    [color6 addGestureRecognizer:colorTap6];
    [color7 addGestureRecognizer:colorTap7];
    [color8 addGestureRecognizer:colorTap8];
    [color9 addGestureRecognizer:colorTap9];
    [color10 addGestureRecognizer:colorTap10];
    [color11 addGestureRecognizer:colorTap11];
    [color12 addGestureRecognizer:colorTap12];
    
    UIImage* image3 = [UIImage imageNamed:@"Checkmark-50.png"];
    CGRect frameimg = CGRectMake(0, 0, 30, 30);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(endChanged:) forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *checkbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.naviItem.rightBarButtonItem = checkbutton;
    
    UIImage* image4 = [UIImage imageNamed:@"Back-48.png"];
    CGRect frameBack = CGRectMake(0, 0, 30, 30);
    UIButton *backButton = [[UIButton alloc] initWithFrame:frameBack];
    [backButton setBackgroundImage:image4 forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backclicked:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *backbuttonItem =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.naviItem.leftBarButtonItem = backbuttonItem;
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
