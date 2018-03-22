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
-(CGFloat)hbo_getBatteryQuantity;
-(nullable NSString*)hbo_getWifiName;
-(UIDeviceBatteryState)hbo_getBatteryStauts;
-(int)hbo_getSignalStrength;
- (nullable NSString *)hbo_getCurreWiFiSsid;
- (nullable NSString*)hbo_getCurrentLocalIP;
+ (nullable NSString*)hbo_iphoneType;
-(void)hbo_startLocation;
+(void)hbo_askAudio;
+(void)hbo_askScreenLight;
@end
