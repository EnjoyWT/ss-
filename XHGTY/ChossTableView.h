//
//  ChossTableView.h
//  APP
//
//  Created by 马罗罗 on 2017/4/21.
//  Copyright © 2017年 马罗罗. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChossTableView : UITableView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , strong) NSMutableArray *dataArray;
@end
