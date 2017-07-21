//
//  EZPlaybackProgressBar.m
//  EZUIKit
//
//  Created by linyong on 2017/4/24.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EZPlaybackProgressBar.h"

#define UIColorFromRGB(rgbValue,al) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(al)]

#define LINE_WIDTH (1.0)//刻度线宽度
#define LINE_DEFAULT_COLOR ([UIColor colorWithWhite:0.8 alpha:1.0])//刻度线默认颜色
#define RECORD_VIEW_DEFAULT_COLOR (UIColorFromRGB(0x2ab8cf,0.7))//视频区域默认颜色
#define RECORD_VIEW_DEFAULT_COLOR1 (UIColorFromRGB(0xffb8cf,0.7))//视频区域默认颜色
#define HOURS_ONE_PAGE (6)//默认一屏展示小时数
#define SCROLL_VIEW_HEIGHT_PROPORTION (0.8)//滚动视图在整个视图中的高度比例

#define SHOW_MIN10_LINE_HOUR (12)//小于一屏12小时时展示10分钟刻度线
#define SHOW_MIN2_LINE_HOUR (2)//小于一屏2小时时展示2分钟刻度线

#define MAX_HOUR_PER_PAGE (24)//一屏最多显示小时数
#define MIN_HOUR_PER_PAGE (0.5)//一屏最少显示小时数
#define SHOW_2HOUR_LABEL_HOUR (18)//小于一屏18小时时展示2小时的标签
#define SHOW_HOUR_LABEL_HOUR (8)//小于一屏8小时时展示1小时的标签
#define SHOW_MIN_LABEL_HOUR (1.5)//小于一屏1.5小时时展示10分钟的标签

#define MAX_LINE_LENGTH (15.0)//刻度线最大长度
#define MAX_FONT_SIZE (12.0)//最大时间字体

@implementation EZPlaybackInfo


@end

@interface EZPlaybackProgressBar () <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSMutableArray *timeHourLabelList;//显示小时刻度值的label数组
@property (nonatomic,strong) NSMutableArray *time10MinLabelList;//显示10分钟刻度值的label数组
@property (nonatomic,strong) NSMutableArray *recordViewList;//视频片段视图数组
@property (nonatomic,strong) NSMutableArray *hourScaleLineList;//显示小时的时间刻度线的view数组
@property (nonatomic,strong) NSMutableArray *min10ScaleLineList;//显示10分钟的时间刻度线的view数组
@property (nonatomic,strong) NSMutableArray *min2ScaleLineList;//显示2分钟时间刻度线的view数组

@property (nonatomic,assign) NSInteger dayCount;//跨越天数
@property (nonatomic,assign) CGFloat hourPerPage;//一屏展示小时数
@property (nonatomic,strong) UIView *scrollBgView;
@property (nonatomic,strong) UIScrollView *mainScroll;
@property (nonatomic,strong) UILabel *curDateLabel;
@property (nonatomic,strong) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic,strong) CADisplayLink *displayLink;//刷新
@property (nonatomic,assign) BOOL needUpdate;//是否需要更新界面
@property (nonatomic,assign) BOOL needResponseScroll;//是否响应外部滚动
@property (nonatomic,assign) CGFloat touchBeginHourPerPage;//手势触发是每一屏显示的小时数

@property (nonatomic,assign) NSTimeInterval curTimeOffset;//当前中线所指的时间偏移，单位:秒
@property (nonatomic,strong) NSDateFormatter *mFormatter;//格式化日期
@property (nonatomic,strong) NSDate *mBeginDate;//滚动视图开始日期点
@property (nonatomic,assign) CGSize mainScrollContentSize;//记录scrollView的contentSize，伸缩时需先滚动位置再修改scrollView的contentSize，否则会导致异常

@end


@implementation EZPlaybackProgressBar

- (instancetype) initWithFrame:(CGRect)frame dataList:(NSArray *) dataList
{
    if (!dataList || dataList.count == 0)
    {
        return nil;
    }
    
    //保证数据正确
    for (id obj in dataList)
    {
        if (![obj isKindOfClass:[EZPlaybackInfo class]])
        {
            return nil;
        }
    }
    
    self = [super initWithFrame:frame];
    if (self)
    {
        _dataList = dataList;
        
        [self initData];
        [self initSubviews];
        [self addTouch];
        [self createDisplayLink];
    }
    return self;
}

