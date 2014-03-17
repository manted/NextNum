//
//  Record+CoreData.h
//  NextNum
//
//  Created by Manted on 17/03/2014.
//  Copyright (c) 2014 Ye Hua. All rights reserved.
//

#import "Record.h"

@interface Record (CoreData)

+(Record*)getRecordInManagedObjectContext:(NSManagedObjectContext*)context;

@end
