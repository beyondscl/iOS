//
//  Register.m
//  UiLearn
//
//  Created by xianming on 2018/3/16.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
//
//  LoginViewController.m
//  WebViews
//
//  Created by xianming on 2018/3/13.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegisterVC.h"
#import "Util.h"
#import "Logon.h"
#import "GameVC.h"



#define kScreen_height [UIScreen mainScreen].bounds.size.height
#define kScreen_width [UIScreen mainScreen].bounds.size.width

#import "Logon.h"

@interface RegisterVC ()<UITextFieldDelegate,UINavigationControllerDelegate>{
    UIView *_view;
    CGRect _vFrame;
    UITextField *_sjhField;
    UITextField *_yzmField;
    UITextField *_mmField;
    UITextField *_ncField;
    
    UILabel *_loginLeb;
    UIImageView *_infoView;
}
    @end



@implementation RegisterVC
    
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    
    //键盘
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self loggin2];
}
    
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [_ncField resignFirstResponder];
    [_mmField resignFirstResponder];
    [_yzmField resignFirstResponder];
    [_sjhField resignFirstResponder];
    
}
#pragma mark 去掉导航栏
    
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}
    //注册界面
- (void)loggin2
    {
        float navHeight = 0.0f;
//        UIFont *lpFont = [UIFont boldSystemFontOfSize:16];
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
        UIImage *bg2 =[UIImage imageNamed:@"ty_di1.png"];
        UIImageView *bgView2 = [[UIImageView alloc]initWithImage:bg2];
        bgView2.frame = CGRectMake(kScreen_width/6, kScreen_height/7, kScreen_width*4/6, kScreen_height*5/7);
        [_view addSubview:bgView2];
        
        //    //返回
        //    UIImage *back =[UIImage imageNamed:@"fanhui.png"];
        //    UIImageView *bkView2 = [[UIImageView alloc]initWithImage:back];
        //    bkView2.frame = CGRectMake(kScreen_width/10, bgView2.frame.origin.y+5, 35, 35);
        //    //    bkView2.frame = CGRectMake(kScreen_width/10, kScreen_height/10, 35, 35);
        //    [_view addSubview:bkView2];
        
        //    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backBtn:)];
        //    [bkView2 addGestureRecognizer:tapGesture];
        //    bkView2.userInteractionEnabled = YES;
        
        //注册标题
        UIImage *zcTitle =[UIImage imageNamed:@"zhuce.png"];
        UIImageView *zcView = [[UIImageView alloc]initWithImage:zcTitle];
        zcView.frame = CGRectMake(kScreen_width/2-35, bgView2.frame.origin.y+3, 90, 28);
        [_view addSubview:zcView];
        
        //关闭,
        UIImage *close =[UIImage imageNamed:@"guanbi.png"];
        UIImageView *closeView = [[UIImageView alloc]initWithImage:close];
        closeView.frame = CGRectMake(bgView2.frame.origin.x+bgView2.frame.size.width-30, bgView2.frame.origin.y, 30, 30);
        [_view addSubview:closeView];
        
        
        UITapGestureRecognizer *closeBtn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBtn:)];
        [closeView addGestureRecognizer:closeBtn];
        closeView.userInteractionEnabled = YES;
        
        //背景3
        UIImage *back3 =[UIImage imageNamed:@"ty_di4.png"];
        UIImageView *back3View3 = [[UIImageView alloc]initWithImage:back3];
        back3View3.frame = CGRectMake(kScreen_width/6+4, kScreen_height/7+35, kScreen_width*4/6-8, kScreen_height*5/7-38);
        [_view addSubview:back3View3];
        
        
        
        //内容框的总高度
        float contentHeight = bgView2.frame.size.height;
        //内容开始高度：内容总共有3个。那么分成5份，第二份开始
        float startH =bgView2.frame.origin.y+contentHeight/3.5;
        
        //手机号码========
        //lebal
        UILabel *loginLeb = [[UILabel alloc] initWithFrame:CGRectMake(bgView2.frame.origin.x+10, startH, 80, 40)];
        [loginLeb setText:@"手机号码"];
        [loginLeb setTextColor:[UIColor blackColor]];
        [_view addSubview:loginLeb];
        //背景
        UIImage *shuruDi =[UIImage imageNamed:@"di2.png"];
        UIImageView *diView = [[UIImageView alloc]initWithImage:shuruDi];
        diView.frame = CGRectMake(loginLeb.frame.origin.x+loginLeb.frame.size.width,
                                  loginLeb.frame.origin.y, bgView2.frame.size.width-loginLeb.frame.size.width-20,30);
        [_view addSubview:diView];
        //text
        _sjhField =[[UITextField alloc]initWithFrame:CGRectMake(loginLeb.frame.origin.x+loginLeb.frame.size.width,
                                                                loginLeb.frame.origin.y-5,
                                                                diView.frame.size.width,30)];
        [_sjhField setKeyboardType:UIKeyboardTypePhonePad];
        _sjhField.placeholder = @"请输入手机号码";
        [_view addSubview:_sjhField];
        
        //验证码========
        //lebal
        UILabel *yzmLeb = [[UILabel alloc] initWithFrame:CGRectMake(bgView2.frame.origin.x+10, loginLeb.frame.origin.y+40, 80, 40)];
        [yzmLeb setText:@"验证码"];
        [_view addSubview:yzmLeb];
        //背景
        UIImage *shuruDi2 =[UIImage imageNamed:@"di2.png"];
        UIImageView *diView2 = [[UIImageView alloc]initWithImage:shuruDi2];
        diView2.frame = CGRectMake(diView.frame.origin.x,
                                   yzmLeb.frame.origin.y, bgView2.frame.size.width-loginLeb.frame.size.width-20-120,30);
        [_view addSubview:diView2];
        
        //获取验证码
        UIImage *getYzm =[UIImage imageNamed:@"huoquyanzhengma.png"];
        UIImageView *getYzmV = [[UIImageView alloc]initWithImage:getYzm];
        getYzmV.frame = CGRectMake(diView2.frame.origin.x+diView2.frame.size.width+20,
                                   yzmLeb.frame.origin.y, 85,30);
        
        UITapGestureRecognizer *yamBtn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yamBtn:)];
        [getYzmV addGestureRecognizer:yamBtn];
        getYzmV.userInteractionEnabled = YES;
        
        [_view addSubview:getYzmV];
        
        //text
        _yzmField =[[UITextField alloc]initWithFrame:CGRectMake(diView2.frame.origin.x,
                                                                diView2.frame.origin.y-5,
                                                                diView2.frame.size.width,30)];
        [_yzmField setKeyboardType:UIKeyboardTypeNumberPad];
        _yzmField.placeholder = @"请输入验证码";
        
        
        [_view addSubview:_yzmField];
        
        //密码========
        //lebal
        UILabel *maLeb = [[UILabel alloc] initWithFrame:CGRectMake(bgView2.frame.origin.x+10, yzmLeb.frame.origin.y+40, 80, 40)];
        [maLeb setText:@"密    码"];
        [_view addSubview:maLeb];
        //背景
        UIImage *shuruDi3 =[UIImage imageNamed:@"di2.png"];
        UIImageView *diView3 = [[UIImageView alloc]initWithImage:shuruDi3];
        diView3.frame = CGRectMake(diView2.frame.origin.x,
                                   maLeb.frame.origin.y, bgView2.frame.size.width-loginLeb.frame.size.width-20,30);
        [_view addSubview:diView3];
        //text
        _mmField =[[UITextField alloc]initWithFrame:CGRectMake(diView3.frame.origin.x,
                                                               diView3.frame.origin.y-5,
                                                               diView3.frame.size.width,30)];
        _mmField.placeholder = @"请输入6-20位密码";
        [_mmField setKeyboardType:UIKeyboardTypeDefault];
        [_mmField setBorderStyle:UITextBorderStyleNone];
        [_mmField setAutocapitalizationType:UITextAutocapitalizationTypeNone]; //关闭首字母大写
        [_mmField setReturnKeyType:UIReturnKeyDone]; //完成
        [_mmField setSecureTextEntry:YES]; //验证
        
        [_view addSubview:_mmField];
        
        //昵称========
        //lebal
        UILabel *nickNameLeb = [[UILabel alloc] initWithFrame:CGRectMake(bgView2.frame.origin.x+10, maLeb.frame.origin.y+40, 80, 40)];
        [nickNameLeb setText:@"昵    称"];
        [_view addSubview:nickNameLeb];
        //背景
        UIImage *shuruDi4 =[UIImage imageNamed:@"di2.png"];
        UIImageView *diView4 = [[UIImageView alloc]initWithImage:shuruDi4];
        diView4.frame = CGRectMake(diView3.frame.origin.x,
                                   nickNameLeb.frame.origin.y, bgView2.frame.size.width-loginLeb.frame.size.width-20,30);
        [_view addSubview:diView4];
        //text
        _ncField =[[UITextField alloc]initWithFrame:CGRectMake(diView4.frame.origin.x,
                                                               diView4.frame.origin.y-5,
                                                               diView4.frame.size.width,30)];
        _ncField.placeholder = @"请输入昵称";
        [_view addSubview:_ncField];
        
        //确定
        
        UIImage *submit =[UIImage imageNamed:@"queding.png"];
        UIImageView *submitV = [[UIImageView alloc]initWithImage:submit];
        submitV.frame = CGRectMake(kScreen_width/2-45,
                                   nickNameLeb.frame.origin.y+nickNameLeb.frame.size.height+10, 90,30);
        
        UITapGestureRecognizer *regisBtn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regisBtn:)];
        [submitV addGestureRecognizer:regisBtn];
        submitV.userInteractionEnabled = YES;
        
        [_view addSubview:submitV];
        
        
        
    }
    //返回按钮
