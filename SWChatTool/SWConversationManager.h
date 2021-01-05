//
//  SWConversationManager.h
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import "ChatConverModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SWConversationManager : NSObject


/// 当前是所在的会话聊天页
@property (nonatomic , strong , nullable) ChatConverModel *inConversation;


/*!
 *  \~chinese
 *  删除一条消息
 *
 *  @param aMessageId   要删除消失的ID
 *  @param pError       错误信息
 *
 *  \~english
 *  Delete a message
 *
 *  @param aMessageId   Id of the message to be deleted
 *  @param pError       Error
 *
 */
- (void)deleteMessageWithId:(NSString *)aMessageId
                      error:(NSError *)pError;


/*!
 *  \~chinese
 *  删除该会话所有消息，同时清除内存和数据库中的消息
 *
 *  @param pError       错误信息
 *
 *  \~english
 *  Delete all messages of the conversation from memory cache and local database
 *
 *  @param pError       Error
 */
- (void)deleteAllMessages:(NSError **)pError;

//获取当前登陆账号的所有会话

//会话列表发生变化


//获取会话列表
-(NSMutableArray *)getConversations;

//等等


@end

NS_ASSUME_NONNULL_END
