//
//  ZYAngularGraphView.h
//  ZYChartView
//
//  Created by zhuyi on 2018/8/1.
//  Copyright © 2018年 zhuyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYAngularGraphView : UIView

@property (nonatomic, copy) NSString *backgroundImgName;//背景图片名字
@property (nonatomic, assign) CGFloat maxValue;//每条线的最大值
@property (nonatomic, assign) CGFloat minValue;//每条线的原点值
@property (nonatomic, assign) NSUInteger steps;//刻度线总数(1:只显示最外面一圈,其余非零值若干圈线)
@property (nonatomic, assign) BOOL fillColor; //是否填充颜色
@property (nonatomic, strong) NSArray *sourceENameArr;//单个数据类型中数据元素的数组(顶点对应的标题)
    
//下面三个数组内的元素需要一一对应(最后一个内的元素为数组)
@property (nonatomic, strong) NSArray *dataTypeNameArray;//各组数据对应的组名称数组
@property (nonatomic, strong) NSArray *colorsArray;//各组数据对应的填充颜色数组
@property (nonatomic, strong) NSArray<NSArray *> *sourceDatas;//数据源(元素为集合)

@end
