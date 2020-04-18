//
//  Utils.m
//  TreeTableViewDemo
//
//  Created by Tb on 2020/4/15.
//  Copyright © 2020 Tb. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (id)getJsonDataJsonname:(NSString *)jsonname
{
    NSString *path = [[NSBundle mainBundle] pathForResource:jsonname ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    NSError *error;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!jsonData || error) {
        NSLog(@"JSON解码失败:%@",error.localizedDescription);
        return nil;
    } else {
        return jsonObj;
    }
}
@end
