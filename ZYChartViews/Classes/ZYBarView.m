//
//  ZYBarView.m
//  ZYChartView
//
//  Created by zhuyi on 2018/8/1.
//  Copyright © 2018年 zhuyi. All rights reserved.
//

#import "ZYBarView.h"

#define TOPBOTTTOMSPACE 40.0//X轴距离底部间距/顶部间距
#define LEFTRIGHTSPACE 25.0//左右间距
#define STARTPOINTX  (LEFTRIGHTSPACE + 17.0)//坐标轴原点x值
#define STARTPOINTY (self.bounds.size.height - TOPBOTTTOMSPACE)//坐标轴原点y值
#define YLINEENDY 20.0//Y轴结束y值
#define XLINEENDX (self.bounds.size.width - LEFTRIGHTSPACE)//X轴结束时x值
#define YLINESECLEGTH 5.0//Y轴刻度线长度
#define SPACETOLINE 3.0//文字距离坐标轴间距
#define ZY_TEXT_SIZE(text, font) [text length] > 0.0 ? [text sizeWithAttributes : @{NSFontAttributeName:font}]:CGSizeZero;
#define ZY_DRAW_TEXT_IN_RECT(text, rect, font) [text drawInRect : rect withAttributes : @{ NSFontAttributeName:font }];

#define firstColor  [UIColor colorWithRed:35.0/255 green:160.0/255 blue:97.0/255 alpha:1.0]
#define secondColor  [UIColor colorWithRed:219.0/255 green:81.0/255 blue:73.0/255 alpha:1.0]
#define thirdColor [UIColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0]
#define lineColor [UIColor colorWithRed:254.0/255 green:205.0/255 blue:82.0/255 alpha:1.0]
@interface ZYBarView()

@property(nonatomic, strong)NSMutableArray *pathRectArray;//bar路径中绘图的原始rect数组
@property(nonatomic, strong)NSMutableArray *pathRectChangeArray;//bar路径中绘图的点击后rect数组
@property(nonatomic, assign)NSUInteger selectedBarIndex;//被选中的bar的角标(从-1开始)
@end


@implementation ZYBarView
#pragma mark - 初始化
//代码方式
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initDefaultValue];
    }
    return self;
}
//xib方式
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initDefaultValue];
    }
    return self;
}

//设置初始值
- (void)initDefaultValue
{
    self.backgroundColor = [UIColor whiteColor];
    _ylineSectionCount = 5;
    _yMinValue = 0;
    _yMaxValue = 150;
    _titleArray = @[@"1月", @"2月", @"3月", @"4月", @"5月", @"6月", @"7月", @"8月", @"9月", @"10月", @"11月", @"12月"];
    _yearTotalArray = [NSMutableArray arrayWithArray:@[@"80",@"90", @"140", @"110", @"80", @"100", @"130",@"100", @"70", @"60", @"110"]];//, @"120"
    _lineTxtFont = [UIFont systemFontOfSize:10];
    _lineTxtColor = [UIColor blackColor];
    _lineSlctTxtFont = [UIFont systemFontOfSize:12];
    
    _currentMonthTxtFont = [UIFont systemFontOfSize:12];
    _selectedBarIndex = -1;
//    _barWith = kIphone6P?13: 10;
//    _barSpace = kIphone6P?13: 10;
    _barSpace = _barWith = (XLINEENDX - STARTPOINTX)/25;
    _pathRectArray = [[NSMutableArray alloc]init];
    _pathRectChangeArray = [[NSMutableArray alloc]init];
}

