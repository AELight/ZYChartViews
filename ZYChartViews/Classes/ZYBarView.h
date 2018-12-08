//
//  ZYBarView.h
//  ZYChartView
//
//  Created by zhuyi on 2018/8/1.
//  Copyright © 2018年 zhuyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYBarView : UIView

@property(nonatomic, assign)int ylineSectionCount;//Y轴段数(默认5)
@property(nonatomic, assign)float yMinValue;//Y轴最小值(默认0)
@property(nonatomic, assign)float yMaxValue;//Y轴最大值(默认150)

@property(nonatomic, strong) NSArray *titleArray;//月份数组(12个元素)
@property(nonatomic, strong) NSMutableArray *yearTotalArray;//月份数据 - 元素为字符串(>=0 &&<=12个),更改时则重绘

@property(nonatomic, strong)UIFont *lineTxtFont;//坐标轴文字大小(默认10)
@property(nonatomic, strong)UIColor *lineTxtColor;//坐标轴文字颜色(有默认值)
@property(nonatomic, strong)UIFont *lineSlctTxtFont;//选中时坐标轴文字大小(默认10)

@property(nonatomic, strong)UIFont *currentMonthTxtFont;//选中/当前月文字/数值大小(默认12)

@property(nonatomic, assign)int barWith;//柱宽(默认10)
@property(nonatomic, assign)int barSpace;//柱间距(默认10)

@property(nonatomic, assign)BOOL isDefaultState;//是否是默认状态(YES:默认状态,NO:选中则为红色粗柱体状态)

@end
