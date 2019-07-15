//
//  BJAuthorityManager.m
//  OpenSDKTools
//
//  Created by 陈中宝 on 2019/7/11.
//  Copyright © 2019 中证机构间报价系统股份有限公司. All rights reserved.
//  设备权限管理

/**
 升到iOS10之后，需要在 Info.plist 设置权限的有：
 麦克风权限：Privacy - Microphone Usage Description 是否允许此App使用你的麦克风？
 相机权限： Privacy - Camera Usage Description 是否允许此App使用你的相机？
 相册权限： Privacy - Photo Library Usage Description 是否允许此App访问你的媒体资料库？
 通讯录权限： Privacy - Contacts Usage Description 是否允许此App访问你的通讯录？
 蓝牙权限：Privacy - Bluetooth Peripheral Usage Description 是否许允此App使用蓝牙？
 语音转文字权限：Privacy - Speech Recognition Usage Description 是否允许此App使用语音识别？
 日历权限：Privacy - Calendars Usage Description
 定位权限：Privacy - Location When In Use Usage Description
 定位权限: Privacy - Location Always Usage Description
 位置权限：Privacy - Location Usage Description
 媒体库权限：Privacy - Media Library Usage Description
 健康分享权限：Privacy - Health Share Usage Description
 健康更新权限：Privacy - Health Update Usage Description
 运动使用权限：Privacy - Motion Usage Description
 音乐权限：Privacy - Music Usage Description
 提醒使用权限：Privacy - Reminders Usage Description
 Siri使用权限：Privacy - Siri Usage Description
 电视供应商使用权限：Privacy - TV Provider Usage Description
 视频用户账号使用权限：Privacy - Video Subscriber Account Usage Description
 面部ID权限 ：Privacy - Face ID Usage Description
 保存图片到相册 ： Privacy - Photo Library Additions Usage Description
 
 
 key 值：
 <key>NSBluetoothPeripheralUsageDescription</key>
 <string>需要获取蓝牙权限</string>
 <key>NSCalendarsUsageDescription</key>
 <string>日历</string>
 <key>NSCameraUsageDescription</key>
 <string>需要获取您的摄像头信息</string>
 <key>NSContactsUsageDescription</key>
 <string>需要获取您的通讯录权限</string>
 <key>NSHealthShareUsageDescription</key>
 <string>健康分享权限</string>
 <key>NSHealthUpdateUsageDescription</key>
 <string>健康数据更新权限</string>
 <key>NSHomeKitUsageDescription</key>
 <string>HomeKit权限</string>
 <key>NSLocationAlwaysUsageDescription</key>
 <string>一直定位权限</string>
 <key>NSLocationUsageDescription</key>
 <string>定位权限</string>
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>使用app期间定位权限</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>需要获取您的麦克风权限</string>
 <key>NSPhotoLibraryUsageDescription</key>
 <string>需要获取您的相册信息</string>
 <key>NSRemindersUsageDescription</key>
 <string>提醒事项</string>
 <key>NSSiriUsageDescription</key>
 <string>需要获取您的Siri权限</string>
 <key>NSSpeechRecognitionUsageDescription</key>
 <string>语音识别权限</string>
 <key>NSVideoSubscriberAccountUsageDescription</key>
 <string>AppleTV权限</string>
 <key>NSAppleMusicUsageDescription</key>
 <string>Add tracks to your music library.</string>
 <key>NSMotionUsageDescription</key>
 <string>运动与健身权限</string>
 <key>NSPhotoLibraryAddUsageDescription</key>
 <string>需要获取您的相册信息</string>
 */

#import "BJAuthorityManager.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "BJMacro.h"


@implementation BJAuthorityManager

singleton_implementation(BJAuthorityManager)

- (void)openAppInSettings {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    });
}


- (void)executeOperationWithVideoPermission:(void(^)(void))grantedOperation
                                     reject:(void(^)(void))rejectOperation {
    [self _executeOperationWithDevicePermission:(AVMediaTypeVideo)
                                        granted:grantedOperation
                                         reject:rejectOperation];
}





- (void)executeOperationWithAudioPermission:(void (^)(void))grantedOperation
                                     reject:(void (^)(void))rejectOperation {
    [self _executeOperationWithDevicePermission:(AVMediaTypeAudio)
                                        granted:grantedOperation
                                         reject:rejectOperation];
}






- (void)executeOperationWithAssetsLibraryPermission:(void (^)(void))grantedOperation
                                             reject:(void (^)(void))rejectOperation {
    void(^failedOperation)(void) = ^{
        [self _guideUserToSettings:@"您还没有打开相册权限，是否去【设置】中打开？"];
        if (rejectOperation) {
            rejectOperation();
        }
    };
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
            //未决定/未授权
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    if (grantedOperation) {
                        grantedOperation();
                    }else{
                        failedOperation();
                    }
                }
            }];
        }
            break;
            
        case PHAuthorizationStatusDenied:
            BJLog(@"相册授权被拒绝");
            //用户拒绝
        case PHAuthorizationStatusRestricted:
            BJLog(@"相册权限被限制");
            //限制使用
            failedOperation();
            break;
            
        case PHAuthorizationStatusAuthorized:
            BJLog(@"相册权限已授权");
            if (grantedOperation) {
                grantedOperation();
            }
            break;
            
        default:
            break;
    }
}






//MARK:- private methods
- (void)_guideUserToSettings:(NSString *)promptMsg {
    if (!promptMsg || [@"" isEqualToString:promptMsg]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:promptMsg preferredStyle:(UIAlertControllerStyleAlert)];
        [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [[BJAuthorityManager sharedBJAuthorityManager] openAppInSettings];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDestructive) handler:nil]];
        
        UIViewController * vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (vc.presentedViewController && ![vc.presentedViewController isKindOfClass:[UIAlertController class]]) {
            vc = vc.presentedViewController;
        }
        [vc presentViewController:alert animated:YES completion:nil];
    });
}


- (void)_executeOperationWithDevicePermission:(AVMediaType)mediaType
                                      granted:(void (^)(void))grantedOperation
                                       reject:(void (^)(void))rejectOperation {
    NSString * deviceDesc = @"设备";
    if ([AVMediaTypeVideo isEqualToString:mediaType]) {
        deviceDesc = @"相机";
    }else if ([AVMediaTypeAudio isEqualToString:mediaType]) {
        deviceDesc = @"相册";
    }

    void(^failedOperation)(void) = ^{
        [self _guideUserToSettings:[NSString stringWithFormat:@"您还没有打开%@权限，是否去【设置】中打开？", deviceDesc]];
        if (rejectOperation) {
            rejectOperation();
        }
    };
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:(mediaType)];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
            //未决定/未授权
        {
            BJLog(@"%@", [NSString stringWithFormat:@"%@权限未授权", deviceDesc]);
            
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        failedOperation();
                        return;
                    }
                    if (grantedOperation) {
                        grantedOperation();
                    }
                });
            }];
        }
            break;

        case AVAuthorizationStatusDenied:
            //用户拒绝
        case AVAuthorizationStatusRestricted:
            //限制使用
            BJLog(@"%@", [NSString stringWithFormat:@"%@权限不能使用", deviceDesc]);
            failedOperation();
            break;

        case AVAuthorizationStatusAuthorized:
            BJLog(@"%@", [NSString stringWithFormat:@"%@权限已授权", deviceDesc]);
            if (grantedOperation) {
                grantedOperation();
            }
            break;
        default:
            break;
    }
}

@end

