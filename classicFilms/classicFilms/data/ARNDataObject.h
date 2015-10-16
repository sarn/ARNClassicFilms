//
//  ARNDataObject.h
//
//  Created by Stefan Arn on 21.04.15.
//  Copyright (c) 2015 Edge5. All rights reserved.
//

#import <Foundation/Foundation.h>

// ARNDataObjects are exactly the same as a CoreData object
// with the same interface, BUT not attached to CoreData.
// With those objects we can enforce a clean and thread safe
// architecture. NSManagedObjects should only be used inside
// of data controllers or by fetch requests and guarded by performBlocks
// all other parts of the app should use those thread safe ARNDataObjects
// instead of the NSManagedObjects.
@interface ARNDataObject : NSObject

- (id)initWithAttributesOfManagedObject:(NSManagedObject *)source;
- (id)copyAttributesOfManagedObject:(NSManagedObject *)source;
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;

@end
