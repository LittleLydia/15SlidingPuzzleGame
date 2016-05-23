//
//  ViewController.m
//  15puzzle
//
//  Created by 王倩－mac on 16/3/2.
//  Copyright © 2016年 王倩－mac. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()
   /* IBOutlet UIButton *startButton;
    IBOutlet UIButton *resetButton;
    */
    


@end

@implementation ViewController


NSMutableArray *allImgViews;
NSMutableArray *allCenters;
NSMutableDictionary *imagedict;

UILabel *label;

_Bool running = FALSE;
//bool paused=FALSE;
NSTimer *clockTicks;
NSDate *start_date;
//NSDate *pause_date;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yellowbg.jpg"]];
    backgroundImage.alpha=1.0;
    backgroundImage.frame=self.view.frame;
    [self.view addSubview:backgroundImage];
    label=[[UILabel alloc] initWithFrame: CGRectMake(10.5, 495, 200, 50)];
    [self.view addSubview:label];
    label.text = @"00:00:00.00";
 
    
    

    /*
    startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];         //边框设置
    startButton.frame=CGRectMake(10,475,40,30);                                   //位置及大小
    startButton.backgroundColor = [UIColor clearColor];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];//按钮的提示字
    [startButton setEnabled:true];
    startButton.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];           //设置字体大小
    //设置背景图片
    [self.view addSubview:startButton];
    [startButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
     resetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];         //边框设置
    resetButton.frame = CGRectMake(50, 475, 50, 30);                                   //位置及大小
    resetButton.backgroundColor = [UIColor clearColor];
    [resetButton setTitle:@"Pause" forState:UIControlStateNormal];                      //按钮的提示字
   [resetButton setEnabled:false];
    resetButton.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];           //设置字体大小
 
    [self.view addSubview:resetButton];
    [resetButton addTarget:self action:@selector(stop:)
          forControlEvents:UIControlEventTouchUpInside];
    */
    
    UIImageView* completeImgView=[[UIImageView alloc] initWithFrame: CGRectMake(110,450,220,160)];
    completeImgView.image=[UIImage imageNamed:[NSString stringWithFormat:@"famous.jpg"]];
    [self.view addSubview:completeImgView];
    
    allImgViews=[NSMutableArray new];
    allCenters=[NSMutableArray new];
    
    double xCen=46.875;  //xCen=RectLength/2; RectLength= viewLength/4=192
     double yCen=46.875;
    
    for(int v=0;v<4;v++)
    {
        for (int h=0;h<4;h++)
        {  UIImageView* myImgView=[[UIImageView alloc] initWithFrame: CGRectMake(30,23,93.75,93.75)];
            
            CGPoint curCen=CGPointMake(xCen, yCen);
            [allCenters addObject:[NSValue valueWithCGPoint:curCen]];
            
            myImgView.center=curCen;
            int j=h+v*4+1;
            myImgView.image=[UIImage imageNamed:[NSString stringWithFormat:@"jc_%02i.jpg", j]];// picture name jc_00.jpg -- jc_15.jpg
            myImgView.tag=j;
            //[myImgView.image setAccessibilityIdentifier:(NSString)j];
            imagedict=[[NSMutableDictionary alloc]initWithCapacity:16];
            
            [imagedict setObject: [NSValue valueWithCGPoint:curCen]  forKey:[NSNumber numberWithInt:j]];
            myImgView.userInteractionEnabled=YES;
            [allImgViews addObject:myImgView];
            [self.view addSubview:myImgView];
            xCen+=93.75;//RectLength
            
        }
        xCen=46.875;
        yCen+=93.75;
        
    }
    //[[allImgViews objectAtIndex:15] isHidden];
    [[allImgViews objectAtIndex:15] removeFromSuperview];
    [allImgViews removeObjectAtIndex:15];
    if(!allCenters){
        [allCenters removeObjectAtIndex:15];}
    
    
    [self randomizeBlocks];
    
    
}