#pragma mark - 更改数据源则重绘
- (void)setYearTotalArray:(NSMutableArray *)yearTotalArray
{
    _yearTotalArray = yearTotalArray;
    if (yearTotalArray.count > 0) {
        [self setNeedsDisplay];
    }
}
- (void)drawRect:(CGRect)rect {
    //一,X轴
    //1.获取上下文
    CGContextRef ref = UIGraphicsGetCurrentContext();
    //2.描述/添加路径
    CGMutablePathRef path = CGPathCreateMutable();//创建路径
    CGPathMoveToPoint(path, NULL, STARTPOINTX, STARTPOINTY);
    CGPathAddLineToPoint(path, NULL, XLINEENDX, STARTPOINTY);
    CGContextAddPath(ref, path);
    CGContextSetLineWidth(ref, 1);
    [lineColor set];
    //3.渲染上下文
    CGContextStrokePath(ref);//X轴
    
    //二,Y轴
    float secLegth = (_yMaxValue - _yMinValue)/_ylineSectionCount;
    
    CGPathMoveToPoint(path, NULL, STARTPOINTX, STARTPOINTY);
    CGPathAddLineToPoint(path, NULL, STARTPOINTX,  STARTPOINTY - (_yMaxValue - _yMinValue)/_yMaxValue * (STARTPOINTY - YLINEENDY) );
    CGContextAddPath(ref, path);
    CGContextStrokePath(ref);
    
    //三,y轴刻度线及对应刻度值
    CGPoint secEndP = CGPointZero;
    for (int i = 0; i < _ylineSectionCount + 1; i++) {
        secEndP = CGPointMake(STARTPOINTX - YLINESECLEGTH, STARTPOINTY - secLegth/_yMaxValue * (STARTPOINTY - YLINEENDY) * i);
        if (i != 0) {
            CGPathMoveToPoint(path, NULL, STARTPOINTX, STARTPOINTY - secLegth/_yMaxValue * (STARTPOINTY - YLINEENDY) * i);
            CGPathAddLineToPoint(path, NULL, secEndP.x , secEndP.y);
            CGContextAddPath(ref, path);
            CGContextStrokePath(ref);
        }
        
        //绘制文字
        NSString *yValue = [NSString stringWithFormat:@"%d",(int)secLegth * i];
        CGSize attributeTextSize = ZY_TEXT_SIZE(yValue, _lineTxtFont);
        NSInteger txtW = attributeTextSize.width;
        NSInteger txtH = attributeTextSize.height;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        NSDictionary *attributes = @{NSFontAttributeName: _lineTxtFont,NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName:_lineTxtColor };
        
        [yValue drawInRect:CGRectMake(secEndP.x - txtW - SPACETOLINE,secEndP.y - txtH / 2.0, txtW, txtH) withAttributes:attributes];
    }
    
    //4,X轴bar/对应标题及数值
    CGPoint namePoint = CGPointZero;
    NSUInteger indexNumber = _yearTotalArray.count;
    CGFloat x = STARTPOINTX + _barSpace;
    CGFloat w = 0;
    for (NSUInteger i = 0; i < _titleArray.count; i++) {
        //一般尺寸值
        CGFloat h = 0;
        if (i < indexNumber) {
            h = ([_yearTotalArray[i] intValue ]- _yMinValue)/(_yMaxValue - _yMinValue) * (STARTPOINTY - YLINEENDY);
        }else{
            h = 0.1 * (STARTPOINTY - YLINEENDY);
        }
        
        CGFloat y = STARTPOINTY - h;
        UIFont *factFont = nil;
        UIColor *factBarColor = nil;
        if (indexNumber == 1) {//只有一个数据(当前红,其后灰)
            if (i == 0) {
                w =  _isDefaultState?_barWith :_barWith * 2;
                factFont = _isDefaultState?_lineTxtFont:_lineSlctTxtFont;
                factBarColor = _isDefaultState?firstColor:secondColor;
            }
            if (i == 1) {
                x += w + _barSpace;
                w = _barWith;
                factFont = _lineTxtFont;
                factBarColor = thirdColor;
            }
        }else if (indexNumber < 12) {//小于12个数据 当前红,其前绿,其后灰
            if (i < indexNumber - 1) {
                w = _barWith;
                if (i > 0) {
                    x += _barSpace + _barWith;
                }
                factFont = _lineTxtFont;
                factBarColor = firstColor;
            }else if(i == indexNumber - 1){
                w = _isDefaultState?_barWith :_barWith * 2;
                factFont = _isDefaultState?_lineTxtFont:_lineSlctTxtFont;
                factBarColor = _isDefaultState?firstColor:secondColor;
                x += w + _barSpace;
            }else if(i == indexNumber){
                x += _barSpace + w;
                w = _barWith;
                factFont = _lineTxtFont;
                factBarColor = thirdColor;
            }
        }else{//12个数据,最后红,其前绿
            if(i < _titleArray.count - 1){
                w = _barWith;
                if (i > 0) {
                    x += _barSpace + _barWith;
                }
                factFont = _lineTxtFont;
                factBarColor = firstColor;
            }else{
                x += _barSpace + w;
                w = _isDefaultState?_barWith :_barWith * 2;
                factFont = _isDefaultState?_lineTxtFont:_lineSlctTxtFont;
                factBarColor = _isDefaultState?firstColor:secondColor;
            }
        }
        CGContextRef barRef = UIGraphicsGetCurrentContext();
        CGMutablePathRef barPath = CGPathCreateMutable();
        
        //绘制bar的区域
        if( i < _pathRectChangeArray.count){
            rect = [[_pathRectChangeArray objectAtIndex:i] CGRectValue];
            if (i == _selectedBarIndex) {
                factBarColor = secondColor;
                factFont = _currentMonthTxtFont;
                
            }else{
                factBarColor = firstColor;
                _lineSlctTxtFont = _lineTxtFont;
                if (i == indexNumber ) {
                    factBarColor = thirdColor;
                    _lineSlctTxtFont = _lineTxtFont;
                }
            }
            
        }else{
            rect = CGRectMake(x, y, w, h);
            [_pathRectArray insertObject:[NSValue valueWithCGRect:rect] atIndex:i];
        }
        
        //绘制bar
        CGPathAddRect(barPath, NULL, rect);
        [factBarColor set];
        CGPoint valuePoint = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y);
        if (rect.size.width == _barWith * 2) {
            //被选中月份的通知(@"index":月份值,@"numberStr":数值字符串)
            NSDictionary *infoDic = @{@"index":@(i + 1),@"numberStr":_yearTotalArray[i]};
            [[NSNotificationCenter defaultCenter]postNotificationName:@"feshGraphData" object:nil userInfo:infoDic];
            //绘制月份对应总数值,月份值
            [self drawValueWithString:_yearTotalArray[i] andPoint:valuePoint];
        }
        CGContextFillRect(barRef, rect);
        
        //绘制坐标轴文字
        NSString *yValue = _titleArray[i];//月份名字
        CGSize attributeTextSize = ZY_TEXT_SIZE(yValue, factFont);
        NSInteger txtW = attributeTextSize.width;
        NSInteger txtH = attributeTextSize.height;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        NSDictionary *attributes = @{NSFontAttributeName: factFont,NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName:_lineTxtColor};
       
        namePoint = CGPointMake(rect.origin.x + rect.size.width/2, STARTPOINTY);
        [yValue drawInRect:CGRectMake(namePoint.x - txtW /2.0,namePoint.y  + SPACETOLINE * 2, txtW, txtH) withAttributes:attributes];
        if ((indexNumber == 1 && (i ==1))||(indexNumber < _titleArray.count && i == indexNumber) || (indexNumber == _titleArray.count && i == indexNumber -1)) {
            break;
        }
        CGPathRelease(barPath);
    }
    
    CGPathRelease(path);
}