- (void) updateWithDataList:(NSArray *) dataList
{
    [self clearSubViews];
    
    _dataList = dataList;
    _mBeginDate = nil;
    [self initData];
    
    [self drawRecordViewsIsUpdate:NO];
    [self drawsScaleLinesIsUpdate:NO];
    
    [self updateSubviews];
}

- (void) scrollToDate:(NSDate *) dateTime
{
    if (!dateTime || !self.needResponseScroll)
    {
        return;
    }
    
    NSTimeInterval time = [dateTime timeIntervalSinceDate:self.mBeginDate];
    [self scrollToTime:time animated:NO];
}


#pragma mark - actions

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    CGFloat destHourPerPage = self.touchBeginHourPerPage/recognizer.scale;
    
    if (destHourPerPage > MAX_HOUR_PER_PAGE)
    {
        destHourPerPage = MAX_HOUR_PER_PAGE;
    }
    
    if (destHourPerPage < MIN_HOUR_PER_PAGE)
    {
        destHourPerPage = MIN_HOUR_PER_PAGE;
    }
    
    if (destHourPerPage == self.hourPerPage)
    {
        self.needUpdate = NO;
    }
    else
    {
        self.hourPerPage = destHourPerPage;
        self.needUpdate = YES;
    }
}

#pragma mark - override

- (NSDateFormatter *) mFormatter
{
    if (_mFormatter)
    {
        return _mFormatter;
    }
    
    _mFormatter = [[NSDateFormatter alloc] init];
    return _mFormatter;
}

- (NSDate *) mBeginDate
{
    if (_mBeginDate)
    {
        return _mBeginDate;
    }
    
    EZPlaybackInfo *info = [self.dataList firstObject];
    [self.mFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dayStr = [self.mFormatter stringFromDate:info.beginTime];
    [self.mFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    _mBeginDate = [self.mFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",dayStr]];
    return _mBeginDate;
}

- (void) removeFromSuperview
{
    [self destroyDisplayLink];//停止displaylink，对象才可以被释放
    [super removeFromSuperview];
}

#pragma mark - delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    self.touchBeginHourPerPage = self.hourPerPage;
    self.needResponseScroll = NO;
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.needResponseScroll = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate)
    {
        return;
    }
    
    [self scrollEnd];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat timeOffset = scrollView.contentOffset.x;
    if (timeOffset < 0)
    {
        timeOffset = 0;
    }
    
    self.curTimeOffset = [self timeOfOffset:timeOffset];
    [self updateCurDateLabelWithOffset:scrollView.contentOffset.x];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollEnd];
}


#pragma mark - view

- (void) initSubviews
{
    //当前时间点展示
    [self drawCurDateLabel];
    
    //背景视图
    self.scrollBgView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                 CGRectGetHeight(self.frame)*(1.0-SCROLL_VIEW_HEIGHT_PROPORTION),
                                                                 CGRectGetWidth(self.frame),
                                                                 CGRectGetHeight(self.frame)*SCROLL_VIEW_HEIGHT_PROPORTION)];
    self.scrollBgView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollBgView];
    
    //滚动视图
    self.mainScroll = [[UIScrollView alloc] initWithFrame:self.scrollBgView.bounds];
    self.mainScroll.backgroundColor = [UIColor clearColor];
    self.mainScroll.showsVerticalScrollIndicator = NO;
    self.mainScroll.showsHorizontalScrollIndicator = NO;
    self.mainScroll.delegate = self;
    self.mainScroll.contentSize = CGSizeMake(CGRectGetWidth(self.mainScroll.frame)*(self.dayCount*24/self.hourPerPage+1),
                                             CGRectGetHeight(self.mainScroll.frame));
    self.mainScrollContentSize = self.mainScroll.contentSize;
    [self.scrollBgView addSubview:self.mainScroll];
    
    [self drawRecordViewsIsUpdate:NO];
    [self drawBaseLine];
    [self drawsScaleLinesIsUpdate:NO];
    
    //中间游标视图
    UIImage *image = [UIImage imageNamed:@"middle_line"];
    UIImageView *flagImageView = [[UIImageView alloc] initWithImage:image];
    flagImageView.backgroundColor = [UIColor clearColor];
    flagImageView.frame = CGRectMake((CGRectGetWidth(self.scrollBgView.frame)-image.size.width)/2,
                                     0,
                                     image.size.width,
                                     CGRectGetHeight(self.scrollBgView.frame));
    [self.scrollBgView addSubview:flagImageView];
}

