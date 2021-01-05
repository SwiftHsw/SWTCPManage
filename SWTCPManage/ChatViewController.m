//
//  ChatViewController.m
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import "ChatViewController.h"
#import <MJExtension.h>
#import "SWChatTool.h"
@interface ChatViewController ()

@end

@implementation ChatViewController


+ (instancetype)chatControllerWithConversationModel:(ChatConverModel *)conversation
{
    ChatViewController *vc = [ChatViewController new];
    vc.conversation = conversation;
    vc.conversation.priority = 1;
    return vc;
}

- (void)dealloc{
    
    
  
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)senMessage{
    
    //发送逻辑
    
    //1. 加到self的数组里面作为列表展示。
    
    //2. 无感加载，在发送期间使用加载动画 load
    
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
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
