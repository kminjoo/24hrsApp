//
//  EventManager.h
//  24hrsApp
//
//  Created by Julie Kwon on 7/30/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface EventManager : NSObject

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic) BOOL eventsAccessGranted;
    

@end
