//
//  AppDelegate.h
//  qzh
//
//  Created by xianming on 2018/1/19.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Reachability.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (nonatomic, strong) Reachability *reach;


- (void)saveContext;


@end
