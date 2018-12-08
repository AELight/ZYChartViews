//
//  ZYAngularGraphView.m
//  ZYChartView
//
//  Created by zhuyi on 2018/8/1.
//  Copyright © 2018年 zhuyi. All rights reserved.
//
/*
整体步骤如下
    1.绘制背景图片
    2.绘制数据类型
    3.绘制各角的圆圈标题
    4.获取总多边形的路径并绘制对应的填充色(背景色)
    5.获取并绘制刻度线对应的圈
    6.循环遍历数据源绘制实际数据对应的图
        6.1.获取多边形路径
        6.2.拷贝路径
        6.3.绘制多边形边线
        6.4.恢复路径并绘制内部填充色(最后一组为渐变色)
        6.5.释放路径
        6.6.绘制交点
    7.绘制中心至各顶点的线
    8.绘制竖直方向的刻度值
 */

#import "ZYAngularGraphView.h"


#define ZY_TEXT_SIZE(text, font) [text length] > 0 ? [text sizeWithAttributes : @{ NSFontAttributeName : font }] : CGSizeZero;
#define ZY_DRAW_TEXT_IN_RECT(text, rect, font) [text drawInRect : rect withAttributes : @{ NSFontAttributeName:font }];

#define CircleToAngleMargin 10.0 //文字所在圆形与多边形各定点的距离
#define CircleR 20//文字所在圆形视图的半径
#define TextFont [UIFont systemFontOfSize:12]//标题文字大小
#define NumberFont [UIFont systemFontOfSize:8.0] //刻度数 字体大小
#define TextColor [UIColor whiteColor]//标题文字颜色

@interface ZYAngularGraphView ()
@property (nonatomic, assign) CGPoint centerPoint;//中心位置
@property (nonatomic, assign) CGFloat angleR;//半径
@property (nonatomic, assign) NSUInteger angleCount;//一共几个角
//下列属性均可移至声明文件,暴露供修改
@property (nonatomic, assign) BOOL clockwise; //是否顺时针(默认YES)
@property (nonatomic, assign) BOOL drawPoints;//是否绘制交点(默认YES)
@property (nonatomic, assign) BOOL showStepNumber;//是否显示刻度线值(竖直方向,默认YES)
@end


@implementation ZYAngularGraphView
#pragma mark - 初始化方法
//代码创建
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

//xib创建
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

//初始化
- (void)setDefaultValues {
    self.backgroundColor = [UIColor clearColor];
    
    _clockwise = YES;
    _drawPoints = YES;
    _showStepNumber = YES;
    _sourceENameArr = [NSMutableArray array];//防止外部未传值
    
    //设置中心(多边形的中心位于视图的几何中心)
    _centerPoint = CGPointMake(self.bounds.size.width / 2,self.bounds.size.height/2);
    _angleR = MIN(self.bounds.size.width / 2, self.bounds.size.height/ 2) - 60 ;//顶部文字所在的圆的边距离多边形顶点的距离10+顶部文字所在圆的直径40+顶部文字所在圆边距视图边的距离10 = 60
}

- (void)setSourceDatas:(NSArray *)sourceDatas {
    _sourceDatas = sourceDatas;
    _angleCount = [sourceDatas[0] count];
    [self setNeedsDisplay];
}

