//
//  BJAuthorityManager.h
//  OpenSDKTools
//
//  Created by 陈中宝 on 2019/7/11.
//  Copyright © 2019 中证机构间报价系统股份有限公司. All rights reserved.
//  设备权限管理

#import <Foundation/Foundation.h>
#import "BJMacro.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJAuthorityManager : NSObject

singleton_interface(BJAuthorityManager)

/**
 打开 App 对应的设置界面
 */
- (void)openAppInSettings;



/**
 获取相机权限并执行操作
 如果用户拒绝，或已拒绝，会 alert 引导用户去开启

 @param grantedOperation 获取权限成功执行的操作
 @param rejectOperation  获取权限失败执行的操作
 */
- (void)executeOperationWithVideoPermission:(void(^ _Nullable)(void))grantedOperation
                                     reject:(void(^ _Nullable)(void))rejectOperation;



/**
 获取麦克风权限并执行操作
 如果用户拒绝，或已拒绝，会 alert 引导用户去开启

 @param grantedOperation 获取权限成功执行的操作
 @param rejectOperation  获取权限失败执行的操作
 */
- (void)executeOperationWithAudioPermission:(void(^ _Nullable)(void))grantedOperation
                                     reject:(void(^ _Nullable)(void))rejectOperation;



/**
 获取相册权限并执行操作
 如果用户拒绝，或已拒绝，会 alert 引导用户去开启

 @param grantedOperation 获取权限成功执行的操作
 @param rejectOperation  获取权限失败执行的操作
 */
- (void)executeOperationWithAssetsLibraryPermission:(void(^ _Nullable)(void))grantedOperation
                                             reject:(void(^ _Nullable)(void))rejectOperation;
@end

NS_ASSUME_NONNULL_END
