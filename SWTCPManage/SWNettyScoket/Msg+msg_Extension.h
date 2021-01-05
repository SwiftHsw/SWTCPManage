//
//  Msg+msg_Extension.h
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import "SWNettySocketMsg.pbobjc.h"
#import "SWTCPManager.h"
#import "ChatMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Msg (msg_Extension)

/// 创建第一次握手需要的Msg
+ (instancetype)createMsgForFirstHand;

/// 创建心跳需要的Msg
+ (instancetype)createMsgForHeart;


/// 创建普通的Msg(群聊功能可用)
+ (instancetype)createMsgWithMsgType:(int32_t)msgType
                      msgContentType:(int32_t)msgContentType
                                toId:(NSString *)toId;


/// Msg转ChatModel
- (ChatMessageModel *)msgToMessageModel;


@end


@interface Head (head_Extension)

/// 创建第一次握手需要的Head
+ (instancetype)createHeadForFirstHand;

/// 创建心跳需要的Head
+ (instancetype)createHeadForHeart;

/// 创建普通的Head

+ (instancetype)createHeadWithMsgType:(int32_t)msgType msgContentType:(int32_t)msgContentType toId:(NSString *)toId;

@end


NS_ASSUME_NONNULL_END
