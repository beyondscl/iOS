//
//  Device.h
//  qzh
//
//  Created by xianming on 2018/2/5.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#ifndef Device_h
#define Device_h


#endif /* Device_h */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>//由于使用了NSObject，所以导入此头文件

@interface DeviceInfo : NSObject{
    
}

-(CGFloat)getBatteryQuantity;
-(nullable NSString*)getWifiName;
-(UIDeviceBatteryState)getBatteryStauts;
-(int)getSignalStrength;
- (nullable NSString *)getCurreWiFiSsid;
- (nullable NSString*)getCurrentLocalIP;
- (nullable NSString*)iphoneType;
-(void)startLocation;
+(void)askAudio;
+(void)askScreenLight;
@end
