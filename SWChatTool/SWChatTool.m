//
//  SWChatTool.m
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import "SWChatTool.h"

static SWChatTool *instance = nil;

@interface SWChatTool()
<
  SWTCPManagerDelaget
>

@end
@implementation SWChatTool


+(instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[SWChatTool alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //监听某些数据变化可使用RAC
        
    }
    return self;
}


- (void)removeAllManager
{
    [self.tcpManager disconnectSocket];
    [self.tcpManager removeAllUnSentMessagge];
    [self.tcpManager removeTokenCodeAndBlock];
//    [self.conversationManager closeAllConversations]; //移除所有会话
//    [self.dataManager closeCurrentUserDB]; 关闭数据库
    _conversationManager = nil;
    _dataManager = nil;
}

/// 清除图片、视频、文件
- (void)clearAllRecordFileForIIM
{
    //删除图片、视频、文件
    [NSFileManager.defaultManager removeItemAtURL:[NSURL fileURLWithPath:@"path路径"] error:nil];
     
}


#pragma mark - SWTCPManagerDelaget


//链接成功回调
- (void)TCPManager:(SWTCPManager *)manager
             socket:(GCDAsyncSocket *)sock
              didConnectToHost:(NSString *)host
              port:(uint16_t)port{
    SWLog(@"%@....%hu",host,port);
     
    
}

//链接失败回调
- (void)TCPManager:(SWTCPManager *)manager
             socketDidDisconnect:(GCDAsyncSocket *)sock
         withError:(NSError *)err{
    
    
    
}
//发送数据成功回调
- (void)TCPManager:(SWTCPManager *)manager
              socket:(GCDAsyncSocket *)sock
didWriteDataWithTag:(long)tag{
    
    
    
    
}
//解析正常数据回调
- (void)TCPManager:(SWTCPManager *)manager
    didReadMessage:(Msg *)message{
    
    //提取来自别人发的信息（toId 和 自己的Id进行比较）
    //优先获取自己的发送出去的信息（如果是群，也会走这个方法）
    //接受到自己发的信息的回调
    if ([message.head.fromId isEqualToString:@"自己的ID"]) {
        SWLog(@"开始更新自己发的消息")
        #pragma mark - 接受到消息后 回传接收成功 (勿动)
        Msg *m = [message copy];
        m.head.msgType = 1009;
        [SWTCPManager.shareManager sendMsd:m];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //获取我发送的会话
            //获取会话ID
            NSString *conversationId = message.head.toId;
            
            //自己主动退群不做任何操作、添加好友发送消息回调，不做处理
            if (message.head.msgContentType == 13 ||
                (message.head.msgContentType == 18 && [message.body integerValue] != 1)) {
                //主动更新会话列表显示
//                [SWChatTool.shareManager.conversationManager updateConversationsForUnReadNum];
                return;
            }
            
            //提取会话(首页会话会自动处理，这里只做数据存储)
//            SWConversationModel *conversation = [SWChatTool.shareManager.conversationManager getOneConversationWithConversationId:conversationId type:message.head.msgType isSavaIntoDB:YES];
            
            //会话前移
//            [SWChatTool.shareManager.conversationManager moveConversationToFirst:conversation];
            
            //更新本地数据库
//            [conversation updateSelfSendMessageModelInConversation:message handle:^(ZXMessageModel * _Nonnull messageModel) {
//                messageModel.sendState = (message.head.statusReport == 0 || message.head.statusReport == 1) ? ZXMessageSendSuccess : ZXMessageSendFail;
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//
//                    if (conversation.receiveSelfNeedUpdateMessageBlock) conversation.receiveSelfNeedUpdateMessageBlock(messageModel);
//
//                    //主动更新自己发送的消息状态
//                    [conversation.receiveSelfNeedUpdateMessageSinal sendNext:messageModel];
//                    [conversation.receiveSelfNeedUpdateMessageSinal sendCompleted];
//                });
//            }];
            
            //群处理
//            [self dealGroupInfoWithMsg:message conversation:conversation];
            
            //并主动更新会话列表显示
//            [SWChatTool.shareManager.conversationManager updateConversationsForUnReadNum];
        });
        
    }
    //新好友添加提示
    else if (message.head.msgContentType == 18 && [message.body integerValue] == 3)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.newAddFriendCount ++;
            //计算好友提示的个数
//            [SWUserDefaultTool setnewAddFriendCount:self.newAddFriendCount];
        });
    }
    //单聊判断，群聊判断
    else if ([message.head.toId isEqualToString:@"自己的id"] ||
        message.head.msgType == 2002) {
        
        //获取会话ID
        NSString *conversationId = message.head.msgType == 2001 ? message.head.fromId : message.head.toId;
        
        //过滤拒绝添加好友的消息
        if (message.head.msgContentType == 18 && [message.body integerValue] == 2) {
            return;
        }
        
        //提取会话(首页会话会自动处理，这里只做数据存储)
//        SWConversationModel *conversation = [SWChatTool.shareManager.conversationManager getOneConversationWithConversationId:conversationId type:message.head.msgType isSavaIntoDB:YES];
//        conversation.recordNum ++;
//        [conversation updataConversationSelf];
        

        //更新本地数据库
//        [conversation insertOrUpdateReceivedMessageModelInConversation:message];
        
        //会话前移
//        [SWChatTool.shareManager.conversationManager moveConversationToFirst:conversation];
        
        //并主动更新会话列表显示
//        [SWChatTool.shareManager.conversationManager updateConversationsForUnReadNum];
        
        //更新数据库
        //群数据更新操作位置，根据消息类型，获取数据
        //群聊处理
        if (message.head.msgType == 2002)
        {
//            [self dealGroupInfoWithMsg:message conversation:conversation];
        }
        //单聊
        else {
//            [self dealSingleChatWithMsg:message conversation:conversation];
        }
    }
    
    //其他消息
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            //针对好友更新
            //发送通知
        });
        
        SWLog(@"其他消息-----待处理:%@",message);
    }
}


#pragma mark - get
- (SWConversationManager *)conversationManager
{
    if (_conversationManager == nil) {
        _conversationManager = [SWConversationManager new];
    }
    return _conversationManager;;
}

- (NSObject *)dataManager
{
    if (_dataManager == nil) {
        _dataManager = [NSObject new];
     
    }
    return _dataManager;
}

- (SWTCPManager *)tcpManager
{
    if (_tcpManager == nil) {
        _tcpManager = [SWTCPManager shareManager];
        _tcpManager.delegate = self;
    }
    return _tcpManager;
}




@end