CGPoint emptySpot;
- (void)randomizeBlocks
{
    NSMutableArray* centersCopy=[allCenters mutableCopy];
    NSMutableArray* keyArray=[[NSMutableArray alloc] initWithCapacity:15];
    int randLocInt;
    CGPoint randLoc;
    
    for(UIView* any in allImgViews)
    {
        
        randLocInt=arc4random()%centersCopy.count;
        randLoc=[[centersCopy objectAtIndex:randLocInt] CGPointValue];
        //[keyArray addObject:[NSNumber numberWithInt:randLocInt]];
        //NSLog(@"keyArray:%@", keyArray);
        any.center=randLoc;
        //NSLog(@"%li",(long)any.tag);
        [centersCopy removeObjectAtIndex: randLocInt];
        
    }
    
    
    for(UIView* imageView in self.view.subviews){
        if(imageView.tag>=1&&imageView.tag<=15){
        
            [keyArray addObject:[NSNumber numberWithInt:imageView.tag]];
        
        }
    
    }
    NSLog(@"keyArray:%@", keyArray);
    
    int k;
    //k=[[keyArray lastObject]intValue]
    //[keyArray removeLastObject];
    emptySpot=[[centersCopy objectAtIndex:0] CGPointValue];
    k=emptySpot.y/46.975;
    int m=0;
    
    for(int i=0;i<keyArray.count;i++)
    {
        for(int j=i+1;j<keyArray.count;j++){
            
            if([[keyArray objectAtIndex:i]intValue]> [[keyArray objectAtIndex:j]intValue]){
                 m++;
            
            
            }
            
                
                
                }
        
    
    }
    NSLog(@"%i",m);
    //BOOL isSolvable=((int)k%2==0&&m%2==0)||((int)k%2!=0&&m%2!=0);
    if(((k==3||k==7)&&m%2!=0)||((k==1||k==5)&&m%2==0))
  {
        [self randomizeBlocks];
    
    }
    
    
    
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

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* myTouch=[[touches allObjects] objectAtIndex:0];
    
    if(myTouch.view!=self.view)
    {
        tapCen=myTouch.view.center;
        
        left=CGPointMake(tapCen.x - 93.75, tapCen.y);
        right=CGPointMake(tapCen.x+93.75, tapCen.y);
        top=CGPointMake(tapCen.x, tapCen.y+93.75);
        bottom=CGPointMake(tapCen.x, tapCen.y-93.75);
        
        if([[NSValue valueWithCGPoint:left] isEqual: [NSValue valueWithCGPoint:emptySpot]])  leftIsEmpty= true;
        
        if([[NSValue valueWithCGPoint:right] isEqual: [NSValue valueWithCGPoint:emptySpot]])  rightIsEmpty= true;
        
        if([[NSValue valueWithCGPoint:top] isEqual: [NSValue valueWithCGPoint:emptySpot]])  topIsEmpty= true;
        
        if([[NSValue valueWithCGPoint:bottom] isEqual: [NSValue valueWithCGPoint:emptySpot]])  bottomIsEmpty= true;
        
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
            
            myTouch.view.center=emptySpot;
            
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
            clockTicks.invalidate;
            
            [self showDialog];
        }
        
         
       
        /*if([allImgViews isEqual:allCenters]){
         [self showDialog];
        
        }
        BOOL youwon;
        int j=0;
        for(UIView* any in allImgViews){
            youwon=CGPointEqualToPoint(any.center, [[allCenters objectAtIndex:j]CGPointValue]);
            
            
            if(youwon==false)
            {
                break;
            }
                
                
                clockTicks.invalidate;
                
                
         [self showDialog];
            
            
            
       
        
        }
        
     */
        
    }

}





-(void)updateTimer{
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:start_date];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    label.text=timeString;
}


-(void)showDialog{
    
    UIView* fullScreenView = [[UIView alloc]init];
    fullScreenView.tag=101;
    fullScreenView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.5];
    //fullScreenView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:0.0];
    //fullScreenView.backgroundColor=[UIColor colorWithWhite:(CGFloat)1.0 alpha:(CGFloat)0.5];
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
    [btnClose setTitle:@"close" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    btnClose.frame=CGRectMake((dialogView.frame.size.width-100)/2, (dialogView.frame.size.height-30)/2, 100, 30);
    [btnClose addTarget:self action:@selector(closeDialog:) forControlEvents:UIControlEventTouchUpInside];
    [dialogView addSubview:btnClose];
    
}
-(void)closeDialog:(UIButton*)sender{
    [[self.view.window viewWithTag:1013]removeFromSuperview];
}

/*-(void)click:(UIButton *)startButton{
    if(!running){
        paused=false;
        start_date = [NSDate date];
        
        [startButton setTitle:@"Stop" forState:UIControlStateNormal];
        
        [resetButton setTitle:@"Pause" forState:UIControlStateNormal];
        [resetButton setEnabled:true];
        
        if (clockTicks == nil) {
            clockTicks = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0
                                                         target:self
                                                       selector:@selector(updateTimer)
                                                       userInfo:nil
                                                        repeats:YES];
        }
        
      }else{
       
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
        [startButton setEnabled:true];
          [resetButton setTitle:@"Pause" forState:UIControlStateNormal];
          [resetButton setEnabled:false];
          [clockTicks invalidate];
          clockTicks = nil;
        
    }
    
    running = !running;
}
 

-(void)stop:(UIButton *)resetButton{
        if(!paused){
            [resetButton setTitle:@"Resume" forState:UIControlStateNormal];
            [resetButton setEnabled:true];
            [startButton setTitle:@"Stop" forState:UIControlStateNormal];
            [startButton setEnabled:true];
            [clockTicks invalidate];
            clockTicks=nil;
            pause_date=[NSDate date];
            
        }
        else{
            NSTimeInterval secondsbetween= [pause_date timeIntervalSinceDate:start_date];
            start_date=[NSDate dateWithTimeIntervalSinceNow:(-1)*secondsbetween];
            
            [resetButton setTitle:@"Pause" forState:UIControlStateNormal];
            [resetButton setEnabled:true];
            [startButton setTitle:@"Stop" forState:UIControlStateNormal];
            [startButton setEnabled:false];
            if (clockTicks == nil) {
                clockTicks = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0
                                                              target:self
                                                            selector:@selector(updateTimer)
                                                            userInfo:nil
                                                             repeats:YES];
            }
        }
        
        paused = !paused;
    }

 */
    


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end