- (void) drawCurDateLabel
{
    self.curDateLabel = [[UILabel alloc] init];
    self.curDateLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)*(1-SCROLL_VIEW_HEIGHT_PROPORTION));
    self.curDateLabel.backgroundColor = [UIColor clearColor];
    self.curDateLabel.textColor = [UIColor blackColor];
    self.curDateLabel.font = [UIFont systemFontOfSize:CGRectGetHeight(self.curDateLabel.frame)*0.6];
    self.curDateLabel.textAlignment = NSTextAlignmentCenter;
    self.curDateLabel.text = [self makeCurDateStringWithOffset:0];
    
    [self addSubview:self.curDateLabel];
}

- (void) updateCurDateLabelWithOffset:(CGFloat) offset
{
    self.curDateLabel.text = [self makeCurDateStringWithOffset:offset];
}

- (void) drawBaseLine
{
    UIView *lineView = [self drawHVLineFromPoint:CGPointMake(0, 0)
                                         toPoint:CGPointMake(CGRectGetWidth(self.scrollBgView.frame), 0)
                                           color:LINE_DEFAULT_COLOR];
    [self.scrollBgView addSubview:lineView];
    
    lineView = [self drawHVLineFromPoint:CGPointMake(0, CGRectGetHeight(self.scrollBgView.frame)-LINE_WIDTH)
                                 toPoint:CGPointMake(CGRectGetWidth(self.scrollBgView.frame), CGRectGetHeight(self.scrollBgView.frame)-LINE_WIDTH)
                                   color:LINE_DEFAULT_COLOR];
    [self.scrollBgView addSubview:lineView];
}

- (void) drawRecordViewsIsUpdate:(BOOL) isUpdate
{
    CGFloat offset = CGRectGetWidth(self.scrollBgView.frame)/2;
    CGFloat widthPerSec = (self.mainScrollContentSize.width - CGRectGetWidth(self.mainScroll.frame))/(self.dayCount*24*3600);
    UIView *recordView = nil;
    for (int i = 0;i < self.dataList.count; i++)
    {
        EZPlaybackInfo *info = [self.dataList objectAtIndex:i];
        CGFloat px = offset + [info.beginTime timeIntervalSinceDate:self.mBeginDate]*widthPerSec;
        NSTimeInterval sec = [info.endTime timeIntervalSinceDate:info.beginTime];
        CGFloat width = sec*widthPerSec;

        if (isUpdate)
        {
            recordView = [self.recordViewList objectAtIndex:i];
            recordView.frame = CGRectMake(px, 0, width, CGRectGetHeight(self.mainScroll.frame));
        }
        else
        {
            recordView = [[UIView alloc] init];
            recordView.frame = CGRectMake(px, 0, width, CGRectGetHeight(self.mainScroll.frame));
            recordView.backgroundColor = info.recType == 1? RECORD_VIEW_DEFAULT_COLOR:RECORD_VIEW_DEFAULT_COLOR1;
            [self.mainScroll addSubview:recordView];
            [self.recordViewList addObject:recordView];
        }
    }
}

