//
//  ViewController.m
//  15puzzle
//
//  Created by 王倩－mac on 16/3/2.
//  Copyright © 2016年 王倩－mac. All rights reserved.
//

#import "ViewController.h"
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height


@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    AVAudioPlayer *player;
}

@end

@implementation ViewController


NSMutableArray *allImgViews;
NSMutableArray *allCenters;
NSMutableDictionary *imagedict;

UILabel *label;

_Bool running = FALSE;
NSTimer *clockTicks;//计时器
NSDate *start_date;
UIImage *theImage;
UIButton *getImageButton;//获取相册图片按钮


- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //显示游戏时间label
    label=[[UILabel alloc] initWithFrame: CGRectMake(10.5, HEIGHT-50, 150, 50)];
    [self.view addSubview:label];
    //label.backgroundColor = [[UIColor alloc] initWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    label.text = @"00:00.00";
    
     getImageButton = [[UIButton alloc]initWithFrame:CGRectMake(200, HEIGHT-50, 80, 50)];
    [self.view addSubview:getImageButton];
    [getImageButton setTitle:@"获取图片" forState:UIControlStateNormal];
    [getImageButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [getImageButton addTarget:self action:@selector(pickTheImage) forControlEvents:UIControlEventTouchUpInside];
    
    allImgViews=[NSMutableArray new];
    allCenters=[NSMutableArray new];
/*大家可以从代码注释的轨迹看到写法历程，最开始用的是具体的数字，认为拼图游戏只能是正方形，之后拓展为长方形*/
//    double xCen=46.875;  //xCen=RectLength/2; RectLength= viewLength/4=192
//     double yCen=46.875;
//    
//    for(int v=0;v<4;v++)
//    {
//        for (int h=0;h<4;h++)
//        {  UIImageView* myImgView=[[UIImageView alloc] initWithFrame: CGRectMake(30,23,93.75,93.75)];
//            
//            CGPoint curCen=CGPointMake(xCen, yCen);
//            [allCenters addObject:[NSValue valueWithCGPoint:curCen]];
//            
//            myImgView.center=curCen;
//            int j=h+v*4+1;
//            myImgView.image=[UIImage imageNamed:[NSString stringWithFormat:@"jc_%02i.jpg", j]];// picture name jc_00.jpg -- jc_15.jpg
//            myImgView.tag=j;
//            //[myImgView.image setAccessibilityIdentifier:(NSString)j];
//            imagedict=[[NSMutableDictionary alloc]initWithCapacity:16];
//            
//            [imagedict setObject: [NSValue valueWithCGPoint:curCen]  forKey:[NSNumber numberWithInt:j]];
//            myImgView.userInteractionEnabled=YES;
//            [allImgViews addObject:myImgView];
//            [self.view addSubview:myImgView];
//            xCen+=93.75;//RectLength
//            
//        }
//        xCen=46.875;
//        yCen+=93.75;
//        
//    }
    //[[allImgViews objectAtIndex:15] isHidden];
     [self createImageViews];
     [[allImgViews objectAtIndex:15] removeFromSuperview];
     [allImgViews removeObjectAtIndex:15];
    if(!allCenters){
        [allCenters removeObjectAtIndex:15];
    }
     [self randomizeBlocks];
     [self playAudio];
}
-(void)getRandom{
    [[allImgViews objectAtIndex:15] removeFromSuperview];
    [allImgViews removeObjectAtIndex:15];
    if(!allCenters)
        [allCenters removeObjectAtIndex:15];
    [self randomizeBlocks];
   // [self playAudio];
}

-(void)pickTheImage{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    theImage = image;
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [allImgViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImageView *img = (UIImageView*)obj;
            [img removeFromSuperview];
        }];
        [allImgViews removeAllObjects];
        [allCenters removeAllObjects];
        [weakSelf createImageViews];
        [weakSelf getRandom];
        if(!player.isPlaying)
          [weakSelf playAudio];
    }];
}

CGFloat itemW,itemH,imageW,imageH;
BOOL hasTransformed;

