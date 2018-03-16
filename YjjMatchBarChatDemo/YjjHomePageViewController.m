//
//  YjjHomePageViewController.m
//  YjjMatchBarChatDemo
//
//  Created by YjjTT on 2018/3/16.
//  Copyright © 2018年 YjjTT. All rights reserved.
//

#import "YjjHomePageViewController.h"
#import "MatchBarChat/MatchBarChatView.h"

@interface YjjHomePageViewController () <MatchBarChatDelegate>

@property (nonatomic, strong) NSArray *array;

@end

@implementation YjjHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _array = @[@[@13,@11], @[@22,@5], @[@3, @7], @[@13, @33], @[@15, @1], @[@1, @31], @[@21, @6], @[@12, @11], @[@15, @21], @[@0, @0]];
    
    MatchBarChatView *matchView = [[MatchBarChatView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 400) array:_array];
    matchView.delegate = self;
    matchView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:matchView];
}

#pragma mark - MatchBarChatDelegate small Ball Click
- (void)didSelectedBallAtIndex:(NSInteger)index{
    NSLog(@"点击了第%zd个小球",index);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
