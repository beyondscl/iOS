//
//  Commutate.h
//  fish
//
//  Created by xianming on 2018/3/19.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#ifndef Commutate_h
#define Commutate_h


#endif /* Commutate_h */

#import <Foundation/Foundation.h>

@protocol DownProgress<NSObject>

@optional
//获取下载进度的协议
-(float)setDownProgress:(float)p;

@end



@interface Commutate :NSObject

@property (nonatomic, weak)id<DownProgress> downProgressDele;

@end

