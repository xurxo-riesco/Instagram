//
//  Comment.m
//  Instagram
//
//  Created by Xurxo Riesco on 7/6/20.
//  Copyright © 2020 Xurxo Riesco. All rights reserved.
//

#import "Comment.h"

@implementation Comment
@dynamic text;
@dynamic author;
+ (nonnull NSString *)parseClassName {
    return @"Comment";
}
@end