- (void) drawsScaleLinesIsUpdate:(BOOL) isUpdate
{
    CGPoint point1 = CGPointZero,point2 = CGPointZero,point3 = CGPointZero,point4 = CGPointZero;
    UIView *tempLine = nil;
    UILabel *tempLabel = nil;
    CGFloat offset = CGRectGetWidth(self.scrollBgView.frame)/2;
    CGFloat po = CGRectGetWidth(self.scrollBgView.frame)/self.hourPerPage,tempPx = 0;
    CGFloat fontSize = 0,width = 0,height = 0,maxLineLength = 0,bgHeight = CGRectGetHeight(self.scrollBgView.frame);
    fontSize = CGRectGetHeight(self.frame)*0.1;
    fontSize = fontSize > MAX_FONT_SIZE?MAX_FONT_SIZE:fontSize;
    maxLineLength = CGRectGetHeight(self.frame)*0.15;
    maxLineLength = maxLineLength > MAX_LINE_LENGTH?MAX_LINE_LENGTH:maxLineLength;
    width = 4*fontSize;
    height = fontSize;
    
    //上下边沿小时刻度
    for (int i = 0; i < self.dayCount*24+1; i ++)
    {
        tempPx = offset+i*po;
        point1 = CGPointMake(tempPx, 0);
        point2 = CGPointMake(tempPx, maxLineLength);
        point3 = CGPointMake(tempPx, bgHeight - maxLineLength);
        point4 = CGPointMake(tempPx, bgHeight);
        if (isUpdate)
        {
            tempLine = [self.hourScaleLineList objectAtIndex:i*2];
            [self updateVLineWithView:tempLine fromPoint:point1 toPoint:point2];
            
            tempLabel = [self.timeHourLabelList objectAtIndex:i];
            tempLabel.frame = CGRectMake(CGRectGetMidX(tempLine.frame)-width/2,
                                         CGRectGetMaxY(tempLine.frame)+1,
                                         width, height);
            if (i%4 == 0)//4小时间隔
            {
                tempLabel.hidden = NO;
            }
            else if (i%2 == 0)//2小时间隔
            {
                tempLabel.hidden = self.hourPerPage > SHOW_2HOUR_LABEL_HOUR;
            }
            else
            {
                tempLabel.hidden = self.hourPerPage > SHOW_HOUR_LABEL_HOUR;
            }
            
            tempLine = [self.hourScaleLineList objectAtIndex:i*2+1];
            [self updateVLineWithView:tempLine fromPoint:point3 toPoint:point4];
        }
        else
        {
            tempLine = [self drawHVLineFromPoint:point1 toPoint:point2 color:LINE_DEFAULT_COLOR];
            [self.mainScroll addSubview:tempLine];
            [self.hourScaleLineList addObject:tempLine];
            
            tempLabel = [self drawTimeLabelWithFrame:CGRectMake(CGRectGetMidX(tempLine.frame)-width/2,
                                                                CGRectGetMaxY(tempLine.frame)+1,
                                                                width, height)
                                                text:[NSString stringWithFormat:@"%02d:00",i%24]
                                            fontSize:fontSize
                                           textColor:[UIColor blackColor]];
            if (i%4 == 0)//4小时间隔
            {
                tempLabel.hidden = NO;
            }
            else if (i%2 == 0)//2小时间隔
            {
                tempLabel.hidden = self.hourPerPage > SHOW_2HOUR_LABEL_HOUR;
            }
            else
            {
                tempLabel.hidden = self.hourPerPage > SHOW_HOUR_LABEL_HOUR;
            }
            [self.mainScroll addSubview:tempLabel];
            [self.timeHourLabelList addObject:tempLabel];

            tempLine = [self drawHVLineFromPoint:point3 toPoint:point4 color:LINE_DEFAULT_COLOR];
            [self.mainScroll addSubview:tempLine];
            [self.hourScaleLineList addObject:tempLine];
        }
    }
    
    //上下边沿10分钟刻度
    po = CGRectGetWidth(self.scrollBgView.frame)/(self.hourPerPage*6);
    fontSize = fontSize*0.9;
    width = 4*fontSize;
    height = fontSize;
    maxLineLength *= 0.6;
    for (int i = 0; i < self.dayCount*24*6+1; i ++)
    {
        tempPx = offset+i*po;
        point1 = CGPointMake(tempPx, 0);
        point2 = CGPointMake(tempPx, maxLineLength);
        point3 = CGPointMake(tempPx, bgHeight - maxLineLength);
        point4 = CGPointMake(tempPx, bgHeight);
        if (isUpdate)
        {
            tempLine = [self.min10ScaleLineList objectAtIndex:i*2];
            [self updateVLineWithView:tempLine fromPoint:point1 toPoint:point2];
            tempLine.hidden = self.hourPerPage > SHOW_MIN10_LINE_HOUR;
            
            tempLabel = [self.time10MinLabelList objectAtIndex:i];
            tempLabel.frame = CGRectMake(CGRectGetMidX(tempLine.frame)-width/2,
                                         CGRectGetMaxY(tempLine.frame)+1,
                                         width, height);

            tempLabel.hidden = self.hourPerPage > SHOW_MIN_LABEL_HOUR;
            if (i%6 == 0)//整点上的分钟label不显示
            {
                tempLabel.hidden = YES;
            }
            tempLine = [self.min10ScaleLineList objectAtIndex:i*2+1];
            [self updateVLineWithView:tempLine fromPoint:point3 toPoint:point4];
            tempLine.hidden = self.hourPerPage > SHOW_MIN10_LINE_HOUR;
        }
        else
        {
            tempLine = [self drawHVLineFromPoint:point1 toPoint:point2 color:LINE_DEFAULT_COLOR];
            tempLine.hidden = self.hourPerPage > SHOW_MIN10_LINE_HOUR;
            [self.mainScroll addSubview:tempLine];
            [self.min10ScaleLineList addObject:tempLine];
            
            tempLabel = [self drawTimeLabelWithFrame:CGRectMake(CGRectGetMidX(tempLine.frame)-width/2,
                                                                CGRectGetMaxY(tempLine.frame)+1,
                                                                width, height)
                                                text:[NSString stringWithFormat:@"%02d:%d0",(i/6)%24,i%6]
                                            fontSize:fontSize
                                           textColor:[UIColor blackColor]];
            tempLabel.hidden = self.hourPerPage > SHOW_MIN_LABEL_HOUR;
            if (i%6 == 0)//整点上的分钟label不显示
            {
                tempLabel.hidden = YES;
            }
            [self.mainScroll addSubview:tempLabel];
            [self.time10MinLabelList addObject:tempLabel];
            
            tempLine = [self drawHVLineFromPoint:point3 toPoint:point4 color:LINE_DEFAULT_COLOR];
            tempLine.hidden = self.hourPerPage > SHOW_MIN10_LINE_HOUR;
            [self.mainScroll addSubview:tempLine];
            [self.min10ScaleLineList addObject:tempLine];
        }
    }

    //上下边沿2分钟刻度
    po = CGRectGetWidth(self.scrollBgView.frame)/(self.hourPerPage*30);
    maxLineLength *= 0.6;
    for (int i = 0; i < self.dayCount*24*30+1; i ++)
    {
        tempPx = offset+i*po;
        point1 = CGPointMake(tempPx, 0);
        point2 = CGPointMake(tempPx, maxLineLength);
        point3 = CGPointMake(tempPx, bgHeight - maxLineLength);
        point4 = CGPointMake(tempPx, bgHeight);
        if (isUpdate)
        {
            tempLine = [self.min2ScaleLineList objectAtIndex:i*2];
            [self updateVLineWithView:tempLine fromPoint:point1 toPoint:point2];
            tempLine.hidden = self.hourPerPage > SHOW_MIN2_LINE_HOUR;
            
            tempLine = [self.min2ScaleLineList objectAtIndex:i*2+1];
            [self updateVLineWithView:tempLine fromPoint:point3 toPoint:point4];
            tempLine.hidden = self.hourPerPage > SHOW_MIN2_LINE_HOUR;
        }
        else
        {
            tempLine = [self drawHVLineFromPoint:point1 toPoint:point2 color:LINE_DEFAULT_COLOR];
            tempLine.hidden = self.hourPerPage > SHOW_MIN2_LINE_HOUR;
            [self.mainScroll addSubview:tempLine];
            [self.min2ScaleLineList addObject:tempLine];
            
            tempLine = [self drawHVLineFromPoint:point3 toPoint:point4 color:LINE_DEFAULT_COLOR];
            tempLine.hidden = self.hourPerPage > SHOW_MIN2_LINE_HOUR;
            [self.mainScroll addSubview:tempLine];
            [self.min2ScaleLineList addObject:tempLine];
        }
    }
}

