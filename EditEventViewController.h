//
//  EditEventViewController.h
//  
//
//  Created by Julie Kwon on 8/15/16.
//
//

#import <UIKit/UIKit.h>


@protocol EditEventViewControllerDelegate

-(void)eventWasSuccessfullySaved;

@end

@interface EditEventViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *eventTitle;

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@property (nonatomic, strong) NSDate *eventStartDate;
@property (nonatomic, strong) NSDate *eventEndDate;
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
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (strong, nonatomic) IBOutlet UIDatePicker *startPicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *endPicker;
@property (nonatomic, strong) id<EditEventViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDate *start_in;
@property (nonatomic, strong) NSDate *end_in;
@property (nonatomic, strong) NSString *title_in;
@property (nonatomic, strong) NSString *color_in;

@end
