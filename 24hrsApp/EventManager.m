//
//  EventManager.m
//  24hrsApp
//
//  Created by Julie Kwon on 7/30/16.
//  Copyright (c) 2016 webpdp. All rights reserved.
//

#import "EventManager.h"

@implementation EventManager

- (id) init{
    self = [super init];
    if(self){
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
    }
    return self;
}

-(void)setEventsAccessGranted:(BOOL)eventsAccessGranted{
    _eventsAccessGranted = eventsAccessGranted;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:eventsAccessGranted] forKey:@"eventkit_events_access_granted"];
}
/*
-(void) setStartsTime:(NSDate *)input{
    startsTime = input;
}

-(void) setEndsTime:(NSDate *)input{
    endsTime = input;
}
-(void) setTitle:(NSString *)input{
    title = input;
}
-(void)setEventColor:(id)input{
    eventColor = input;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:startsTime forKey:@"startsTime"];
    [encoder encodeObject:endsTime forKey:@"endsTime"];
    [encoder encodeObject:eventColor forKey:@"eventColor"];
    [encoder encodeObject:title forKey:@"title"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        startsTime = [decoder decodeObjectForKey:@"startsTime"];
        endsTime = [decoder decodeObjectForKey:@"endsTime"];
        title = [decoder decodeObjectForKey:@"eventColor"];
        eventColor = [decoder decodeObjectForKey:@"title"];
    }
    return self;
}

- (void)saveCustomObject:(EventManager *)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}

- (EventManager *)loadCustomObjectWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    EventManager *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}*/


@end