//画垂直或水平的直线,lineColor如为nil 则默认黑色，坐标如不符合水平或垂直则返回nil
- (UIView*) drawHVLineFromPoint:(CGPoint) pointStart toPoint:(CGPoint) pointEnd color:(UIColor *) lineColor
{
    CGFloat width = 0,height = 0;
    if (pointStart.x == pointEnd.x)
    {
        width = LINE_WIDTH;
        height = fabs(pointEnd.y - pointStart.y);
    }
    else if (pointStart.y == pointEnd.y)
    {
        height = LINE_WIDTH;
        width = fabs(pointEnd.x - pointStart.x);
    }
    else
    {
        return nil;
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(pointStart.x, pointStart.y, width, height)];
    if (lineColor)
    {
        lineView.backgroundColor = lineColor;
    }
    else
    {
        lineView.backgroundColor = [UIColor blackColor];
    }
    
    return lineView;
}

- (void) updateVLineWithView:(UIView *) lineView fromPoint:(CGPoint) pointStart toPoint:(CGPoint) pointEnd
{
    if (!lineView)
    {
        return;
    }
    
    CGFloat width = 0,height = 0;
    width = LINE_WIDTH;
    height = fabs(pointEnd.y - pointStart.y);
    lineView.frame = CGRectMake(pointStart.x, pointStart.y, width, height);
}

