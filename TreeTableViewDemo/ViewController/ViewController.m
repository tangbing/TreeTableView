//
//  ViewController.m
//  TreeTableViewDemo
//
//  Created by Tb on 2020/4/15.
//  Copyright © 2020 Tb. All rights reserved.
//



#import "ViewController.h"
#import <YYCategories/YYCategories.h>
#import "NSObject+YYModel.h"
#import "ContactCell.h"
#import "ContactModel.h"
#import "RATreeView.h"
#import "Utils.h"


@interface ViewController ()<RATreeViewDataSource,RATreeViewDelegate>
@property(nonatomic,strong)NSArray * departmentArray;
@property(nonatomic,strong)NSMutableArray <ContactModel*>* contactDataArray;
@property (nonatomic,strong) NSMutableArray *modelArray;//存储model的数组
@property (nonatomic,strong) RATreeView *raTreeView;
@property (nonatomic,strong) NSMutableArray *dataSourceArray;//存储model的数组

@end

@implementation ViewController

static NSString * const OfficeCellIdentifier = @"OfficeCellIdentifier";
static NSString * const StaffCellIdentifier = @"StaffCellIdentifier";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.departmentArray = [[NSArray alloc] init];
    self.dataSourceArray = [NSMutableArray array];

    [self getDataWithContact];
    [self.view addSubview:self.raTreeView];
}

- (NSArray <NodeModel*>*)handelOffices:(NSArray <Offices*>*)officeModelsArray{
    NSMutableArray *resultArray = [NSMutableArray array];

    [officeModelsArray enumerateObjectsUsingBlock:^(Offices * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
   
       NodeModel *node = [self dealStaffs:obj];
       if (obj.subOffice.count > 0) {
            NSArray *subOfficeArray = [self handelOffices:obj.subOffice];
            NSLog(@"subOfficeArray:%@",subOfficeArray);
           [subOfficeArray enumerateObjectsUsingBlock:^(NodeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
               [node addChild:obj];
           }];
        }
       [resultArray addObject:node];
    }];
    return resultArray;
}

- (NodeModel *)dealStaffs:(Offices *)officeModel{
    NSMutableArray *models = [NSMutableArray array];
    [officeModel.staff enumerateObjectsUsingBlock:^(Staffs * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NodeModel *node = [NodeModel dataObjectWithName:obj.name ID:obj.userId staff:obj children:nil];
         [models addObject:node];
    }];
    
    NodeModel *node = [NodeModel dataObjectWithName:officeModel.name ID:officeModel.departID staff:nil children:models];
    return node;
}

- (void)getDataWithContact {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *responseObj = [Utils getJsonDataJsonname:@"data"];
        NSLog(@"dict:%@",responseObj);
        NSDictionary * contactDict = [responseObj objectForKey:@"b"];
        NSArray *departmentArray = [contactDict objectForKey:@"data"];
        
        for (NSDictionary *goverment in departmentArray) {
            ContactModel *contact = [ContactModel modelWithJSON:goverment];
            [self.modelArray addObject:contact];
        }

        [self.modelArray enumerateObjectsUsingBlock:^(ContactModel  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray <NodeModel *>*array = [self handelOffices:obj.offices];
            NodeModel *node = [NodeModel dataObjectWithName:obj.name ID:obj.ID staff:nil children:array];
         [self.dataSourceArray addObject:node];
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.raTreeView reloadData];
        });
    });
}


- (NSMutableArray *)modelArray {
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

- (RATreeView *)raTreeView
{
    if (!_raTreeView) {
        //创建raTreeView
        _raTreeView = [[RATreeView alloc] init];
        _raTreeView.frame = self.view.bounds;
        //_raTreeView.separatorStyle =  RATreeViewCellSeparatorStyleNone;
        _raTreeView.treeFooterView = [[UIView alloc] init];
        //设置代理
        _raTreeView.delegate = self;
        _raTreeView.dataSource = self;
        //注册单元格
        [_raTreeView registerClass:[UITableViewCell class] forCellReuseIdentifier:OfficeCellIdentifier];
        [_raTreeView registerClass:[ContactCell class] forCellReuseIdentifier:StaffCellIdentifier];
    }
    return _raTreeView;
}


- (Staffs *)getContactUserInfo:(NSString *)userId {
    __block Staffs *node;

    [self.dataSourceArray enumerateObjectsUsingBlock:^(ContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
       node = [self getContactOffices:obj.offices userId:userId];
    }];
    return node;
}

- (Staffs *)getContactOffices:(NSArray <Offices*>*)officeModelsArray userId:(NSString *)userId  {
    __block Staffs *node;
    [officeModelsArray enumerateObjectsUsingBlock:^(Offices * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
        node = [self getUserInfo:obj userId:userId];
        if (obj.subOffice.count > 0) {
            node = [self getContactOffices:obj.subOffice userId:userId];
             //NSLog(@"subOfficeArray:%@",subOfficeArray);
//            [subOfficeArray enumerateObjectsUsingBlock:^(NodeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [node addChild:obj];
//            }];
         }
     }];
    return node;
}

- (Staffs *)getUserInfo:(Offices *)officeArray userId:(NSString *)userId {
    __block Staffs *result;
        [officeArray.staff enumerateObjectsUsingBlock:^(Staffs * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userId isEqualToString:userId]) {
                result = obj;
                *stop = YES;
            }
        }];
    return nil;
}