#pragma mark - 绘图
- (void)drawRect:(CGRect)rect {
    //1.绘制背景图片
    if (self.backgroundImgName && self.backgroundImgName.length>0) {
        UIImage *img = [UIImage imageNamed:self.backgroundImgName];
        [img drawInRect:rect];
    }
    
    //2.绘制每组数据对应的类型说明
    for(int i = 0 ; (i<self.dataTypeNameArray.count && i < self.colorsArray.count);i++){
        NSString *typeName = self.dataTypeNameArray[i];
        NSDictionary *attributes = @{NSFontAttributeName:NumberFont, NSForegroundColorAttributeName:self.colorsArray[i]};
        [typeName drawInRect:CGRectMake(10, 64+i*15, 25, 15) withAttributes:attributes];
    }
    
    //3.每个角的弧度值
    CGFloat perAngleValue = M_PI * 2 / self.angleCount;//2PI/角数
    if (self.clockwise) {//顺时针
        perAngleValue =  - perAngleValue;
    }
    
    //0.获取图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //1.绘制文字及文字所在的圆圈
    for (int i = 0; (i < self.angleCount && i < self.sourceENameArr.count); i++) {//顺时针(从上面顶点开始)
        NSString *attributeName = self.sourceENameArr[i];
        //1.1多边形各个顶点坐标
        CGPoint pointOnEdge = CGPointMake(self.centerPoint.x - self.angleR * sin(i * perAngleValue), self.centerPoint.y - self.angleR * cos(i * perAngleValue));
        
        //1.2.1绘制标题圆圈及填充色
        CGPoint circlePoint = CGPointMake(pointOnEdge.x - (CircleR + CircleToAngleMargin) * sin(i * perAngleValue), pointOnEdge.y - (CircleR + CircleToAngleMargin) * cos(i * perAngleValue));
        
        CGContextAddArc(context, circlePoint.x, circlePoint.y, CircleR, 0, M_PI * 2, YES);
        CGContextSetRGBFillColor(context, 37/255.0, 161/255.0, 98/255.0, 1.0);//圆圈的颜色(绿色)
        CGContextFillPath(context);
        //1.2.2绘制标题文字
        CGSize attributeTextSize = ZY_TEXT_SIZE(attributeName, TextFont);
        NSInteger txtW = attributeTextSize.width;
        NSInteger txtH = attributeTextSize.height;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        NSDictionary *attributes = @{NSFontAttributeName: TextFont,NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName:TextColor};
        
        [attributeName drawInRect:CGRectMake(circlePoint.x - txtW / 2.0,circlePoint.y - txtH / 2.0, txtW, txtH) withAttributes:attributes];
    }
    
    //2.绘制多边形背景色
    CGContextMoveToPoint(context, self.centerPoint.x, self.centerPoint.y - self.angleR);
    for (int i = 1; i <= self.angleCount; ++i) {
        CGContextAddLineToPoint(context, self.centerPoint.x - self.angleR * sin(i * perAngleValue), self.centerPoint.y - self.angleR * cos(i * perAngleValue));
    }
    CGContextSetRGBFillColor(context ,238/255.0, 161/255.0, 110/255.0, 0.7);//多边形背景色
    CGContextFillPath(context);
    
    //3.绘制刻度值对应的线(包含最外面的一圈线)
    for (int step = 1; step <= self.steps; step++) {
        for (int i = 0; i <= self.angleCount; ++i) {
            if (i == 0) {
                CGContextMoveToPoint(context, self.centerPoint.x, self.centerPoint.y - self.angleR * step / self.steps);
            }
            else {
                CGContextAddLineToPoint(context, self.centerPoint.x - self.angleR * sin(i * perAngleValue) * step / self.steps, self.centerPoint.y - self.angleR * cos(i * perAngleValue) * step / self.steps);
            }
        }
    }
    CGContextSetRGBStrokeColor(context, 254.0/255, 205.0/255, 82.0/255, 1.0);//线的颜色
    CGContextSetLineWidth(context, 0.5);//线宽
    CGContextStrokePath(context);
    
    //4.遍历数据源绘制实际数据对应的图(边界,填充色及交点)
    if (self.angleCount > 0) {
        CGFloat firstValue = 0;
        for (int index = 0; index < [self.sourceDatas count]; index++) {
            int subCount = (int)[self.sourceDatas[index] count];
            for (int i = 0; i < subCount; ++i) {
                //绘制返回范围(最大值的0.05~0.95) - 最小值为0
                CGFloat value = [self.sourceDatas[index][i] floatValue];
                //设置最大值+最小值时使用
//                if (value <= self.maxValue * 0.05 ) {
//                    value = self.maxValue * 0.05;
//                }
//                else if (value >=  self.maxValue){//残缺也是美
//                    value = self.maxValue * 0.95;
//                }
//                else{
//
//                }
                
                if (i == 0) {//内圈起点
                    firstValue = value;
                    CGContextMoveToPoint(context, self.centerPoint.x, self.centerPoint.y - (value - self.minValue) / (self.maxValue - self.minValue) * self.angleR);
                }
                else {//内圈路线
                    CGContextAddLineToPoint(context, self.centerPoint.x - (value - self.minValue) / (self.maxValue - self.minValue) * self.angleR * sin(i * perAngleValue), self.centerPoint.y - (value - self.minValue) / (self.maxValue - self.minValue) * self.angleR * cos(i * perAngleValue));
                    if (i == subCount - 1) {
                        //最后一条线
                        CGContextAddLineToPoint(context, self.centerPoint.x, self.centerPoint.y - (firstValue - self.minValue) / (self.maxValue - self.minValue) * self.angleR);
                    }
                }
            }
            //复制当前路径用于后面绘制填充色
            CGPathRef currentPath = CGContextCopyPath(context);
            
            //绘制多边形边线
            [self.colorsArray[index] setStroke];//线的颜色CGContextSetRGBStrokeColor(context,1.0,0,0,1.0);
            CGContextSetLineWidth(context, 3);//线宽
            CGContextDrawPath(context, kCGPathStroke);//或者 CGContextStrokePath(context);
            
            //获取多边形路径用于绘制内部填充色
            CGContextAddPath(context, currentPath);
            if (self.fillColor) {//绘制多边形内部填充色
                if(index < self.sourceDatas.count - 1){//使用一般颜色填充
                    [self.colorsArray[index] setFill];
                    CGContextFillPath(context);
                }
                else{//使用渐变色填充
                    CGContextSaveGState(context);//保存上下文状态
                    
                    CGContextClip(context);//裁切出渐变区域(必须先裁切再调用渐变)
                    
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//使用rgb颜色空间
                    
                    //颜色组件
                    CGFloat compoents[8]= {//12
//                    153.0/255.0, 154.0/255.0, 69.0/255.0, 0.9,
                        255.0/255, 230.0/255, 75.0/255, 0.9,
                        255.0/255, 165.0/255, 40.0/255, 0.9
                    };
                    CGFloat locations[2] = {0, 1.0};//3, 0.5
                    CGGradientRef gradient= CGGradientCreateWithColorComponents(colorSpace, compoents, locations, 2);//3
                    CGContextDrawRadialGradient(context, gradient, self.centerPoint,0, self.centerPoint, self.angleR, kCGGradientDrawsBeforeStartLocation);
                    
                    //释放
                    CGColorSpaceRelease(colorSpace);
                    CGGradientRelease(gradient);
                    
                    CGContextRestoreGState(context);//恢复上下文状态
                }
            }
            CGPathRelease(currentPath);//释放多边形路径
            
            //绘制交点
            if (self.drawPoints) {
                for (int i = 0; i < self.angleCount; i++) {
                    CGFloat value = [self.sourceDatas[index][i] floatValue];
                    CGFloat xVal = self.centerPoint.x - (value - self.minValue) / (self.maxValue - self.minValue) * self.angleR * sin(i * perAngleValue);
                    CGFloat yVal = self.centerPoint.y - (value - self.minValue) / (self.maxValue - self.minValue) * self.angleR * cos(i * perAngleValue);

                    [self.colorsArray[index] setFill];//外圈颜色
                    CGContextFillEllipseInRect(context, CGRectMake(xVal - 2, yVal - 2, 4, 4));
                    [self.backgroundColor setFill];//内圈颜色
                    CGContextFillEllipseInRect(context, CGRectMake(xVal - 1, yVal - 1, 2, 2));
                }
            }
        }
    }
    
    //5.绘制中心到顶点的线
    for (int i = 0; i < self.angleCount; i++) {
        CGPoint apexPoint = CGPointMake(self.centerPoint.x - self.angleR * sin(i * perAngleValue), self.centerPoint.y - self.angleR * cos(i * perAngleValue));
        CGContextMoveToPoint(context, self.centerPoint.x, self.centerPoint.y);
        CGContextAddLineToPoint(context, apexPoint.x,
                               apexPoint.y);
        CGContextSetRGBStrokeColor(context, 220.0/255, 84.0/255, 75.0/255, 0.5);
        CGContextSetLineWidth(context, 0.5);//线宽
        CGContextStrokePath(context);
    }
    
    //6.绘制刻度值
    if (self.showStepNumber) {
        [[UIColor blackColor] setFill];//颜色
        for (int number = 0; number <= self.steps; number++) {
            CGFloat value = self.minValue + (self.maxValue - self.minValue) * number * 1.0f / self.steps;
            NSString *valueStr = [NSString stringWithFormat:@"%.0f", value];
            ZY_DRAW_TEXT_IN_RECT(valueStr, CGRectMake(self.centerPoint.x + 3, self.centerPoint.y - self.angleR * number / self.steps - 3,20,10), NumberFont);
        }
    }
}

@end
