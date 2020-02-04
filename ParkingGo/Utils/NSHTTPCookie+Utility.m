//
//  NSHTTPCookie+Utility.m
//  ParkingGoPostMB
//
//  Created by 김학철 on 2019/12/20.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "NSHTTPCookie+Utility.h"

@implementation NSHTTPCookie (Utility)

- (NSString *)wn_javascriptString {
    NSString *string = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@",
                        self.name,
                        self.value,
                        self.domain,
                        self.path ?: @"/"];
    
    if (self.secure) {
        string = [string stringByAppendingString:@";secure=true"];
    }
    
    return string;
}
@end