//返回cell
- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {
    NSInteger level = [treeView levelForCellForItem:item];
    NSLog(@"cellForItem: level:%zd,item:%@",level,item);

    NodeModel *dataObject = item;
     if (!dataObject.staff) {
          UITableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:OfficeCellIdentifier];
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            UIImageView * ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(level*15+10, 18.5 , 8 , 11)];
            ImageView.centerY = 50  * 0.5;
            ImageView.image = [UIImage imageNamed:@"contact_shouqi"];
            ImageView.tag = 300;
            [cell.contentView addSubview:ImageView];
            
            UILabel *officeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(ImageView.frame) + 5, 0, SCREEN_WIDTH, cell.height)];
            officeLabel.centerY = ImageView.centerY;
            officeLabel.font = [UIFont systemFontOfSize:16];
            officeLabel.textColor = [UIColor colorWithHexString:@"#333333"];
            officeLabel.text = [NSString stringWithFormat:@"%@",dataObject.name];
            [cell.contentView addSubview:officeLabel];
            return cell;
     } else {
           ContactCell *cell = [treeView dequeueReusableCellWithIdentifier:StaffCellIdentifier];
           cell.staffModel = dataObject.staff;
           [cell updateSubViewFrame:level];
           return cell;
     }
    
    /*
    if ([item isKindOfClass:[ContactModel class]]) {// 公司层
       
        UITableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:CompanyCellIdentifier];
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

        UIImageView * clickImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15 , 18.5 , 8 , 11)];
        clickImageView.centerY = 50  * 0.5;
        clickImageView.image = [UIImage imageNamed:@"contact_shouqi"];
        clickImageView.tag = 200;
        [cell.contentView addSubview:clickImageView];
        
        ContactModel *model = item;
        UILabel *company = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(clickImageView.frame) + 5, 0, SCREEN_WIDTH, cell.height)];
         company.centerY = clickImageView.centerY;
        company.font = [UIFont systemFontOfSize:16];
        company.textColor = [MyControl colorWithHexString:@"#333333"];
        company.text = [NSString stringWithFormat:@"%@ (%zd)",model.name,model.personNO];
        [cell.contentView addSubview:company];
        return cell;
        
    } else if ([item isKindOfClass:[Offices class]]) {// 公司下的部门层
        UITableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:OfficeCellIdentifier];
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIImageView * ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(level*15+11 , 18.5 , 8 , 11)];
        ImageView.centerY = 50  * 0.5;
        ImageView.image = [UIImage imageNamed:@"contact_shouqi"];
        ImageView.tag = 300;
        [cell.contentView addSubview:ImageView];
        
        Offices *office = item;
        UILabel *officeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(ImageView.frame) + 5, 0, SCREEN_WIDTH, cell.height)];
        officeLabel.centerY = ImageView.centerY;
        officeLabel.font = [UIFont systemFontOfSize:16];
        officeLabel.textColor = [MyControl colorWithHexString:@"#333333"];
        officeLabel.text = [NSString stringWithFormat:@"%@(%zd)",office.name,office.personNO];
        [cell.contentView addSubview:officeLabel];
        return cell;
    }else if ([item isKindOfClass:[Staffs class]]) {// 员工层
        ContactCell *cell = [treeView dequeueReusableCellWithIdentifier:StaffCellIdentifier];
        Staffs *staff = item;
        if ([Global share].contactSelectType == ContactVcSelectTypeMultiSelect) {
            cell.checkButton.hidden = NO;
        } else {
            cell.checkButton.hidden = YES;
        }
        cell.staffModel = staff;
        return cell;
    }
     */
    return nil;
}
/**
 *  必须实现
 *
 *  @param treeView treeView
 *  @param item    节点对应的item
 *
 *  @return  每一节点对应的个数
 */
- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
           return self.dataSourceArray.count;
       }
       NodeModel *node = item;
       return node.children.count;
    /*
    NSInteger treeNum = self.modelArray.count;
    if (item == nil) {
        treeNum = self.modelArray.count;
    }
    //NSLog(@"numberOfChildrenOfItem: level:%zd,item:%@",level,item);

    if ([item isKindOfClass:[ContactModel class]]) {
          ContactModel *model = (ContactModel *)item;
          NSArray<Offices*> *officeModelArray =  model.offices;
          treeNum = officeModelArray.count;
    } else if([item isKindOfClass:[Offices class]]) {
        Offices *office = (Offices *)item;
        NSInteger subOfficeNum = 0;
        NSInteger staffNum = 0;
        
        if (office.subOffice.count > 0) {
             subOfficeNum =  office.subOffice.count;
        }
        if (office.staff.count >0) {
             staffNum = office.staff.count;
        }
        treeNum = subOfficeNum + staffNum;
    }
    
  return treeNum;
      */
}
/**
 *必须实现的dataSource方法
 *
 *  @param treeView treeView
 *  @param index    子节点的索引
 *  @param item     子节点索引对应的item
 *
 *  @return 返回 节点对应的item
 */
- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
    
    if (item == nil) {
        return self.dataSourceArray[index];
    }
   NodeModel *node = item;
   return node.children[index];

    /*
    if (item == nil) {
        return self.modelArray[index];
    }

    if ([item isKindOfClass:[ContactModel class]]) {
         ContactModel *contact = item;
         return contact.offices[index];
    } else if([item isKindOfClass:[Offices class]]) {
         Offices *office = (Offices *)item;
        NSMutableArray *staffsArray = [NSMutableArray array];
        if (office.subOffice.count > 0) {
             [staffsArray addObjectsFromArray:office.subOffice];
        }
        
        if (office.staff.count > 0) {
            [staffsArray addObjectsFromArray:office.staff];
        }
      
        return staffsArray[index];
    }
    
    return nil;
     */
}


//cell的点击方法
- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item {
        
    //获取当前的层
    //NSInteger level = [treeView levelForCellForItem:item];
    NSLog(@"didSelectRowForItem:item:%@",item);
    
    NodeModel *model = item;
    NSLog(@"staff:%@",model.staff);
//    if (model.staff) {
//        Staffs *staffModel = model.staff;
//        if ([Global share].contactSelectType == ContactVcSelectTypeMultiSelect) {
//            staffModel.isCheck = !staffModel.isCheck;
//            [self.select addObject:item];
//            [self.raTreeView reloadRowsForItems:self.select withRowAnimation:RATreeViewRowAnimationNone];
//
//            if ([self.delegate respondsToSelector:@selector(contactOrganizationView:selectStaffsModel:)]) {
//                [self.delegate contactOrganizationView:self selectStaffsModel:staffModel];
//            }
//        } else if([Global share].contactSelectType == ContactVcSelectTypeSingleSelect) {
//            UserInfoVc * userInfoVc = [[UserInfoVc alloc] initWithUserInfo:staffModel.userId companyId:staffModel.companyId officeId:staffModel.officeId];
//            [[Tool getCurrentVC].navigationController pushViewController:userInfoVc animated:YES];
//        } else {// 点击选择名片
//            if ([self.delegate respondsToSelector:@selector(contactOrganizationView:selectStaffsModel:)]) {
//                [self.delegate contactOrganizationView:self selectStaffsModel:staffModel];
//            }
//        }
//    }
    
}

//单元格是否可以编辑 默认是YES
- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item {
    
    return NO;
}

//编辑要实现的方法
- (void)treeView:(RATreeView *)treeView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowForItem:(id)item {
    //NSLog(@"编辑了实现的方法");
}

#pragma mark - delegate
//返回行高
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
    return 50 ;
}

//将要展开
- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item {
    NodeModel *dataObject = item;

    if (!dataObject.staff) {
        UITableViewCell *cell = (UITableViewCell *)[treeView cellForItem:item];
        UIImageView *clickImageView = nil;
        for (UIView * view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                clickImageView = (UIImageView *)view;
                break;
            }
        }
        [UIView animateWithDuration:0.25 animations:^{
            clickImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }];
    }
    
}
//将要收缩
- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item {
    NodeModel *dataObject = item;

    if (!dataObject.staff) {
        UITableViewCell *cell = (UITableViewCell *)[treeView cellForItem:item];
        UIImageView *clickImageView = nil;
        for (UIView * view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                clickImageView = (UIImageView *)view;
                break;
            }
        }
        [UIView animateWithDuration:0.25 animations:^{
            clickImageView.transform = CGAffineTransformIdentity;
        }];
    }
    
}

//已经展开
- (void)treeView:(RATreeView *)treeView didExpandRowForItem:(id)item {

}
//已经收缩
- (void)treeView:(RATreeView *)treeView didCollapseRowForItem:(id)item {

}

@end
