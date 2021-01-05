//
//  ChatModel.m
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import "ChatMessageModel.h"

@implementation ChatMessageModel
+ (SWMessageType)messageModelTypeWith:(int32_t)type
{
    switch (type){
            
        case 1:
            {
                return SWMessageTypeText;
            }
            break;
        case 2:
            {
                return SWMessageTypeImage;
            }
            break;
        case 3:
            {
                return SWMessageTypeVoice;
            }
            break;
        case 4:
            {
                return SWMessageTypeVideo;
            }
            break;
        case 5:
            {
                return SWMessageTypeNameCard;
            }
            break;
        case 6:
            {
                return SWMessageTypeMessageWithdraw;
            }
            break;
        case 7:
            {
                return SWMessageTypeLocation;
            }
            break;
        case 8:
            {
                return SWMessageTypeFile;
            }
            break;
        case 9:
            {
                return SWMessageTypeSticker;
            }
            break;
        case 10:
            {
                return SWMessageTypeDropMessage;
            }
            break;
        case 11:
            {
            return SWMessageTypeGoupNickname_change;
            }
        case 12:
            {
            return SWMessageTypeNewMemberIntoGroup;
            }
            break;
        case 13:
            {
            return SWMessageTypeMemberGoOutGroup;
            }
            break;
        case 14:
            {
            return SWMessageTypeGroupJinyan;
            }
            break;
        case 15:
            {
            return SWMessageTypeGroupJinAddFriends;
            }
            break;
        case 16:
            {
            return SWMessageTypeGroupOwnChange;
            }
            break;
        case 17:
            {
            return SWMessageTypeGroupOwnTiMembers;
            }
            break;
        case 18:
            {
            return SWMessageTypeAddNewFriend;
            }
            break;
        default:
            {
            return SWMessageTypeUnknown;
            }
            break;
    }
}

+ (ChatMessageModel *)creatMessageModelWithType:(SWMessageType)type
{
    ChatMessageModel *message = [[ChatMessageModel alloc] init];
    message.messageType = type;
    message.ownerTyper = SWMessageOwnerTypeSelf;
    message.date = [NSDate date];
    message.sendState = SWMessageSendIng;
    message.readState = SWMessageReaded;
    message.fromId = @"自己的id" ;
    
    return message;
}
- (Msg *)messageModelToMsg:(ChatConverModel *)conversation
{
    NSString *TCPID = [NSString stringWithFormat:@"%u%lld%u%u",arc4random_uniform(10000),(long long)[NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970,arc4random_uniform(10),arc4random_uniform(99)];
    
    Head *header = [Head message];
    header.fromId = @"自己的id";
    header.timestamp = [NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970 * 1000;
    NSDictionary *dic = @{@"token":@"自己的token",@"messageId":_messageId,iOS_TCPIDKEY():TCPID};
    
    header.extend =  [dic mj_JSONObject];
    header.msgType = conversation.type;
    header.toId = conversation.conversationId;
    
    Msg *mess = [Msg message];
    mess.head = header;
    
    switch (self.messageType){
            
        case SWMessageTypeText:
        {
            header.msgContentType = 1;
            mess.body = self.text;
        }
            break;
        case SWMessageTypeImage:
        {
            header.msgContentType = 2;
            NSDictionary *dic = @{@"url":[NSString stringWithFormat:@"%@",self.imageURL],@"width":@(self.imageWidth),@"height":@(self.imageHeight)};
            mess.body = [dic mj_JSONObject];
        }
            break;
        case SWMessageTypeVoice:
        {
            header.msgContentType = 3;
            NSDictionary *dic = @{@"duration":@((NSInteger)(self.voiceSeconds * 1000)),@"url":[NSString stringWithFormat:@"%@",self.voiceUrl]};
            mess.body = [dic mj_JSONObject];
        }
            break;
        case SWMessageTypeVideo:
        {
            header.msgContentType = 4;
            NSDictionary *dic = @{@"url":[NSString stringWithFormat:@"%@",self.videoRemotePath],@"width":@(self.imageWidth),@"height":@(self.imageHeight),@"duration":@(self.videoDuration)};
            mess.body = [dic mj_JSONObject];
        }
            break;
        case SWMessageTypeNameCard:
        {
            header.msgContentType = 5;
            NSDictionary *dic = @{@"friendId":self.friendId ,
                                  @"nickName":self.nickName ,
                                  @"imgHead":self.imgHead,
                                  @"bcardUrl":self.bcardUrl ,
                                  @"userType":self.userType };
            mess.body = [dic mj_JSONObject];
        }
            break;
        case SWMessageTypeMessageWithdraw:
        {
            header.extend = [@{@"token":@"自己的token",
                               @"messageId":self.messageId,
                               iOS_TCPIDKEY():TCPID,
                               @"msgId":self.msgId } mj_JSONObject];
            header.msgContentType = 6;
        }
            break;
        case SWMessageTypeLocation:
        {
            header.msgContentType = 7;
        }
            break;
        case SWMessageTypeFile:
        {
            header.msgContentType = 8;
            NSDictionary *dic = @{@"filename":self.fileName,@"fileSize":@(self.fileSize),@"url":self.fileUrl };
            mess.body = [dic mj_JSONObject];
        }
            break;
        case SWMessageTypeSticker:
        {
            header.msgContentType = 9;
            mess.body = self.text;
        }
            break;
        default:
        {
        
        }
            break;
    }
    return mess;
}

@end
