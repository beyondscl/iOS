//
//  Device.m
//  qzh
//  获取机器的相关信息
//  Created by xianming on 2018/2/5.
//  Copyright © 2018年 hzqzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "NetworkExtension/NetworkExtension.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import<AVFoundation/AVFoundation.h>


#import "Device.h"


@interface DeviceInfo()<CLLocationManagerDelegate>{
    CLLocationManager  *locationManager;
}
@end

@implementation DeviceInfo

//获取电量必须enabled=yes
-(CGFloat)hbo_getBatteryQuantity{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return [[UIDevice currentDevice] batteryLevel];
}
-(UIDeviceBatteryState)hbo_getBatteryStauts
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return [UIDevice currentDevice].batteryState;
}
-(NSString *)hbo_getWifiName
{
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}
-(int)hbo_getSignalStrength{
    @try {
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
        UIView *dataNetworkItemView = nil;
        
        for (UIView * subview in subviews) {
            if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
                dataNetworkItemView = subview;
                break;
            }
        }
        int signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
        
        NSLog(@"signal %d", signalStrength);
        return signalStrength;
    }@catch (NSException *exception) {
        return -1;//表示获取失败
    }
    @finally {}
}

- (nullable NSString*)hbo_getCurrentLocalIP
{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (nullable NSString *)hbo_getCurreWiFiSsid {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    return [(NSDictionary*)info objectForKey:@"SSID"];
}

+ (NSString*)hbo_iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"]) return@"iPhone 2G";
    
    if([platform isEqualToString:@"iPhone1,2"]) return@"iPhone 3G";
    
    if([platform isEqualToString:@"iPhone2,1"]) return@"iPhone 3GS";
    
    if([platform isEqualToString:@"iPhone3,1"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,2"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,3"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone4,1"]) return@"iPhone 4S";
    
    if([platform isEqualToString:@"iPhone5,1"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,2"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,3"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone5,4"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone6,1"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone6,2"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone7,1"]) return@"iPhone 6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"]) return@"iPhone 6";
    
    if([platform isEqualToString:@"iPhone8,1"]) return@"iPhone 6s";
    
    if([platform isEqualToString:@"iPhone8,2"]) return@"iPhone 6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"]) return@"iPhone SE";
    
    if([platform isEqualToString:@"iPhone9,1"]) return@"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,2"]) return@"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,4"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,2"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,6"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPod1,1"]) return@"iPod Touch 1G";
    
    if([platform isEqualToString:@"iPod2,1"]) return@"iPod Touch 2G";
    
    if([platform isEqualToString:@"iPod3,1"]) return@"iPod Touch 3G";
    
    if([platform isEqualToString:@"iPod4,1"]) return@"iPod Touch 4G";
    
    if([platform isEqualToString:@"iPod5,1"]) return@"iPod Touch 5G";
    
    if([platform isEqualToString:@"iPad1,1"]) return@"iPad 1G";
    
    if([platform isEqualToString:@"iPad2,1"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,2"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,3"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,4"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,5"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,6"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,7"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad3,1"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,2"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,3"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,4"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,5"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,6"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad4,1"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,2"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,3"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,4"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,5"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,6"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,7"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,8"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,9"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad5,1"]) return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,2"]) return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,3"]) return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad5,4"]) return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad6,3"]) return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,4"]) return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,7"]) return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"iPad6,8"]) return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"i386"]) return@"iPhone Simulator";
    
    if([platform isEqualToString:@"x86_64"]) return@"iPhone Simulator";
    
    return platform;
    
}
//写在这里无法进入位置更新,无法使用
//开始定位
-(void)hbo_startLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1.0f;
    locationManager.desiredAccuracy = 1.0f;
    locationManager.delegate = self;

    
    if ([[[UIDevice currentDevice]systemVersion]doubleValue] >8.0){
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        if (@available(iOS 9.0, *)) {
            locationManager.allowsBackgroundLocationUpdates =YES;
        } else {
            // Fallback on earlier versions
        }
    }
    [locationManager startUpdatingLocation];
}
//这个方法用来获取用户是否开启可定位权限
- (void)hbo_locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        casekCLAuthorizationStatusNotDetermined:
            if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
}
//定位失败的代理方法
- (void)hbo_locationManager:(CLLocationManager *)manager   didFailWithError:(NSError *)error{
    NSLog(@"定位失败");
    if (error.code == kCLErrorDenied) {
        
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
        
    }
}
//获得的定位
- (void)hbo_locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = locations[0];
    CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
    [manager stopUpdatingLocation];
    //oldCoordinate.longitude 经度
    //oldCoordinate.latitude 纬度
     CLGeocoder *geocoder = [[CLGeocoder alloc]init];
     [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> *_Nullable placemarks, NSError * _Nullable error) {
        for (CLPlacemark *placemark in placemarks) {
            
            NSLog(@"name,%@",placemark.name);                      // 位置名
            
            NSLog(@"thoroughfare,%@",placemark.thoroughfare);      // 街道
            
            NSLog(@"subThoroughfare,%@",placemark.subThoroughfare);// 子街道
            
            NSLog(@"locality,%@",placemark.locality);              // 市
            
            NSLog(@"subLocality,%@",placemark.subLocality);        // 区
            
            NSLog(@"country,%@",placemark.country);                // 国家
            
            NSLog(@"%@ %@ %f %f", placemark.name, placemark.addressDictionary, placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
        }
    }];
}
//=======申请权限
+(void)hbo_askAudio{
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [avSession requestRecordPermission:^(BOOL available) {
            if (available) {
                //completionHandler
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"无法录音" message:@"请在“设置-隐私-麦克风”选项中允许xx访问你的麦克风" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                });
            }
        }];
        
    }
}
//屏幕常亮
+(void)hbo_askScreenLight{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}
@end

