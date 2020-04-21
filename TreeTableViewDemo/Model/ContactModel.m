
//
//  ContactModel.m
//  Epipe
//
//  Created by Tb on 2018/6/21.
//  Copyright © 2018年 Epipe-iOS. All rights reserved.
//

#import "ContactModel.h"
@implementation ContactModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"ID": @[@"id"]};
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass
{
    return @{@"offices":@"Offices"};
}

@end

@implementation Offices
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"departID": @[@"id"],
//             @"offices": @""
    };
}
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass
{
    return @{@"staff":@"Staffs",
             @"subOffice": @"Offices"
    };
}
@end


@implementation Staffs

@end

@implementation NodeModel
// 初始化节点数据
- (id)initWithName:(NSString *)name ID:(NSString *)ID staff:(Staffs *)staffModel children:(NSArray *)array {
    self = [super init];
    if (self) {
      self.children = [NSArray arrayWithArray:array];
      self.name = name;
      self.staff = staffModel;
      self.ID = ID;
    }
    return self;
}

+ (id)dataObjectWithName:(NSString *)name ID:(NSString *)ID staff:(Staffs *)staffModel children:(NSArray *)children {
    return [[self alloc] initWithName:name ID:ID staff:staffModel children:children];
}
// 添加子节点
- (void)addChild:(id)child
{
  NSMutableArray *children = [self.children mutableCopy];
  [children insertObject:child atIndex:0];
  self.children = [children copy];
}

@end

