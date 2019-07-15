//
//  BJPhotoTool.m
//  OpenSDKTools
//
//  Created by 陈中宝 on 2019/7/12.
//  Copyright © 2019 中证机构间报价系统股份有限公司. All rights reserved.
//

#import "BJPhotoTool.h"
#import "BJMacro.h"
#import "BJAuthorityManager.h"


/**
typedef NS_ENUM(NSInteger, PHAssetCollectionType) {
    PHAssetCollectionTypeAlbum      = 1,  相册，系统外的
    PHAssetCollectionTypeSmartAlbum = 2,  智能相册，系统自己分配和归纳的
    PHAssetCollectionTypeMoment     = 3,  时刻，系统自动通过时间和地点生成的分组
}

typedef NS_ENUM(NSInteger, PHAssetCollectionSubtype) {
 
    // PHAssetCollectionTypeAlbum regular subtypes
    PHAssetCollectionSubtypeAlbumRegular         = 2, // 在iPhone中自己创建的相册
    PHAssetCollectionSubtypeAlbumSyncedEvent     = 3, // 从iPhoto（就是现在的图片app）中导入图片到设备
    PHAssetCollectionSubtypeAlbumSyncedFaces     = 4, // 从图片app中导入的人物照片
    PHAssetCollectionSubtypeAlbumSyncedAlbum     = 5, // 从图片app导入的相册
    PHAssetCollectionSubtypeAlbumImported        = 6, // 从其他的相机或者存储设备导入的相册
    
    // PHAssetCollectionTypeAlbum shared subtypes
    PHAssetCollectionSubtypeAlbumMyPhotoStream   = 100,  // 照片流，照片流和iCloud有关，如果在设置里关闭了iCloud开关，就获取不到了
    PHAssetCollectionSubtypeAlbumCloudShared     = 101,  // iCloud的共享相册，点击照片上的共享tab创建后就能拿到了，但是前提是你要在设置中打开iCloud的共享开关（打开后才能看见共享tab）
    
    // PHAssetCollectionTypeSmartAlbum subtypes
    PHAssetCollectionSubtypeSmartAlbumGeneric    = 200,
    PHAssetCollectionSubtypeSmartAlbumPanoramas  = 201,  // 全景图、全景照片
    PHAssetCollectionSubtypeSmartAlbumVideos     = 202,  // 视频
    PHAssetCollectionSubtypeSmartAlbumFavorites  = 203,  // 标记为喜欢、收藏
    PHAssetCollectionSubtypeSmartAlbumTimelapses = 204,  // 延时拍摄、定时拍摄
    PHAssetCollectionSubtypeSmartAlbumAllHidden  = 205,  // 隐藏的
    PHAssetCollectionSubtypeSmartAlbumRecentlyAdded = 206,  // 最近添加的、近期添加
    PHAssetCollectionSubtypeSmartAlbumBursts     = 207,  // 连拍
    PHAssetCollectionSubtypeSmartAlbumSlomoVideos = 208,  // Slow Motion,高速摄影慢动作（概念不懂）
    PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209,  // 相机胶卷
    PHAssetCollectionSubtypeSmartAlbumSelfPortraits PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 210, // 使用前置摄像头拍摄的作品
    PHAssetCollectionSubtypeSmartAlbumScreenshots PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 211,  // 屏幕截图
    PHAssetCollectionSubtypeSmartAlbumDepthEffect PHOTOS_AVAILABLE_IOS_TVOS(10_2, 10_1) = 212,  // 在可兼容的设备上使用景深摄像模式拍的照片（概念不懂）
    PHAssetCollectionSubtypeSmartAlbumLivePhotos PHOTOS_AVAILABLE_IOS_TVOS(10_3, 10_2) = 213,  // Live Photo资源
    PHAssetCollectionSubtypeSmartAlbumAnimated PHOTOS_AVAILABLE_IOS_TVOS(11_0, 11_0) = 214,  // 没有解释
    PHAssetCollectionSubtypeSmartAlbumLongExposures PHOTOS_AVAILABLE_IOS_TVOS(11_0, 11_0) = 215,  // 没有解释
    // Used for fetching, if you don't care about the exact subtype
    PHAssetCollectionSubtypeAny = NSIntegerMax
}
 
 **/



@implementation BJPhotoTool

singleton_implementation(BJPhotoTool)





