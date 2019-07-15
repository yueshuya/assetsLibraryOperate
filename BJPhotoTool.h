//
//  BJPhotoTool.h
//  OpenSDKTools
//
//  Created by 陈中宝 on 2019/7/12.
//  Copyright © 2019 中证机构间报价系统股份有限公司. All rights reserved.
//  相册工具

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "BJMacro.h"

NS_ASSUME_NONNULL_BEGIN


NSString * const BJVideoExportErrorDomain = @"com.interotc.error.video.export.failed";
NSString * const BJCollectionCreationErrorDomain = @"com.interotc.error.assets.collection.create";
NSString * const BJAssetsSaveErrorDomain = @"com.interotc.error.assets.save";




@interface BJPhotoTool : NSObject

singleton_interface(BJPhotoTool)


/**
 获取所有的相册列表

 @param callBack 回调
 */
- (void)allCollections:(void(^ _Nonnull)(NSArray<PHAssetCollection *> * _Nullable assetCollections))callBack;


/**
 获取指定相册的图片，传 nil 则获取所有相册的所有的图片

 @param collection      指定相册
 @param completeHandler 回调
 */
- (void)imageForCollection:(PHAssetCollection * _Nullable)collection
                  complete:(void (^ _Nonnull)(NSArray<PHAsset *> * _Nullable assetArr))completeHandler;



/**
 根据指定资源获取图片

 @param imageAsset      资源，必须是图片
 @param completeHandler 回调
 */
- (void)imageForAsset:(PHAsset * _Nonnull)imageAsset
             complete:(void(^ _Nonnull)(UIImage * image, NSDictionary *info))completeHandler;


/**
 获取指定相册的视频

 @param collection      指定相册
 @param completeHandler 回调
 */
- (void)videoForCollection:(PHAssetCollection * _Nullable)collection
                  complete:(void (^ _Nonnull)(NSArray<PHAsset *> * _Nullable assetArr))completeHandler;


/**
 导出指定的视频，MP4 格式，中等质量

 @param videoAsset      资源
 @param savePath        保存路径
 @param completeHandler 回调
 */
- (void)videoForAsset:(PHAsset * _Nonnull)videoAsset
                 save:(NSString * _Nonnull)savePath
             complete:(void(^ _Nonnull)(NSURL * _Nullable location, NSError * _Nullable error))completeHandler;


//保存图片到某相册


/**
 保存图片到某相册

 @param image           图片
 @param collection      相册
 @param completeHandler 回调
 */
- (void)saveImage:(UIImage * _Nonnull)image
     toCollection:(PHAssetCollection * _Nonnull)collection
         complete:(void(^ _Nullable)(BOOL success, NSError * _Nullable error))completeHandler;


/**
 保存视频到某个相册

 @param videoPath       视频地址
 @param collection      相册
 @param completeHandler 回调
 */
- (void)saveVideo:(NSString * _Nonnull)videoPath
     toCollection:(PHAssetCollection * _Nonnull)collection
         complete:(void(^ _Nullable)(BOOL success, NSError * _Nullable error))completeHandler;



/**
 根据 title 获取相册 - 只针对自定义相册，不存在的话会自动创建

 @param title 相册名字
 @param completeHander 回调
 */
- (void)collectionForTitle:(NSString * _Nonnull)title
                  complete:(void(^ _Nonnull)(PHAssetCollection * _Nullable collection, NSError * _Nullable error))completeHander;


@end

NS_ASSUME_NONNULL_END
