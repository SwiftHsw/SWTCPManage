//
//  ChatConverModel.m
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import "ChatConverModel.h"
#import "ChatMessageModel.h"

@implementation ChatConverModel


- (void)sendMessageModel:(ChatMessageModel *)messageModel
                 success:(void (^)(ChatMessageModel *messageModel))success
                    fail:(void (^)(ChatMessageModel *messageModel))fail{
    
    //插入数据库备份(等待处理发送状态)
//    [self insertOrReplaceMessageModelToConversation:messageModel];
     
    //处理消息，如有需要上传文件，必须提交完上传后，在发送消息
    [self chatUploadFileWithMessage:messageModel completeHandle:^(ChatMessageModel *message) {
         
        //失败，则刷新
        if (message.sendState == SWMessageSendFail)
        {
            if (fail) fail(message);
        }
        //成功就发送
        else
        {
            [SWTCPManager.shareManager sendMsd:[message messageModelToMsg:self]];
            if (success) success(message);
        }
    }];
    
    
}

- (void)chatUploadFileWithMessage:(ChatMessageModel *)message completeHandle:(void (^)(ChatMessageModel *message))handle
{
    //没有代码块回调直接报错
    if (!handle) {
        [NSException exceptionWithName:@"必须有回调" reason:@"请添加回调" userInfo:nil];
        return;
    }

    //文本
    if (message.messageType == SWMessageTypeText ||
        message.messageType == SWMessageTypeSticker ||
        message.messageType == SWMessageTypeMessageWithdraw ||
        message.messageType == SWMessageTypeNameCard) {
        handle(message);
    }
    else
    {
        //图片
        if (message.messageType == SWMessageTypeImage)
        {
            //判断是否已经提交过
            if (message.imageURL) {
                handle(message);
                return;
            }
             
            //上传图片逻辑操作
             
        }
        //视频
        else if (message.messageType == SWMessageTypeVideo)
        {
            //判断是否已经提交过
            if (message.videoRemotePath) {
                handle(message);
                return;
            }
            //上传视频文件逻辑操作
        }
        //录音
        else if (message.messageType == SWMessageTypeVoice)
        {
            //判断是否已经提交过
            if (message.videoRemotePath) {
                handle(message);
                return;
            }
            //上传录音文件逻辑操作
        }
        //文件
        else if (message.messageType == SWMessageTypeFile) {
            
            if (message.fileUrl) {
                handle(message);
                return;
            }
            //上传文件逻辑操作
            
        }
    }
    //逻辑，上传成功后赋值给imageURL
    // message.imageURL = 服务器地址
    // 所有上传成功后回调block handle(message);
    
}
@end
