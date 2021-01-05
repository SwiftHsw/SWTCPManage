//
//  SWChatTool.h
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import "SWConversationManager.h"
#import "SWTCPManager.h"
 
NS_ASSUME_NONNULL_BEGIN

@interface SWChatTool : NSObject

///会话管理者
@property (nonatomic , strong) SWConversationManager *conversationManager;

/// 数据库管理者
@property (nonatomic , strong) NSObject *dataManager;

/// TCP管理者
@property (nonatomic , strong) SWTCPManager *tcpManager;
 

/// 是否有新朋友添加
@property (nonatomic , assign) int32_t newAddFriendCount;

+(instancetype)shareManager;

/// token过期处理
//- (void)addTokenExpiredHandle;

/// 关闭所有管理者
- (void)removeAllManager;
//
///// 清除全部记录
//- (void)clearAllRecordDataForIIM;
//
///// 清除图片、视频、文件
- (void)clearAllRecordFileForIIM;
//
///// 根据记录保留时长，清理记录
//- (void)clearAllRecordDataForRecordTime;

@end

NS_ASSUME_NONNULL_END
