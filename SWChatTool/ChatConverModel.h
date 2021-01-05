//
//  ChatConverModel.h
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    //其他
    SWConversationType_Other = 0,
    //私聊
    SWConversationType_Single = 2001,
    //群聊
    SWConversationType_Group = 2002,
} SWConversationType;

NS_ASSUME_NONNULL_BEGIN
@class ChatMessageModel;
@interface ChatConverModel : NSObject

/// 会话ID(私聊：用户ID ,群聊：群ID)
@property (nonatomic , copy) NSString *conversationId;

/// 数据库中对应的ID
@property (nonatomic , copy) NSString *idBeDB;

/// 昵称
@property (nonatomic , copy) NSString *nickName;

/// 消息类型
@property (nonatomic , assign) int32_t msgContentType;

/// 2001 : 私聊    2002：群聊
@property (nonatomic , assign) int32_t type;
/// 单聊/群聊
@property (nonatomic , assign) SWConversationType conversationType;

/// 未读消息数
@property (nonatomic , assign) int64_t recordNum;

/// 最新一条消息的时间（和离线消息一起做过处理，使用它）
@property (nonatomic , assign) long long needLastTime;

/// 最新一条消息的时间
@property (nonatomic , assign) long long lastTime;

/// 最后操作时间
@property (nonatomic , assign) long long dealLastTime;

/// 最新的消息
@property (nonatomic , strong) ChatMessageModel *NewMessageModel;
/// 最新消息的内容
@property (nonatomic , copy) NSString *lastMsgString;

/// 离线网络请求 优先级
@property (nonatomic , assign) NSInteger priority;


/// 发送消息
/// @param messageModel 消息
- (void)sendMessageModel:(ChatMessageModel *)messageModel
                 success:(void (^)(ChatMessageModel *messageModel))success
                    fail:(void (^)(ChatMessageModel *messageModel))fail;


@end

NS_ASSUME_NONNULL_END
