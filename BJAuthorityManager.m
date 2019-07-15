//
//  BJAuthorityManager.m
//  OpenSDKTools
//
//  Created by 陈中宝 on 2019/7/11.
//  Copyright © 2019 中证机构间报价系统股份有限公司. All rights reserved.
//  设备权限管理

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

