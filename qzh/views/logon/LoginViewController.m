//
//  LoginViewController.m
//  WebViews
//
//  Created by xianming on 2018/3/13.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginViewController.h"


#define kScreen_height [UIScreen mainScreen].bounds.size.height
#define kScreen_width [UIScreen mainScreen].bounds.size.width

#import "Logon.h"
#import "GameVC.h"
#import "RegisterVC.h"
#import "FindPasswordVC.h"

@interface LoginViewController ()<UITextFieldDelegate,UINavigationControllerDelegate>{
    UIView *_view;
    CGRect _vFrame;
    UITextField *_email;
    UITextField *_passwd;
    UILabel *_loginLeb;
    UIImageView *_infoView;
}
    @end



@implementation LoginViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    self.navigationController.navigationBarHidden = YES;

    //键盘
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hbo_keyboardHide:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self hbo_loggin2];
}
    
-(void)hbo_keyboardHide:(UITapGestureRecognizer*)tap{
    [_email resignFirstResponder];
    [_passwd resignFirstResponder];
}
    
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
    
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
    
    //账号登陆界面
- (void)hbo_loggin2
    {
        float navHeight = 0.0f;
        UIFont *lpFont = [UIFont boldSystemFontOfSize:16];
        _vFrame = CGRectMake(0, navHeight, kScreen_width, kScreen_height);
        
        //邮箱和密码背景颜色设置
        _view = [[UIView alloc] initWithFrame:_vFrame];
        [self.view addSubview:_view];
        
        //背景1
        UIImage *bg =[UIImage imageNamed:@"loading1.jpg"];
        UIImageView *bgView = [[UIImageView alloc]initWithImage:bg];
        bgView.frame = CGRectMake(0, 0, kScreen_width, kScreen_height);
        bgView.alpha = 0.4;
        [_view addSubview:bgView];
        //背景2
        UIImage *bg2 =[UIImage imageNamed:@"dengludi.png"];
        UIImageView *bgView2 = [[UIImageView alloc]initWithImage:bg2];
        bgView2.frame = CGRectMake(0, kScreen_height/5, kScreen_width, kScreen_height/5*3);
        [_view addSubview:bgView2];
        
        //内容框的总高度
        float contentHeight = bgView2.frame.size.height;
        //内容开始高度：内容总共有3个。那么分成5份，第二份开始
        float startH =bgView2.frame.origin.y+contentHeight/5;
        
        
        //返回
        UIImage *back =[UIImage imageNamed:@"fanhui.png"];
        UIImageView *bkView2 = [[UIImageView alloc]initWithImage:back];
        bkView2.frame = CGRectMake(kScreen_width/10, bgView2.frame.origin.y+5, 35, 35);
        //    bkView2.frame = CGRectMake(kScreen_width/10, kScreen_height/10, 35, 35);
        [_view addSubview:bkView2];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hbo_backBtn:)];
        [bkView2 addGestureRecognizer:tapGesture];
        bkView2.userInteractionEnabled = YES;
        
        //提示框
        UIImage *info =[UIImage imageNamed:@"tishikuang.png"];
        _infoView = [[UIImageView alloc]initWithImage:info];
        _infoView.frame = CGRectMake(kScreen_width/4, bgView2.frame.origin.y-30, kScreen_width/2, 20);
        _infoView.hidden = YES;
        [_view addSubview:_infoView];
        
        _loginLeb = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_width/4, bgView2.frame.origin.y-30, kScreen_width/2, 20)];
        _loginLeb.hidden = YES;
        [_view addSubview:_loginLeb];
        
        //用户名
        UIImage *namePassDi =[UIImage imageNamed:@"di3.png"];
        UIImageView *namePassDiView = [[UIImageView alloc]initWithImage:namePassDi];
        namePassDiView.frame = CGRectMake(kScreen_width/4, startH, kScreen_width/2, 47);
        [_view addSubview:namePassDiView];
        
        UIImage *yhm =[UIImage imageNamed:@"shuruzhanghao.png"];
        UIImageView *yhmView = [[UIImageView alloc]initWithImage:yhm];
        yhmView.frame = CGRectMake(namePassDiView.frame.origin.x+4, namePassDiView.frame.origin.y+4, 32, 39);
        [_view addSubview:yhmView];
        //密码
        UIImage *namePassDi2 =[UIImage imageNamed:@"di3.png"];
        UIImageView *namePassDiView2 = [[UIImageView alloc]initWithImage:namePassDi2];
        namePassDiView2.frame = CGRectMake(kScreen_width/4, yhmView.frame.origin.y+yhmView.frame.size.height+ 10, kScreen_width/2, 47);
        [_view addSubview:namePassDiView2];
        
        UIImage *ma =[UIImage imageNamed:@"mima.png"];
        UIImageView *maView = [[UIImageView alloc]initWithImage:ma];
        maView.frame = CGRectMake(namePassDiView2.frame.origin.x+4, namePassDiView2.frame.origin.y+4, 32, 39);
        [_view addSubview:maView];
        
        //登陆
        UIImage *imgDl2 =[UIImage imageNamed:@"denglu.png"];
        UIImageView *imgDLView2 = [[UIImageView alloc]initWithImage:imgDl2];
        imgDLView2.frame = CGRectMake(kScreen_width/2-kScreen_width/8+20, maView.frame.origin.y+maView.frame.size.height+10, kScreen_width/4-40, imgDLView2.frame.size.width/5);
        [_view addSubview:imgDLView2];
        
        UITapGestureRecognizer *hbo_loginBtn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hbo_loginBtn:)];
        [imgDLView2 addGestureRecognizer:hbo_loginBtn];
        imgDLView2.userInteractionEnabled = YES;
        
        
        
        //忘记密码
        UIImage *imgWJ =[UIImage imageNamed:@"wangjimima.png"];
        UIImageView *imgWJView = [[UIImageView alloc]initWithImage:imgWJ];
        imgWJView.frame = CGRectMake(kScreen_width/2, bgView2.frame.origin.y+bgView2.frame.size.height+10, kScreen_width/4-40, imgWJView.frame.size.width/4);
        
        
        UITapGestureRecognizer *hbo_getPassBtn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hbo_getPassBtn:)];
        [imgWJView addGestureRecognizer:hbo_getPassBtn];
        imgWJView.userInteractionEnabled = YES;
        
        [_view addSubview:imgWJView];
        //注册账号
        UIImage *imgZC =[UIImage imageNamed:@"zhucezhanghao.png"];
        UIImageView *imgZC1 = [[UIImageView alloc]initWithImage:imgZC];
        imgZC1.frame = CGRectMake(imgWJView.frame.origin.x+imgWJView.frame.size.width+10, imgWJView.frame.origin.y, kScreen_width/4-40, imgZC1.frame.size.width/4);
        
        
        UITapGestureRecognizer *hbo_registBtn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hbo_registBtn:)];
        [imgZC1 addGestureRecognizer:hbo_registBtn];
        imgZC1.userInteractionEnabled = YES;
        
        [_view addSubview:imgZC1];
        
        
        //用户名或邮箱，只允许手机号码注册！
        _email = [[UITextField alloc] initWithFrame:CGRectMake(yhmView.frame.origin.x+yhmView.frame.size.width+5,
                                                               yhmView.frame.origin.y,
                                                               namePassDiView2.frame.size.width-maView.frame.size.width-10,
                                                               yhmView.frame.size.height)];
        _email.layer.borderWidth =0;
        _email.layer.cornerRadius = 8.0;
        //    [_email setKeyboardType:UIKeyboardTypeEmailAddress];
        [_email setKeyboardType:UIKeyboardTypeNumberPad];
        [_email setTextColor:[UIColor whiteColor]];
        //[_email setClearButtonMode:UITextFieldViewModeWhileEditing]; //编辑时会出现个修改X
        [_email setTag:101];
        [_email setReturnKeyType:UIReturnKeyNext]; //键盘下一步Next
        [_email setAutocapitalizationType:UITextAutocapitalizationTypeNone]; //关闭首字母大写
        [_email setAutocorrectionType:UITextAutocorrectionTypeNo];
