# SWTCPManage
im初始系统，基于CocoaAsyncSocket+Protobuf的原生socket封装，模拟完成拆包、解包的问题，完成基本的会话、tcp握手链接等封装，使用方便。如果对你有帮助，求一个star，谢谢～
 
 //直接连接
 [SWChatTool.shareManager.tcpManager connectSocket];
 
 //TCP握手配置、并连接
    [SWChatTool.shareManager.tcpManager connectSocketSucessfullWithSendMsg:^Msg * _Nullable(GCDAsyncSocket * _Nonnull socket) {
        return [Msg createMsgForFirstHand];
    }];
 
//    重新链接
     [SWChatTool.shareManager.tcpManager reConnectSocket];
 
 //关闭链接 一般在退出登陆
   [SWChatTool.shareManager.tcpManager disconnectSocket];



///会话管理者
@property (nonatomic , strong) SWConversationManager *conversationManager;
  
/// TCP管理者
@property (nonatomic , strong) SWTCPManager *tcpManager;



//使用发送逻辑

//1. 无感加载，在发送期间使用加载动画 load，加到聊天界面数组里面作为列表展示。

//2. 发送时作为Msg对象发送，如果存在文件上传先把文件上传逻辑实现，然后返回路径再发送
 
//3. 通过会话发送数据到im服务器
 
//音频发送

ChatMessageModel *message = [ChatMessageModel creatMessageModelWithType:SWMessageTypeVoice];
message.voiceSeconds = 1;
message.voicePath = [[NSString documentDirectory] lastPathComponent];
message.voiceSourcePath = [NSString documentDirectory];

[self.conversation sendMessageModel:message
success:^(ChatMessageModel * _Nonnull messageModel) {
    
} fail:^(ChatMessageModel * _Nonnull messageModel) {
    
}];


//文本
 
ChatMessageModel *message2 = [ChatMessageModel creatMessageModelWithType:SWMessageTypeText];
message2.text =  @"我是文本，把我发出去吧" ;
[self.conversation sendMessageModel:message2
success:^(ChatMessageModel * _Nonnull messageModel) {
    
} fail:^(ChatMessageModel * _Nonnull messageModel) {
    
}];


//表情
 

//模拟数据
NSDictionary *dic = @{@"data":@{@"chartlet": @"faceName",@"catalog":@"catalog"},@"type":@"3",@"content":@"faceID"};
ChatMessageModel *message3 = [ChatMessageModel creatMessageModelWithType:SWMessageTypeSticker];
message3.text = [dic mj_JSONObject];
[self.conversation sendMessageModel:message3
success:^(ChatMessageModel * _Nonnull messageModel) {
    
} fail:^(ChatMessageModel * _Nonnull messageModel) {
    
}];


//文件
ChatMessageModel *message4 = [ChatMessageModel creatMessageModelWithType:SWMessageTypeFile];
message4.fileName = @"文件名";
NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"路径/%@",@"文件名"]];
message4.fileSize = [data length];
[self.conversation sendMessageModel:message4
success:^(ChatMessageModel * _Nonnull messageModel) {
    
} fail:^(ChatMessageModel * _Nonnull messageModel) {
    
}];

//图片
ChatMessageModel *message5 = [ChatMessageModel creatMessageModelWithType:SWMessageTypeImage];
message5.imagePath = @"imagePath" ;
message5.imageWidth = [UIImage new].size.width;
message5.imageHeight = [UIImage new].size.height;
[self.conversation sendMessageModel:message5
success:^(ChatMessageModel * _Nonnull messageModel) {
    
} fail:^(ChatMessageModel * _Nonnull messageModel) {
    
}];

//视频
 
ChatMessageModel *message6 = [ChatMessageModel creatMessageModelWithType:SWMessageTypeVideo];
message6.videoCoverLocationPath = @"视频封面地址";
message6.imageWidth = [UIImage new].size.width;
message6.imageHeight = [UIImage new].size.height;
message6.videLocalSourcePath = @"视频路径地址";
message6.videoDuration = 10;//视频时长
[self.conversation sendMessageModel:message6
success:^(ChatMessageModel * _Nonnull messageModel) {
    
} fail:^(ChatMessageModel * _Nonnull messageModel) {
    
}];


//群拓展

//发送消息
//例如退出群
Msg *message7 = [Msg createMsgWithMsgType:2002 msgContentType:17 toId:@"群id"];
message7.body = [@{@"Executor":@"Executor",@"Executee":@"Executee"} mj_JSONObject];
NSMutableDictionary *ssssDis = [[NSJSONSerialization JSONObjectWithData:[message7.head.extend dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil] mutableCopy];
[ssssDis setValue:@"gmid" forKey:@"gmID"];
message7.head.extend = [ssssDis mj_JSONObject];
[SWChatTool.shareManager.tcpManager sendMsd:message7];
