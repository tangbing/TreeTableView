

# TreeTableView

一个无限层级树形结构TableView展示

## 一. 之前通讯录是三级层级，公司->部门->员工，但这次需求一改，要求在部门下还有子部门，子部门下还有部门，层级结构不固定，完全有后台返回的数据决定，最后终于完成了需求，效果如下:

```html
<img src="https://github.com/tangbing/TreeTableView/blob/master/Screens/treeTableView.gif" width="375" alt="效果图">
```

二.这里我用到了第三方库[RATreeView](https://github.com/Augustyniak/RATreeView)实现，关键代码我以下会贴出

- 准备节点NodeModel数据

``` objective-c
@interface NodeModel : NSObject

@property (nonatomic, copy)NSString *ID;

@property (nonatomic, copy)NSString *name;
// 员工模型
@property (nonatomic, strong)Staffs *staff;

@property (nonatomic, strong)NSArray *children;

// 初始化节点数据
- (id)initWithName:(NSString *)name ID:(NSString *)ID staff:(Staffs *)staffModel children:(NSArray *)array;

+ (id)dataObjectWithName:(NSString *)name ID:(NSString *)ID staff:(Staffs *)staffModel children:(NSArray *)children;
// 添加子节点
- (void)addChild:(id)child;
    
@end
```



```objective-c
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

```



- 处理后台返回的数据，转成NodeModel

  ```objective-c
  [self.modelArray enumerateObjectsUsingBlock:^(ContactModel  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
              NSArray <NodeModel *>*array = [self handleOffices:obj.offices];
              NodeModel *node = [NodeModel dataObjectWithName:obj.name ID:obj.ID staff:nil children:array];
           [self.dataSourceArray addObject:node];
              
          }];
          dispatch_async(dispatch_get_main_queue(), ^{
              [self.raTreeView reloadData];
          });
  
  - (NSArray <NodeModel*>*)handleOffices:(NSArray <Offices*>*)officeModelsArray{
      NSMutableArray *resultArray = [NSMutableArray array];
  
      [officeModelsArray enumerateObjectsUsingBlock:^(Offices * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         // 这里递归调用把Offices数据以及子Offices数据，转成节点NodeModel数据，
         NodeModel *node = [self handelStaffs:obj];
         if (obj.subOffice.count > 0) {
              NSArray *subOfficeArray = [self handleOffices:obj.subOffice];
             [subOfficeArray enumerateObjectsUsingBlock:^(NodeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 [node addChild:obj];
             }];
          }
         [resultArray addObject:node];
      }];
      return resultArray;
  }
  
  - (NodeModel *)handelStaffs:(Offices *)officeModel{
      NSMutableArray *models = [NSMutableArray array];
      [officeModel.staff enumerateObjectsUsingBlock:^(Staffs * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          NodeModel *node = [NodeModel dataObjectWithName:obj.name ID:obj.userId staff:obj children:nil];
           [models addObject:node];
      }];
      
      NodeModel *node = [NodeModel dataObjectWithName:officeModel.name ID:officeModel.departID staff:nil children:models];
      return node;
  }
  ```

- 剩下的就是赋值数据了，类似tableview这样，最后Demo看[这里](https://github.com/tangbing/TreeTableView.git)

  