-(void)createImageViews
{
    UIImage *image;
    if(theImage)
    {
        image = theImage;
    }
    else
    {
        image = [UIImage imageNamed:@"timg.jpg"];
        
    }
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat height1 = image.size.height/width * WIDTH;
    if(height >= width){
        
        if(hasTransformed)
        {
            //要在view原来的Transform的基础上在加上你想要的Transform
            CGAffineTransform transform = self.view.transform;
            self.view.transform = CGAffineTransformRotate(transform, M_PI/2);//CGAffineTransformMakeRotation(M_PI/2);
            self.view.bounds = CGRectMake(0, 0, WIDTH, HEIGHT);
            hasTransformed = NO;
            
            label.frame = CGRectMake(10.5, HEIGHT-50, 150, 50);
            label.font = [UIFont systemFontOfSize:17];
            getImageButton.frame = CGRectMake(200, HEIGHT-50, 80, 50);
            getImageButton.titleLabel.font = [UIFont systemFontOfSize:17];
            
        }
        
        if(height1 >= (HEIGHT - 50))
        {
            height1 = HEIGHT - 50;
            CGFloat realHeight = (HEIGHT - 50)/HEIGHT * height;
            
            image = [self getImageWithImage:image inRect:CGRectMake(0, (height-realHeight)/2, width, realHeight)];
            
        }
        
        width = image.size.width;
        height = image.size.height;

        itemW = WIDTH/4;
        itemH = height1/4;
        imageW = width/4;
        imageH = height/4;
        
      
    }
    else//如果宽度>长度
    {
        if(!hasTransformed){
            self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
            self.view.bounds = CGRectMake(0, 0, HEIGHT, WIDTH);
            hasTransformed = YES;
        }
        
        height1 = image.size.width/height * WIDTH;
        itemW = height1/4;
        itemH = WIDTH/4;
        imageW = width/4;
        imageH = height/4;
        
        //同时更改label和button的位置
        label.frame = CGRectMake(HEIGHT - 50, 40, 50, 30);
        label.font = [UIFont systemFontOfSize:10];
        getImageButton.frame = CGRectMake(HEIGHT-50, 120, 50, 40);
        getImageButton.titleLabel.font = [UIFont systemFontOfSize:10];
      
    }
    
    double xCen = itemW/2;
   
    double yCen=itemH/2;
    
    
    for(int v=0;v<4;v++)
    {
        for (int h=0;h<4;h++)
        {  UIImageView* myImgView=[[UIImageView alloc] initWithFrame: CGRectMake(30,23,itemW,itemH)];
            
            CGPoint curCen=CGPointMake(xCen, yCen);
            [allCenters addObject:[NSValue valueWithCGPoint:curCen]];
            
            myImgView.center=curCen;
            int j=h+v*4+1;
            
            //myImgView.image=[UIImage imageNamed:[NSString stringWithFormat:@"jc_%02i.jpg", j]];// picture name jc_00.jpg -- jc_15.jpg
            myImgView.image = [self getImageWithImage:image inRect:CGRectMake(0+imageW * h, 0+imageH*v,imageW, imageH)];
            myImgView.tag=j;
            myImgView.clipsToBounds = YES;
            //[myImgView.image setAccessibilityIdentifier:(NSString)j];
            imagedict=[[NSMutableDictionary alloc]initWithCapacity:16];
            
            [imagedict setObject: [NSValue valueWithCGPoint:curCen]  forKey:[NSNumber numberWithInt:j]];
            myImgView.userInteractionEnabled=YES;
            [allImgViews addObject:myImgView];
            [self.view addSubview:myImgView];
            xCen+=itemW;//93.75;//RectLength
            
        }
        xCen= itemW/2;//46.875;
        yCen+=itemH;//93.75;
        
    }
    
}

