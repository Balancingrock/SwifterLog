//
//  asl-bridge.m
//  SwiftFire
//
//  Created by Marinus van der Lugt on 03/12/14.
//  Copyright (c) 2014 Marinus van der Lugt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <asl.h>
#import "asl-bridge.h"

int asl_bridge_log_message(int level, NSString *message) {
    return asl_log_message(level, "%s", [message cStringUsingEncoding:NSUTF8StringEncoding]);
}