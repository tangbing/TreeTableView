//
//  ContactCell.m
//  Epipe
//
//  Created by EderKaw on 2017/7/20.
//  Copyright © 2017年 Epipe-iOS. All rights reserved.
//

//#define SCREEN_WIDTH       ([UIScreen mainScreen].bounds.size.width)


#import "ContactCell.h"
#import <YYCategories/YYCategories.h>
#import <UIImageView+WebCache.h>

@implementation ContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = 16;
        self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.headImageView];
        
        
        self.nameLab = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLab.textColor = [UIColor colorWithHexString:@"#333333"];
        self.nameLab.font = [UIFont systemFontOfSize:16];
        self.nameLab.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.nameLab];
        
        
    }
    return self;
}

- (void)setStaffModel:(Staffs *)staffModel
{
    _staffModel = staffModel;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:staffModel.profileImg] placeholderImage:[UIImage imageNamed:@"portrait-pho"]];
    self.nameLab.text = staffModel.name;
    
}

- (void)updateSubViewFrame:(NSInteger)nodeLevel {
    self.headImageView.frame = CGRectMake(nodeLevel*15 + 10, (self.height * 0.5 - 32 * 0.5), 32, 32);
    self.nameLab.frame = CGRectMake(self.headImageView.right + 10, 0, SCREEN_WIDTH - CGRectGetMaxX(self.headImageView.frame) - 10, self.height);
}

@end