- (UILabel*) drawTimeLabelWithFrame:(CGRect) frame text:(NSString*) text fontSize:(CGFloat) fontSize textColor:(UIColor *) color
{
    UILabel *destLabel = [[UILabel alloc] initWithFrame:frame];
    destLabel.backgroundColor = [UIColor clearColor];
    destLabel.textAlignment = NSTextAlignmentCenter;
    destLabel.text = text;
    destLabel.font = [UIFont systemFontOfSize:fontSize];
    if (color)
    {
        destLabel.textColor = color;
    }
    
    return destLabel;
}

- (void) clearSubViews
{
    [self removeViewFromList:self.timeHourLabelList];
    [self.timeHourLabelList removeAllObjects];
    
    [self removeViewFromList:self.time10MinLabelList];
    [self.time10MinLabelList removeAllObjects];
    
    [self removeViewFromList:self.recordViewList];
    [self.recordViewList removeAllObjects];
    
    [self removeViewFromList:self.hourScaleLineList];
    [self.hourScaleLineList removeAllObjects];
    
    [self removeViewFromList:self.min10ScaleLineList];
    [self.min10ScaleLineList removeAllObjects];
    
    [self removeViewFromList:self.min2ScaleLineList];
    [self.min2ScaleLineList removeAllObjects];
}

- (void) removeViewFromList:(NSArray *) viewList
{
    for (UIView *view in viewList)
    {
        [view removeFromSuperview];
    }
}

- (void) updateSubviews
{
    [self updateScrollView];
    [self updateTimeScaleLines];
    [self updateRecordViews];
}

- (void) updateRecordViews
{
    [self drawRecordViewsIsUpdate:YES];
}

- (void) updateTimeScaleLines
{
    [self drawsScaleLinesIsUpdate:YES];
}

- (void) updateScrollView
{
    self.mainScrollContentSize = CGSizeMake(CGRectGetWidth(self.mainScroll.frame)*(self.dayCount*24/self.hourPerPage+1),
                                            CGRectGetHeight(self.mainScroll.frame));
    
    //以下2句代码顺序不可掉换，先滚动后修改contentSize，否则会导致部分情况下异常
    [self scrollToTime:self.curTimeOffset animated:NO];
    self.mainScroll.contentSize = self.mainScrollContentSize;
}

#pragma mark - support

- (void) initData
{
    self.needUpdate = NO;
    self.needResponseScroll = YES;
    self.hourPerPage = HOURS_ONE_PAGE;
    self.curTimeOffset = 0;
    self.timeHourLabelList = [NSMutableArray array];
    self.time10MinLabelList = [NSMutableArray array];
    self.recordViewList = [NSMutableArray array];
    self.hourScaleLineList = [NSMutableArray array];
    self.min10ScaleLineList = [NSMutableArray array];
    self.min2ScaleLineList = [NSMutableArray array];
    self.dayCount = 0;
    
    [self initDayCount];
}