- (void)allCollections:(void(^)(NSArray<PHAssetCollection *> *assetCollections))callBack {
    void (^grantedOperation)(void) = ^{
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                              subtype:PHAssetCollectionSubtypeAny
                                                                              options:nil];
        if (smartAlbums) {
            for (int i = 0; i < smartAlbums.count; i++) {
                PHCollection *collection = smartAlbums[i];
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                    BJLog(@"-----%@ - %@", assetCollection.localIdentifier, assetCollection.localizedTitle);
                    [arr addObject:assetCollection];
                }else{
                    BJLog(@"不是相册！！！");
                }
            }
        }
        
        smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        if (smartAlbums) {
            for (int i = 0; i < smartAlbums.count; i++) {
                PHCollection *collection = smartAlbums[i];
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                    BJLog(@"-----%@ - %@", assetCollection.localIdentifier, assetCollection.localizedTitle);
                    [arr addObject:assetCollection];
                }else{
                    BJLog(@"不是相册！！！");
                }
            }
        }
        
        if (callBack) {        
            callBack(arr);
        }
    };
    
    [[BJAuthorityManager sharedBJAuthorityManager] executeOperationWithAssetsLibraryPermission:grantedOperation
                                                                                        reject:nil];
}




- (void)imageForCollection:(PHAssetCollection * _Nullable)collection
                  complete:(void (^ _Nonnull)(NSArray<PHAsset *> * _Nullable assetArr))completeHandler {
    [self _assetsForCollection:collection
                     mediaType:PHAssetMediaTypeImage
                      complete:completeHandler];
}




- (void)imageForAsset:(PHAsset *)imageAsset
             complete:(void(^)(UIImage * image, NSDictionary *info))completeHandler {
    if (!imageAsset || imageAsset.mediaType != PHAssetMediaTypeImage) {
        completeHandler(nil, nil);
        return;
    }
    CGSize size = CGSizeMake(imageAsset.pixelWidth, imageAsset.pixelHeight);
    [[PHImageManager defaultManager] requestImageForAsset:imageAsset
                                               targetSize:size
                                              contentMode:(PHImageContentModeAspectFill)
                                                  options:nil
                                            resultHandler:completeHandler];
}




- (void)videoForCollection:(PHAssetCollection *)collection
                  complete:(void (^)(NSArray<PHAsset *> * _Nullable))completeHandler {
    [self _assetsForCollection:collection mediaType:(PHAssetMediaTypeVideo) complete:completeHandler];
}


- (void)videoForAsset:(PHAsset * _Nonnull)videoAsset
                 save:(NSString * _Nonnull)savePath
             complete:(void(^ _Nonnull)(NSURL * _Nullable location, NSError * _Nullable error))completeHandler {
    if (!videoAsset || !savePath || [@"" isEqualToString:savePath]) {
        NSError *error = [NSError errorWithDomain:BJVideoExportErrorDomain
                                             code:NSURLErrorBadURL
                                         userInfo:@{NSLocalizedFailureReasonErrorKey: @"videoAsset or savePath is empty"}];
        completeHandler(nil, error);
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
    }
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    [[PHImageManager defaultManager] requestExportSessionForVideo:videoAsset
                                  options:options
                             exportPreset:AVAssetExportPresetMediumQuality
                            resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
        exportSession.outputURL =  [NSURL fileURLWithPath:savePath];
        exportSession.shouldOptimizeForNetworkUse = NO;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    {
                        BJLog(@"failed..");
                    NSError *error = [NSError errorWithDomain:BJVideoExportErrorDomain code:NSURLErrorCancelled userInfo:@{NSLocalizedFailureReasonErrorKey: @"video export failed"}];
                        if (completeHandler) {
                            completeHandler(nil, error);
                        }
                    }
                    break;
                
                case AVAssetExportSessionStatusCancelled:
                    BJLog(@"cancelled");
                {
                    BJLog(@"failed..");
                    NSError *error = [NSError errorWithDomain:BJVideoExportErrorDomain code:NSURLErrorCancelled userInfo:@{NSLocalizedFailureReasonErrorKey: @"video export cancelled"}];
                    if (completeHandler) {
                        completeHandler(nil, error);
                    }
                }
                    break;
                    
                case AVAssetExportSessionStatusCompleted:
                    BJLog(@"complete");
                    if (completeHandler) {
                        completeHandler([NSURL fileURLWithPath:savePath], nil);
                    }
                    break;
                    
                default:
                    //AVAssetExportSessionStatusUnknown
                    //AVAssetExportSessionStatusWaiting
                    //AVAssetExportSessionStatusExporting
                    break;
            }
        }];
    }];
}



- (void)saveImage:(UIImage * _Nonnull)image
     toCollection:(PHAssetCollection * _Nonnull)collection
         complete:(void(^ _Nullable)(BOOL success, NSError *error))completeHandler {
    if (!image || !collection) {
        NSError *error = [NSError errorWithDomain:BJAssetsSaveErrorDomain
                                             code:NSURLErrorCannotCreateFile
                                         userInfo:@{NSLocalizedFailureReasonErrorKey:@"image and collection cannot be empty"}];
        if (completeHandler) {
            completeHandler(NO, error);
        }
        return;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHObjectPlaceholder *placeHolder = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
        [request addAssets:@[placeHolder]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (completeHandler) {
            if (error) {
                completeHandler(NO, error);
            }else{
                completeHandler(YES, nil);
            }
        }
    }];
}