-(void)backBtn: (UIButton *)sender{
    NSLog(@"backBtn click");
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)closeBtn: (UIButton *)sender{
    NSLog(@"backBtn click");
    [self.navigationController popViewControllerAnimated:NO];
}
    
-(void)regisBtn: (UIButton *)sender{
    NSLog(@"regisBtn click");
    //    UITextField *_sjhField;
    //    UITextField *_yzmField;
    //    UITextField *_mmField;
    //    UITextField *_ncField;
    
    NSString *phoneNum = _sjhField.text;
    NSString *yzm = _yzmField.text;
    NSString *mima = _mmField.text;
    NSString *nickname = _ncField.text;
    
    if(![UtilTool validateCellPhoneNumber:phoneNum]){
        [UtilTool doAlert:@"手机号不存在"];
        return;
    }
    if(yzm.length!=4){
        [UtilTool doAlert:@"验证码不正确"];
        return;
    }
    if(mima.length<6||mima.length>20){
        [UtilTool doAlert:@"密码格式不正确"];
        return;
    }
    if(nickname.length<2||nickname.length>8){
        [UtilTool doAlert:@"昵称长度为2-7"];
        return;
    }
    NSDictionary *d = [Logon dfSignup:phoneNum pass:mima verifyCode:yzm nickname:nickname];
    NSString *code = [d objectForKey:@"code"];
    if(0==code.intValue){
        [UtilTool doAlert:@"注册成功，准备进入游戏!"];
        
        NSDictionary *d2 = [Logon dfSignin:phoneNum password:mima];
        NSString *code2 = [d2 objectForKey:@"code"];
        if(0==code2.intValue){
            GameVC *gameVC = [[GameVC alloc]initWithInfo:d];
            [self.navigationController pushViewController:gameVC animated:YES];
            return;
        }
    }
    [UtilTool doAlert:[d objectForKey:@"message"]];
}
-(void)yamBtn:(UIButton*)sender{
    NSLog(@"get yzm click");
    NSString *phoneNum = _sjhField.text;
    if(![UtilTool validateCellPhoneNumber:phoneNum]){
        [UtilTool doAlert:@"手机号不存在"];
        return;
    }
    NSDictionary *d = [Logon sendvVrifyMsg:phoneNum type:@"phoneRegist"];
    NSString *code = [d objectForKey:@"code"];
    if(0!=code.intValue){
        [UtilTool doAlert:[d objectForKey:@"message"]];
        return;
    }
    [UtilTool doAlert:@"验证码已发送"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
    
-(void)hiddenMsg{
    _infoView.hidden = YES;
    _loginLeb.hidden = YES;
}
-(void)showMsg:(NSString *)msg{
    [_loginLeb setTextColor:[UIColor redColor]];
    _infoView.hidden = NO;
    _loginLeb.hidden = NO;
    _loginLeb.text = msg;
}
    @end