//绘制选中bar顶部文字
- (void)drawValueWithString:(NSString *)string andPoint:(CGPoint)point
{
    CGSize attributeTextSize = ZY_TEXT_SIZE(string, _currentMonthTxtFont);
    NSInteger txtW = attributeTextSize.width;
    NSInteger txtH = attributeTextSize.height;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributes = @{NSFontAttributeName: _currentMonthTxtFont,NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName:_lineTxtColor};
    
    [string drawInRect:CGRectMake(point.x - txtW /2.0,point.y  - SPACETOLINE * 2 - txtH, txtW, txtH) withAttributes:attributes];
}

#pragma mark - 手势操作
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan: touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if ((point.x > XLINEENDX && point.x < STARTPOINTX)||(point.y < YLINEENDY && point.y > STARTPOINTY)) {
        return;
    }
    
    for (NSUInteger i = 0; i< _pathRectArray.count; i++) {
        if (i == _yearTotalArray.count) {
            return;
        }
        CGRect rect = CGRectZero;
        BOOL isIn = NO;
//        if (_pathRectChangeArray.count == _pathRectArray.count) {
//            
//        }else{//(_pathRectChangeArray.count != _pathRectArray.count)
//            _pathRectChangeArray =[NSMutableArray arrayWithArray:_pathRectArray];
//        }
        
        if (_pathRectChangeArray.count != _pathRectArray.count) {
            _pathRectChangeArray =[NSMutableArray arrayWithArray:_pathRectArray];
        }
        rect = [(NSValue *)[_pathRectChangeArray objectAtIndex:i] CGRectValue];//每个barView的RECT
        //增加被点击区域的灵敏度(扩大有效点击面积)
        float tempSpace = _barSpace * 0.5;
        rect = CGRectMake(rect.origin.x - tempSpace + 0.1, rect.origin.y - tempSpace, rect.size.width + _barSpace - 0.2, rect.size.height + tempSpace);
        isIn =  CGRectContainsPoint(rect, point);//点击的是barView
        
        if (isIn) {
            _isDefaultState = NO;//选中状态(被选中的柱体变成红色,宽度加倍)
            if (_pathRectChangeArray.count == _pathRectArray.count){
                [_pathRectChangeArray removeAllObjects];
                _pathRectChangeArray =[NSMutableArray arrayWithArray:_pathRectArray];
                rect = [(NSValue *)[_pathRectChangeArray objectAtIndex:i] CGRectValue];
            }
            _selectedBarIndex = i;
            CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y, _barWith * 2, rect.size.height);
            for (NSUInteger j = i; j < _pathRectChangeArray.count; j++)
            {
                if (j == i) {
                    [_pathRectChangeArray removeObjectAtIndex:j];
                    [_pathRectChangeArray insertObject:[NSValue valueWithCGRect:newRect] atIndex:j];
                }else{
                    newRect = [(NSValue *)[_pathRectArray objectAtIndex:j] CGRectValue];//每个barView的RECT
                    //点击的bar后面每个bar均右移一个_barWith
                    newRect = CGRectMake([(NSValue *)[_pathRectChangeArray objectAtIndex:j - 1] CGRectValue].origin.x + [(NSValue *)[_pathRectChangeArray objectAtIndex:j - 1] CGRectValue].size.width + _barWith, newRect.origin.y, _barWith, newRect.size.height);
                    [_pathRectChangeArray removeObjectAtIndex:j];
                    [_pathRectChangeArray insertObject:[NSValue valueWithCGRect:newRect] atIndex:j];
                }
            }
            [self setNeedsDisplay];
        }
    }
}
@end