- (void) initDayCount
{
    if (self.dataList.count <= 0)
    {
        return;
    }
    
    EZPlaybackInfo *beginInfo = [self.dataList firstObject];
    EZPlaybackInfo *endInfo = [self.dataList lastObject];
    
    self.dayCount = [self dayCountFromDate:beginInfo.beginTime toDate:endInfo.endTime];
    
    //如果无天数，则设置为1
    if (self.dayCount == 0)
    {
        self.dayCount = 1;
    }
}

//计算两个日期间的天数
- (NSInteger) dayCountFromDate:(NSDate *) beginDate toDate:(NSDate*) endDate
{
    //结束时间点早于开始时间点则返回0
    if ([[endDate earlierDate:beginDate] isEqualToDate:endDate])
    {
        return 0;
    }
    
    [self.mFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *beginDay = [self.mFormatter stringFromDate:beginDate];
    NSString *endDay = [self.mFormatter stringFromDate:endDate];
    
    [self.mFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *beginDateZero = [self.mFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",beginDay]];
    NSDate *endDateZero = [self.mFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",endDay]];

    NSTimeInterval interval = [endDateZero timeIntervalSinceDate:beginDateZero];
    
    NSInteger count = interval/(3600*24) + 1;
    
    return count;
}

- (void) createDisplayLink
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayCallback)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void) destroyDisplayLink
{
    if (!self.displayLink)
    {
        return;
    }
    
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void) displayCallback
{
    if (self.pinchRecognizer.state == UIGestureRecognizerStatePossible)
    {
        self.needResponseScroll = YES;
    }
    
    if (!self.needUpdate)
    {
        return;
    }
    
    self.needUpdate = NO;
    [self updateSubviews];
}

- (void) addTouch
{
    self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    self.pinchRecognizer.delegate = self;
    [self.scrollBgView addGestureRecognizer:self.pinchRecognizer];
}

- (void) scrollToTime:(NSTimeInterval) timeOffset animated:(BOOL) animated
{
    CGFloat scrollOffset = [self scrollOffsetOfTime:timeOffset];
    
    [self.mainScroll setContentOffset:CGPointMake(scrollOffset, 0) animated:animated];
    
    self.curTimeOffset = timeOffset;
    [self updateCurDateLabelWithOffset:scrollOffset];
}

- (CGFloat) scrollOffsetOfTime:(NSTimeInterval) timeOffset
{
    CGFloat offsetPerSec = (self.mainScrollContentSize.width - CGRectGetWidth(self.mainScroll.frame))/(self.dayCount*24*3600);
    CGFloat scrollOffset = offsetPerSec * timeOffset;
    return scrollOffset;
}

- (NSTimeInterval) timeOfOffset:(CGFloat) offset
{
    CGFloat offsetPerSec = (self.mainScrollContentSize.width - CGRectGetWidth(self.mainScroll.frame))/(self.dayCount*24*3600);
    NSTimeInterval time = self.mainScroll.contentOffset.x/offsetPerSec;
    
    return time;
}

- (void) scrollEnd
{
    self.needResponseScroll = YES;
    
    NSDate *time = [self.mBeginDate dateByAddingTimeInterval:self.curTimeOffset];
    if (self.delegate && [self.delegate respondsToSelector:@selector(EZPlaybackProgressBarScrollToTime:)])
    {
        [self.delegate EZPlaybackProgressBarScrollToTime:time];
    }
}

- (NSString *) makeCurDateStringWithOffset:(CGFloat) offset
{
    [self.mFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    if (offset <= 0)
    {
        return [self.mFormatter stringFromDate:self.mBeginDate];
    }
    
    CGFloat offsetPerSec = (self.mainScrollContentSize.width - CGRectGetWidth(self.mainScroll.frame))/(self.dayCount*24*3600);
    
    NSDate *curDate = [self.mBeginDate dateByAddingTimeInterval:offset/offsetPerSec];
    
    [self.mFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [self.mFormatter stringFromDate:curDate];
}

@end
