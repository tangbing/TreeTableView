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
    self.dataSourceArray = [NSMutableArray array];
    self.modelArray = [NSMutableArray array];
    
    [self getDataWithContact];
    [self.view addSubview:self.raTreeView];
    
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

- (NSArray <NodeModel*>*)handelOffices:(NSArray <Offices*>*)officeModelsArray{
    NSMutableArray *resultArray = [NSMutableArray array];

    [officeModelsArray enumerateObjectsUsingBlock:^(Offices * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
   
       NodeModel *node = [self dealStaffs:obj];
       if (obj.subOffice.count > 0) {
            NSArray *subOfficeArray = [self handelOffices:obj.subOffice];
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

}


//cell的点击方法
- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item {
        
    //获取当前的层
    //NSInteger level = [treeView levelForCellForItem:item];
    NSLog(@"didSelectRowForItem:item:%@",item);
    
    NodeModel *model = item;
    NSLog(@"staff:%@",model.staff);
    
   //Staffs *staff = [self getContactUserInfo:model.ID ];
   // NSLog(@"name:%@,userId:%@,profileImg:%@",staff.name, staff.userId, staff.profileImg);
    
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


@end
