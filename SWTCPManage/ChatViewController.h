//
//  ChatViewController.h
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import <UIKit/UIKit.h>
#import "ChatConverModel.h"
#import "ChatMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : SWSuperViewContoller
/// 会话
@property (nonatomic , strong ) ChatConverModel *conversation;


/// 创建会话
+ (instancetype)chatControllerWithConversationModel:(ChatConverModel *)conversation;


@end

NS_ASSUME_NONNULL_END