-(void)playAudio
{
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"extraordinary" ofType:@"mp3"];
    
    NSURL *soundFileURL=[NSURL fileURLWithPath:soundFilePath];
    
    player=[[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    player.numberOfLoops=-1; //Infinite
    [player setVolume:0.5];
    [player play];


}
-(void)stopPlayAudio{

    [player stop];
}

CGPoint emptySpot;
NSMutableArray* keyArray;
- (void)randomizeBlocks
{
    NSMutableArray* centersCopy=[allCenters mutableCopy];
    
    
    int randLocInt;
    CGPoint randLoc;
    
    for(UIView* any in allImgViews)
    {
        
        randLocInt=arc4random()%centersCopy.count;
        randLoc=[[centersCopy objectAtIndex:randLocInt] CGPointValue];
        any.center=randLoc;
        [centersCopy removeObjectAtIndex: randLocInt];
        
    }
    emptySpot=[[centersCopy objectAtIndex:0] CGPointValue];
    [self ifIsSolvable];
    
    
    
}

- (UIImage *)CutImageWithImage:(UIImage *)image withRect:(CGRect)rect
{
    //使用CGImageCreateWithImageInRect方法切割图片，第一个参数为CGImage类型，第二个参数为要切割的CGRect
    CGImageRef cutImage = CGImageCreateWithImageInRect(image.CGImage, rect);
    //将切割出得图片转换为UIImage
    UIImage *resultImage = [UIImage imageWithCGImage:cutImage];
    return resultImage;
}

    
    

#pragma mark 判断4*4的拼图游戏是否能成功拼成
bool isSolvable;
-(bool)ifIsSolvable{
    keyArray=[[NSMutableArray alloc] initWithCapacity:15];
    for(int b=0;b<15;b++){
        [keyArray addObject:[NSNumber numberWithInt:1]];
    }
    NSMutableArray* keyArrayCopy=[keyArray mutableCopy];
    NSMutableArray* allCentersCopy=[allCenters mutableCopy];
    for (int c=0;c<allCentersCopy.count;c++){
        
        if(CGPointEqualToPoint(emptySpot, [[allCentersCopy objectAtIndex:c]CGPointValue]))
            [allCentersCopy removeObjectAtIndex:c];
        
    }
    
    int count1=0;
    
    for(UIView* any in allImgViews)
    {
        for(int a=0;a<allCentersCopy.count;){
            BOOL isEqual=CGPointEqualToPoint(any.center, [[allCentersCopy objectAtIndex:a]CGPointValue]);
            
            if(!isEqual) a++;
            else {
                
                [keyArrayCopy replaceObjectAtIndex:a withObject:[NSNumber numberWithInt:count1+1]];
                break;
                
                
            }
            
            
        }
        count1++;
    }
    NSLog(@"keyArrayCopy:%@", keyArrayCopy);
          
          
          
          int k;
    
          k = emptySpot.y/(itemH/2);
          NSLog(@"k=%i",k);
          
          
          int m=0;
          
          for(int i=0;i<keyArrayCopy.count;i++)
          {
              for(int j=i+1;j<keyArrayCopy.count;j++){
                  
                  if([[keyArrayCopy objectAtIndex:i]intValue]> [[keyArrayCopy objectAtIndex:j]intValue])
                  {
                      m++;
                      
                  }
              }
            
          }
          NSLog(@"m=%i",m);
          bool isSolvable=((k==3||k==7)&&m%2==0)||((k==1||k==5)&&m%2!=0);
    if (isSolvable==false){
            [self randomizeBlocks];
    }
          return isSolvable;
    
}

CGPoint tapCen;
CGPoint left;
CGPoint right;
CGPoint top;
CGPoint bottom;

bool leftIsEmpty, rightIsEmpty, topIsEmpty, bottomIsEmpty;
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(nullable UIEvent *)event{
    UITouch* firstTouch=[[touches allObjects] objectAtIndex:0];
    if(firstTouch.view==self.view)
    {
    
    
        start_date = [NSDate date];
        clockTicks = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0
                                                      target:self
                                                    selector:@selector(updateTimer)
                                                    userInfo:nil
                                                     repeats:YES];
    
        
        if (clockTicks == nil) {
            clockTicks = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0
                                                          target:self
                                                        selector:@selector(updateTimer)
                                                        userInfo:nil
                                                         repeats:YES];
        }
 
   
    }

 
};

