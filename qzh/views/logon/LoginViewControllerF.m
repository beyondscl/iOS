//
//  LoginViewController.m
//  WebViews
//
//  Created by xianming on 2018/3/13.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginViewControllerF.h"
#import "LoginViewController.h"
#import "RegisterVC.h"
#import "GameVC.h"


#define kScreen_height [UIScreen mainScreen].bounds.size.height
#define kScreen_width [UIScreen mainScreen].bounds.size.width

#import "Logon.h"

@interface LoginViewControllerF ()<UINavigationControllerDelegate>{
    UIView *_view;
    CGRect _vFrame;
    UITextField *_email;
    UITextField *_passwd;
    UILabel *_loginLeb;
    UIImageView *_infoView;
}
@end



@implementation LoginViewControllerF

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    self.navigationController.navigationBarHidden = YES;

    [self hbo_loggin];
}

#pragma mark 去掉导航栏
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark addView
//第一次登陆的界面
- (void)hbo_loggin
{
    float navHeight = 0.0f;
    _vFrame = CGRectMake(0, navHeight, kScreen_width, kScreen_height);
    
    //邮箱和密码背景颜色设置
    _view = [[UIView alloc] initWithFrame:_vFrame];
    _view.layer.cornerRadius = 1.0;
    _view.layer.borderWidth = 0.1;
    _view.layer.backgroundColor = [UIColor colorWithRed:205/255.0f green:203/255.0f blue:202/255.0f alpha:1.0f].CGColor;
    [self.view addSubview:_view];
    
    //背景
    UIImage *bg =[UIImage imageNamed:@"loading1.jpg"];
    UIImageView *bgView = [[UIImageView alloc]initWithImage:bg];
    bgView.frame = CGRectMake(0, 0, kScreen_width, kScreen_height);
    [_view addSubview:bgView];
    
    //游客登陆
    UIImage *imgDl =[UIImage imageNamed:@"youkedenglu.png"];
    UIImageView *imgDLView = [[UIImageView alloc]initWithImage:imgDl];
    imgDLView.frame = CGRectMake(kScreen_width/4-5, kScreen_height/3*2, kScreen_width/4, imgDLView.frame.size.width/5);
    [_view addSubview:imgDLView];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hbo_ykBtn:)];
    [imgDLView addGestureRecognizer:tapGesture];
    imgDLView.userInteractionEnabled = YES;
    
    //账号登陆
    UIImage *imgDl3 =[UIImage imageNamed:@"zhanghaodenglu.png"];
    UIImageView *imgDLView3 = [[UIImageView alloc]initWithImage:imgDl3];
    imgDLView3.frame = CGRectMake(kScreen_width/2+5, kScreen_height/3*2, kScreen_width/4, imgDLView3.frame.size.width/5);
    [_view addSubview:imgDLView3];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hbo_zhBtn:)];
    [imgDLView3 addGestureRecognizer:tapGesture2];
    imgDLView3.userInteractionEnabled = YES;
    
    //注册
    float imgDLView5W = kScreen_width/4-30-30;
    float imgDLView5PW = imgDLView3.frame.origin.x+imgDLView3.frame.size.width+10;
    
    UIImage *imgDl5 =[UIImage imageNamed:@"zhuce1.png"];
    UIImageView *imgDLView5 = [[UIImageView alloc]initWithImage:imgDl5];
    imgDLView5.frame = CGRectMake(imgDLView5PW,
                                  imgDLView3.frame.origin.y+imgDLView3.frame.size.height,
                                  imgDLView5W, imgDLView5W/3);
    [_view addSubview:imgDLView5];
    
    UITapGestureRecognizer *tapGesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hbo_registBtn:)];
    [imgDLView5 addGestureRecognizer:tapGesture3];
    imgDLView5.userInteractionEnabled = YES;

}
//游客按钮
-(void)hbo_ykBtn: (UIButton *)sender{
    NSLog(@"hbo_ykBtn click");
    NSDictionary *d = [Logon hbo_touSignin];
    NSString *code = [d objectForKey:@"code"];
    if(0==code.intValue){
        GameVC *gameVC = [[GameVC alloc]initWithInfo:d];
        [self.navigationController pushViewController:gameVC animated:YES];
        return;
    }
}
//账号按钮
-(void)hbo_zhBtn: (UIButton *)sender{
    LoginViewController *loginVc = [LoginViewController new];
    [self.navigationController pushViewController:loginVc animated:NO];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
//注册按钮
-(void)hbo_registBtn: (UIButton *)sender{
    RegisterVC *registVc = [[RegisterVC alloc]init];
    [self.navigationController pushViewController:registVc animated:NO];
    NSLog(@"regisBtn click");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

