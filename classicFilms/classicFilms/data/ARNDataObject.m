//
//  ARNDataObject.m
//
//  Created by Stefan Arn on 21.04.15.
//  Copyright (c) 2015 Edge5. All rights reserved.
//

#import "ARNDataObject.h"

@implementation ARNDataObject

- (id)init
{
    return [self initWithAttributesOfManagedObject:nil];
}

// Based on https://gist.github.com/shto/9552503#file-nsmanagedobject-cloner-m
- (id)initWithAttributesOfManagedObject:(NSManagedObject *)source
{
    self = [super init];
    if(self) {
        [self copyAttributesOfManagedObject:source];
    }
    return self;
}

- (id)copyAttributesOfManagedObject:(NSManagedObject *)source
{
    if (source != nil) {
        // copy attributes from NSManagedObject
        [source.entity.attributesByName.allKeys enumerateObjectsUsingBlock:^(NSString *attrKey, NSUInteger idx, BOOL *stop)
         {
             id valueForKey = [[source valueForKey:attrKey] copy];
             [self setValue:valueForKey forKey:attrKey];
         }];
    }
    return self;
}

// we override the default implementation of NSObject (which would raise an exception)
// with this empty one. So we ignore it if initWithAttributesOfManagedObject tries to set a value
// to a key which does not exist in our target data object, instead of crashing the app
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

@end