//        [_email becomeFirstResponder]; //默认打开键盘
        [_email setFont:[UIFont systemFontOfSize:17]];
        [_email setDelegate:self];
        [_email setPlaceholder:@"请输入手机号"];
        [_email setText:@""];
        [_email setFont:lpFont];
        
        [_email setTextColor:[UIColor blackColor]];
        [_email setHighlighted:YES];
        [_view addSubview:_email];
        //密码
        _passwd = [[UITextField alloc] initWithFrame:CGRectMake(maView.frame.origin.x+maView.frame.size.width+5,
                                                                maView.frame.origin.y,
                                                                namePassDiView.frame.size.width-yhmView.frame.size.width-10,
                                                                maView.frame.size.height)];
        _passwd.layer.borderWidth =0;
        _passwd.layer.cornerRadius = 8.0;
        [_passwd setBackgroundColor:[UIColor clearColor]];
        [_passwd setKeyboardType:UIKeyboardTypeDefault];
        [_passwd setBorderStyle:UITextBorderStyleNone];
        [_passwd setAutocapitalizationType:UITextAutocapitalizationTypeNone]; //关闭首字母大写
        [_passwd setReturnKeyType:UIReturnKeyDone]; //完成
        [_passwd setSecureTextEntry:YES]; //验证
        [_passwd setDelegate:self];
        [_passwd setTag:102];
        [_passwd setTextColor:[UIColor blackColor]];
        [_passwd setText:@""];
        [_passwd setPlaceholder:@"请输入密码"];
        [_view addSubview:_passwd];
        
    }
    //返回按钮
