//
//  Record+CoreData.m
//  NextNum
//
//  Created by Manted on 17/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "Record+CoreData.h"

@implementation Record (CoreData)

+(Record*)getRecordInManagedObjectContext:(NSManagedObjectContext*)context
{
    Record *r = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Record"];
    request.predicate = nil;
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (!results || error) {
        //handle error here
        NSLog(@"got some error: %@", error.description);
    }else if ([results count]){
        NSLog(@"got some results");
        r = [results firstObject];
    }else{
        NSLog(@"got 0 result");
        r = [NSEntityDescription insertNewObjectForEntityForName:@"Record" inManagedObjectContext:context];
        r.persenalRecord = [NSNumber numberWithInt:5];
    }
    
    return r;
}

@end