*/
-(BOOL)isCGPointsEqual :(CGPoint)point1 withNew : (CGPoint)point2
{
    BOOL isEqual = CGPointEqualToPoint(point1, point2);
    return isEqual;
//    NSString *point1X = [NSString stringWithFormat:@"%.2f",point1.x];
//    NSString *point2X = [NSString stringWithFormat:@"%.2f",point2.x];
//    NSString *point1Y = [NSString stringWithFormat:@"%.2f",point1.y];
//    NSString *point2Y = [NSString stringWithFormat:@"%.2f",point2.y];
//    if([point1X isEqualToString:point2X] && [point1Y isEqualToString:point2Y])
//    {
//        return YES;
//    }
//    else
//        return NO;
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* myTouch=[[touches allObjects] objectAtIndex:0];
    
    if(myTouch.view!=self.view)
    {
        tapCen=myTouch.view.center;
       
        
//        left=CGPointMake(tapCen.x - 93.75, tapCen.y);
//        right=CGPointMake(tapCen.x+93.75, tapCen.y);
//        top=CGPointMake(tapCen.x, tapCen.y+93.75);
//        bottom=CGPointMake(tapCen.x, tapCen.y-93.75);
        
        left=CGPointMake(tapCen.x - itemW, tapCen.y);
        right=CGPointMake(tapCen.x+itemW, tapCen.y);
        top=CGPointMake(tapCen.x, tapCen.y-itemH);
        bottom=CGPointMake(tapCen.x, tapCen.y+itemH);
        

         leftIsEmpty = [self isCGPointsEqual:left withNew:emptySpot];
         rightIsEmpty = [self isCGPointsEqual:right withNew:emptySpot];
         topIsEmpty = [self isCGPointsEqual:top withNew:emptySpot];
         bottomIsEmpty = [self isCGPointsEqual:bottom withNew:emptySpot];
       
        if(leftIsEmpty||rightIsEmpty||bottomIsEmpty||topIsEmpty)
        {
            
            if(!running){
            start_date = [NSDate date];
            clockTicks = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0
                                                          target:self
                                                        selector:@selector(updateTimer)
                                                        userInfo:nil
                                                         repeats:YES];
                running = true ;
            }
            
            [UIView beginAnimations:Nil context:NULL];
            [UIView setAnimationDuration:.5];
            
            myTouch.view.center = emptySpot;
            [UIView commitAnimations];
            
            emptySpot=tapCen;
            leftIsEmpty=false; rightIsEmpty=false; topIsEmpty=false; bottomIsEmpty=false;
            
        }
        
        
        int i=0; int count=0;
        for (UIView* any in allImgViews)
        {
            if(CGPointEqualToPoint(any.center, [[allCenters objectAtIndex:i]CGPointValue]))
               {count++;
               }
            
            i++;
        }
        
        if(count==15){
            
            [clockTicks invalidate];
           
            [self performSelector:@selector(showDialog) withObject:nil afterDelay:1.0];
            [self performSelector:@selector(stopPlayAudio) withObject:nil afterDelay:1.0];
            
            
            
        }
        
        
    }

}





-(void)updateTimer{
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:start_date];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss.SS"];//@"HH:mm:ss.SS"
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    label.text=timeString;
}

/*拼图成功后的提示框*/
-(void)showDialog{
    
    UIView* fullScreenView = [[UIView alloc]init];
    fullScreenView.tag=101;
    fullScreenView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.5];
    fullScreenView.frame=self.view.window.frame;
    [self.view.window addSubview:fullScreenView];
    
    UIView* dialogView = [[UIView alloc]init];
    dialogView.frame=CGRectMake(0, 100, 375, 260);
    dialogView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.5];
    //dialogView.center=fullScreenView.center;
    [fullScreenView addSubview:dialogView];
    
    UILabel* winLabel=[[UILabel alloc] initWithFrame: CGRectMake((dialogView.frame.size.width-200)/2, (dialogView.frame.size.height-150)/2, 250, 30)];
    winLabel.textColor=[[UIColor greenColor] colorWithAlphaComponent:1.0];
    [dialogView addSubview:winLabel];
    winLabel.text = @"You Won! Congratulations!";
    
    
    UILabel* timeLabel=[[UILabel alloc] initWithFrame: CGRectMake((dialogView.frame.size.width-100)/2, (dialogView.frame.size.height-100)/2, 100, 30)];
    timeLabel.textColor=[[UIColor yellowColor] colorWithAlphaComponent:1.0];
    [dialogView addSubview:timeLabel];
    timeLabel.text = label.text;

    UIButton* btnClose=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    btnClose.frame=CGRectMake((dialogView.frame.size.width-100)/2, (dialogView.frame.size.height-30)/2, 100, 30);
    [btnClose addTarget:self action:@selector(closeDialog:) forControlEvents:UIControlEventTouchUpInside];
    [dialogView addSubview:btnClose];
    
}
-(void)closeDialog:(UIButton*)sender{
    [[self.view.window viewWithTag:101]removeFromSuperview];
}

#pragma mark - 等分裁剪图片
-(UIImage *)getImageWithImage:(UIImage *)image inRect:(CGRect) rect
{
    CGImageRef old = [image CGImage];
    CGImageRef imgeRef = CGImageCreateWithImageInRect(old,rect);
    UIImage *new = [UIImage imageWithCGImage:imgeRef];
    CGImageRelease(imgeRef);
    return new;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end