- (void)saveVideo:(NSString *)videoPath
     toCollection:(PHAssetCollection *)collection
         complete:(void (^)(BOOL, NSError * _Nullable))completeHandler {
    
    if (!videoPath || [@"" isEqualToString:videoPath] || !collection) {
        NSError *error = [NSError errorWithDomain:BJAssetsSaveErrorDomain
                                             code:NSURLErrorCannotCreateFile
                                         userInfo:@{NSLocalizedFailureReasonErrorKey:@"video and collection cannot be empty"}];
        if (completeHandler) {
            completeHandler(NO, error);
        }
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        NSError *error = [NSError errorWithDomain:BJAssetsSaveErrorDomain
                                             code:NSURLErrorCannotCreateFile
                                         userInfo:@{NSLocalizedFailureReasonErrorKey:@"video and collection cannot be empty"}];
        if (completeHandler) {
            completeHandler(NO, error);
        }
        return;
    }
    
    NSURL *videoUrl = [NSURL fileURLWithPath:videoPath];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHObjectPlaceholder *placeHolder = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl].placeholderForCreatedAsset;
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
        [request addAssets:@[placeHolder]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (completeHandler) {
            if (error) {
                completeHandler(NO, error);
            }else{
                completeHandler(YES, nil);
            }
        }
    }];
}



- (void)collectionForTitle:(NSString *)title
                  complete:(void(^ _Nonnull)(PHAssetCollection * _Nullable collection, NSError * _Nullable error))completeHander {
    if (!title || [@"" isEqualToString:title]) {
        if (completeHander) {
            NSError *error = [NSError errorWithDomain:BJCollectionCreationErrorDomain code:NSURLErrorCannotCreateFile userInfo:@{NSLocalizedFailureReasonErrorKey: @"title cannot be empty"}];
            completeHander(nil, error);
        }
        return;
    }
    
    [[BJAuthorityManager sharedBJAuthorityManager] executeOperationWithAssetsLibraryPermission:^{
        PHFetchResult<PHAssetCollection *> * collectionArr = [PHAssetCollection fetchAssetCollectionsWithType:(PHAssetCollectionTypeAlbum) subtype:(PHAssetCollectionSubtypeAny) options:nil];
        PHAssetCollection *theCollection;
        for (int i = 0; i < collectionArr.count; i++) {
            PHAssetCollection *collection = collectionArr[i];
            if ([title isEqualToString:collection.localizedTitle]) {
                theCollection = collection;
                break;
            }
        }
        if (!theCollection) {
            NSError *error;
            __block NSString * localIdentifier;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
                localIdentifier = request.placeholderForCreatedAssetCollection.localIdentifier;
            } error:&error];
            if (error) {
                if (completeHander) {
                    completeHander(nil, error);
                }
                return;
            }
            PHAssetCollection *collection = [self _collectionForIdentifier:localIdentifier];
            if (completeHander) {
                completeHander(collection, nil);
            }
        }else{
            completeHander(theCollection, nil);
        }
    } reject:nil];
}




////MARK:- private methods
- (void)_assetsForCollection:(PHAssetCollection * _Nullable)collection
                   mediaType:(PHAssetMediaType)mediaType
                    complete:(void (^ _Nonnull)(NSArray<PHAsset *> * _Nullable assetArr))completeHandler {
    [[BJAuthorityManager sharedBJAuthorityManager] executeOperationWithAssetsLibraryPermission:^{
        PHFetchResult<PHAsset *> * results;
        if (collection) {
            results = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        }else{
            results = [PHAsset fetchAssetsWithMediaType:(mediaType) options:nil];
        }
        
        if (results) {
            NSMutableArray *assetArr = [NSMutableArray arrayWithCapacity:1];
            for (int i = 0; i < results.count; i++) {
                PHAsset * asset = results[i];
                if (asset.mediaType != mediaType) {
                    continue;
                }
                [assetArr addObject:asset];
            }
            if (completeHandler) {
                completeHandler(assetArr);
            }
        }
    } reject:nil];
}



- (PHAssetCollection *)_collectionForIdentifier:(NSString * _Nonnull)identifier {
    if (!identifier) {
        return nil;
    }
    PHFetchResult<PHAssetCollection *> * collectionArr = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[identifier] options:nil];
    if (collectionArr.count == 0) {
        return nil;
    }
    return collectionArr.lastObject;
}



    

    

@end
