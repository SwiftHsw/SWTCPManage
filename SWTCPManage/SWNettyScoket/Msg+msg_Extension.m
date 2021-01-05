//
//  Msg+msg_Extension.m
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import "Msg+msg_Extension.h"


@implementation Msg (msg_Extension)


+ (instancetype)createMsgForFirstHand
{
    Msg *msg = [Msg message];
    msg.head = [Head createHeadForFirstHand];
    return msg;
}

+ (instancetype)createMsgForHeart
{
    Msg *msg = [Msg message];
    msg.head = [Head createHeadForHeart];
    return msg;
}
+ (instancetype)createMsgWithMsgType:(int32_t)msgType msgContentType:(int32_t)msgContentType toId:(NSString *)toId;
{
    Msg *msg = [Msg message];
    msg.head = [Head createHeadWithMsgType:msgType msgContentType:msgContentType toId:toId];
    return msg;
}


- (ChatMessageModel *)msgToMessageModel{
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.head.extend dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSString *messageId = dic[@"messageId"];
    
    ChatMessageModel *model = [ChatMessageModel new];
    model.fromId = self.head.fromId;
    model.msgId = self.head.msgId;
    model.date = [NSDate dateWithTimeIntervalSince1970:(self.head.timestamp / 1000.0)];
    if (self.head.timestamp == 0) {
        model.date = [NSDate dateWithTimeIntervalSinceNow:0];
    }
    model.ownerTyper = [self.head.fromId isEqualToString:@"自己的id"] ? SWMessageOwnerTypeSelf : SWMessageOwnerTypeOther;
    if (messageId) {
        model.messageId = messageId;
    }
    model.messageType =  [ChatMessageModel messageModelTypeWith :self.head.msgContentType];
    model.body = self.body;
    model.extend = self.head.extend;
    
    switch (self.head.msgContentType){
            
        case 1:
            {
                model.text = self.body;
            }
            break;
        case 2:
            {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                model.imageURL = dic[@"url"];
                model.imageWidth = [dic[@"width"] floatValue];
                model.imageHeight = [dic[@"height"] floatValue];
            }
            break;
        case 3:
            {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                model.voiceUrl = dic[@"url"];
                model.voiceSeconds = [dic[@"duration"] integerValue] / 1000;
            }
            break;
        case 4:
            {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                model.videoRemotePath = dic[@"url"];
                model.imageWidth = [dic[@"width"] floatValue];
                model.imageHeight = [dic[@"height"] floatValue];
            }
            break;
        case 5:
            {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                model.nickName = dic[@"nickName"];
                model.imgHead = dic[@"imgHead"];
                model.bcardUrl = dic[@"bcardUrl"];
                model.friendId = dic[@"friendId"];
                model.userType = [dic[@"userType"] stringValue];
            }
            break;
        case 6:
            {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.head.extend dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                model.msgId = dic[@"msgId"];
            }
            break;
        case 7:
            {
                
            }
            break;
        case 8:
            {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                model.fileName = dic[@"filename"];
                model.fileSize = [dic[@"fileSize"] integerValue];
                model.fileUrl = dic[@"url"];
            }
            break;
        case 9:
            {
                model.text = self.body;
            }
            break;
        case 10:
            {

            }
            break;
        case 11:
            {
                model.text = self.body;
                model.note = self.body;
            }
            break;
        case 14:
            {
                model.text = [self.body integerValue] == 2 ? @"2" : @"1";
                model.note = [self.body integerValue] == 2 ? @"2" : @"1";
            }
            break;
        case 15:
            {
                model.text = self.body;
                model.note = self.body;
            }
            break;
        case 12:
        case 13:
        case 16:
        case 17:
            {
                model.note = self.body;
                model.text = self.body;
            }
            break;
        case 18:{
            model.note = self.body;
            model.text = self.body;
            if ([self.body integerValue] == 1) {
                model.messageType = SWMessageTypeAddNewFriendSuccess;
            }
        }
            break;
        default:
        {
            model.text =  @"UnKnow" ;
            model.note =  @"UnKnow" ;
        }
            break;
    }
    
    return model;
}
@end


@implementation Head (head_Extension)

+ (instancetype)createHeadForFirstHand
{
    NSString *TCPID = [NSString stringWithFormat:@"%u%lld%u%u",arc4random_uniform(10000),(long long)[NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970,arc4random_uniform(10),arc4random_uniform(99)];
    
    Head *head = [Head message];
    head.msgType = 1001;
    head.fromId = @"用户ID";
    head.timestamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    NSDictionary *data  = @{@"token":@"用户Token",iOS_TCPIDKEY():TCPID};
    head.extend =  [data mj_JSONObject];
    return head;
}

+ (instancetype)createHeadForHeart
{
    NSString *TCPID = [NSString stringWithFormat:@"%u%lld%u%u",arc4random_uniform(10000),(long long)[NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970,arc4random_uniform(10),arc4random_uniform(99)];
    
    Head *head = [Head message];
    head.msgType = 1002;
    head.fromId = @"用户ID";
    head.timestamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    //用户Token
    NSDictionary *data  = @{@"token":@"用户Token",iOS_TCPIDKEY():TCPID};
    head.extend =  [data mj_JSONObject];
    return head;
}
+ (instancetype)createHeadWithMsgType:(int32_t)msgType msgContentType:(int32_t)msgContentType toId:(NSString *)toId
{
    NSString *TCPID = [NSString stringWithFormat:@"%u%lld%u%u",arc4random_uniform(10000),(long long)[NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970,arc4random_uniform(10),arc4random_uniform(99)];
    
    Head *head = [Head message];
    head.msgType = msgType;
    head.msgContentType = msgContentType;
    head.fromId = @"用户ID";
    head.toId = toId;
    head.timestamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    NSDictionary *data  = @{@"token":@"用户Token",iOS_TCPIDKEY():TCPID};
    head.extend =  [data mj_JSONObject];
    return head;
}
@end
