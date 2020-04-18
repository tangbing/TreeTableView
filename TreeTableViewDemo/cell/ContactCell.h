//
//  ContactCell.h
//  Epipe
//
//  Created by EderKaw on 2017/7/20.
//  Copyright © 2017年 Epipe-iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactModel.h"
@interface ContactCell : UITableViewCell
@property(nonatomic,strong)UIImageView * headImageView;//员工头像
@property(nonatomic,strong)UILabel * nameLab;//员工名称
@property (nonatomic, strong)Staffs *staffModel;

- (void)updateSubViewFrame:(NSInteger)nodeLevel;
@end