-(void)hbo_backBtn: (UIButton *)sender{
    NSLog(@"hbo_backBtn click");
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)regisBtn: (UIButton *)sender{
    NSLog(@"regisBtn click");
}
    //登陆按钮
-(void)hbo_loginBtn: (UIButton *)sender{
    NSLog(@"regisBtn click");
    if ([@"" isEqualToString:_email.text]) {
        [self hbo_showMsg:@"请输入手机号"];
        return;
    }
    if ([@"" isEqualToString:_passwd.text]) {
        [_loginLeb setTextColor:[UIColor redColor]];
        [self hbo_showMsg:@"请输入密码"];
        return;
    }
    [self hbo_hiddenMsg];
    NSDictionary *d = [Logon hbo_dfSignin:_email.text password:_passwd.text];
    NSString *code = [d objectForKey:@"code"];
    if(0==code.intValue){
        GameVC *gameVC = [[GameVC alloc]initWithInfo:d];
        [self.navigationController pushViewController:gameVC animated:YES];
        return;
    }
    [self hbo_showMsg:[d objectForKey:@"message"]];
}
    
    //注册
-(void)hbo_registBtn: (UIButton *)sender{
    NSLog(@"hbo_backBtn click");
    RegisterVC *regist = [RegisterVC new];
    [self.navigationController pushViewController:regist animated:YES];
}
    
    //找回密码
-(void)hbo_getPassBtn: (UIButton *)sender{
    NSLog(@"hbo_backBtn click");
    FindPasswordVC *findPass = [FindPasswordVC new];
    [self.navigationController pushViewController:findPass animated:YES];
}
    
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
    
-(void)hbo_hiddenMsg{
    _infoView.hidden = YES;
    _loginLeb.hidden = YES;
}
-(void)hbo_showMsg:(NSString *)msg{
    [_loginLeb setTextColor:[UIColor redColor]];
    _infoView.hidden = NO;
    _loginLeb.hidden = NO;
    _loginLeb.text = msg;
}
    @end
