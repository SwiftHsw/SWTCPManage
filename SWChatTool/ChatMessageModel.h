//
//  ChatModel.h
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ChatConverModel.h"
#import "Msg+msg_Extension.h"
#import <MJExtension.h>


/**
 *  消息拥有者
 */
typedef NS_ENUM(NSUInteger, SWMessageOwnerType){
    SWMessageOwnerTypeUnknown = 0,  // 未知的消息拥有者
    SWMessageOwnerTypeSelf = 1,     // 自己发送的消息
    SWMessageOwnerTypeOther = 2,    // 接收到的他人消息
};

/**
 *  消息类型
 */
typedef NS_ENUM(NSInteger, SWMessageType){
    SWMessageTypeSafeContentNotify = -1,// 双端安全加密通知
    SWMessageTypeUnknown = 0,           // 未知
    SWMessageTypeText = 1,              // 文字
    SWMessageTypeImage = 2,             // 图片
    SWMessageTypeVoice = 3,             // 语音
    SWMessageTypeVideo = 4,             // 视频
    SWMessageTypeFile = 5,              // 文件
    SWMessageTypeLocation = 6,          // 位置
    SWMessageTypeNameCard = 7,          // 名片
    SWMessageTypeSticker = 8,           // 贴图表情
    SWMessageTypeNoteContent = 9,       // 提示类型
    SWMessageTypeMessageWithdraw = 10,  // 消息撤回

    SWMessageTypeDropMessage = 12,      // 消息双向删除
    
    SWMessageTypeGoupNickname_change = 11,      //群昵称变更
    SWMessageTypeNewMemberIntoGroup = 13,       //群新将入提示信息
    SWMessageTypeMemberGoOutGroup = 14,         //群成员退群
    SWMessageTypeGroupJinyan = 15,              //群禁言
    SWMessageTypeGroupJinAddFriends = 16,       //群禁止加好友
    SWMessageTypeGroupOwnChange = 17,           //群主转让
    SWMessageTypeGroupOwnTiMembers = 18,        //群踢成员
    SWMessageTypeAddNewFriend = 19,             //添加好友
    
    SWMessageTypeMessgeInChatTime = 20, //时间展示
    SWMessageTypeAddNewFriendSuccess = 21,      //添加好友成功
    SWMessageTypeSensitiveWordsExist = 22,      //存在敏感词
    SWMessageTypeBlackList = 23,                //被对方拉入黑名单
    SWMessageTypeSendFriendVerification = 24,   //需要发送好友验证
    SWMessageTypeNoGroupMembers = 25,           //非群成员
    SWMessageTypeSendMessageBeJinYan = 26,      //发送的消息属于禁言状态
    SWMessageTypeIsNotFriends = 27,             //未添加对方好友
};
/**
 *  消息发送状态
 */
typedef NS_ENUM(NSUInteger, SWMessageSendState){
    SWMessageSendIng = 0,           // 消息发送中
    SWMessageSendSuccess = 1,       // 消息发送成功
    SWMessageSendFail = 2,          // 消息发送失败
};

/**
 *  消息读取状态
 */
typedef NS_ENUM(NSUInteger, SWMessageReadState) {
    
    SWMessageUnRead = 0,            // 消息未读
    SWMessageReaded = 1,            // 消息已读
};

/**
 *  消息文件下载状态
 */
typedef NS_ENUM(NSUInteger, SWMessageFileDownStatus) {
    
    SWMessageFileDownStatus_UnDown = 0,            //未下载
    SWMessageFileDownStatus_Downning = 1,          //正在下载
    SWMessageFileDownStatus_DownSuccess = 2,       //下载完成
    SWMessageFileDownStatus_DownFail = 3,          //下载失败
};
/**
   翻译状态
*/
typedef NS_ENUM(NSInteger, SWMessageTranslateType){
    SWMessageTranslateType_No = 0,      //未翻译
    SWMessageTranslateType_Ing = 1,     //正在翻译
    SWMessageTranslateType_SUCCESS = 2, //翻译成功
    SWMessageTranslateType_FAIL = 3,    //翻译失败
};


NS_ASSUME_NONNULL_BEGIN

@interface ChatMessageModel : NSObject

@property (nonatomic , copy) NSString *fromId;                      //当前消息对应的用户ID
@property (nonatomic , copy) NSString *msgId;                       //服务器上消息对应的ID
@property (nonatomic , copy) NSString *messageId;                   //消息ID，本地对应的ID

@property (nonatomic, strong) NSDate *date;                         // 发送时间
@property (nonatomic, strong) NSString *dateString;                 // 格式化的发送时间
@property (nonatomic, strong) NSString *dateStringForCell;           // 格式化的发送时间(聊天页使用)

@property (nonatomic, assign) SWMessageType messageType;             // 消息类型
@property (nonatomic, assign) SWMessageOwnerType ownerTyper;         // 发送者类型
@property (nonatomic, assign) SWMessageReadState readState;         // 读取状态
@property (nonatomic, assign) SWMessageSendState sendState;         // 发送状态


@property (nonatomic, assign) CGSize messageSize;                   // 消息大小
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) NSString *cellIndentify;

@property (nonatomic, strong) NSString *body;                       // 源数据
@property (nonatomic, strong) NSString *extend;                     // 源数据扩展


#pragma mark - 文字消息
@property (nonatomic, strong) NSString *text;                       // 文字信息
@property (nonatomic, strong) NSMutableAttributedString *attrText;   // 格式化的文字信息
@property (nonatomic, strong) NSString *translateText;               // 翻译后的文字信息

@property (nonatomic , assign) BOOL isTranslate;                    //是否已翻译
@property (nonatomic , assign) BOOL isShowTranslated;               //是否显示翻译
@property (nonatomic , assign) SWMessageTranslateType translateType; //翻译状态
@property (nonatomic, assign) CGSize translateMessageSize;          // 翻译消息大小

#pragma mark - 图片消息
@property (nonatomic, strong , readonly) UIImage *image;             // 图片（按照相对路径去获取图片）
@property (nonatomic, strong) NSString *imagePath;                  // 本地图片名
@property (nonatomic, strong) NSString *imageURL;                   // 网络图片URL

#pragma mark - 视频
@property (nonatomic, strong , readonly) UIImage *videoCoverImage;   // 视频封面
@property (nonatomic, copy) NSString *videoCoverLocationPath;        // 视频封面本地地址
@property (nonatomic, copy) NSString *videoRemotePath;              // 视频远程地址
@property (nonatomic, copy) NSString *videoLocalPath;               // 视频本地地址
@property (nonatomic, assign) NSUInteger videoDuration;               // 视频时长(毫秒)

@property (nonatomic, copy) NSString *videLocalSourcePath;          // 视频本地地址

///图片和视频共用
@property (nonatomic, assign) CGFloat imageWidth;                   // 网络图片/视频 宽度
@property (nonatomic, assign) CGFloat imageHeight;                  // 网络图片/视频 高度

#pragma mark - 位置消息
@property (nonatomic, strong) UIImage *locationImage;               //位置消息图片
@property (nonatomic, copy) NSString *locationImageRemotePath;       // 位置消息图片远程地址
@property (nonatomic, copy) NSString *locationImagePath;            // 位置消息图片本地地址
@property (nonatomic, assign) CLLocationDegrees latitude;           //经度
@property (nonatomic, assign) CLLocationDegrees longitude;          //维度
@property (nonatomic, strong) NSString *address;                    // 地址

#pragma mark - 语音消息
@property (nonatomic, assign) NSUInteger voiceSeconds;              // 语音时间
@property (nonatomic, strong) NSString *voiceUrl;                   // 网络语音URL
@property (nonatomic, strong) NSString *voicePath;                  // 本地语音名
@property (nonatomic, copy) NSString *voiceSourcePath;              // 语音本地地址源
@property (nonatomic, assign) BOOL isPlay;                          // 是否正在播放

#pragma mark - 个人名片
@property (nonatomic, copy) NSString *bcardUrl;              // 个人明信片点击地址
@property (nonatomic, copy) NSString *imgHead;               // 头像
@property (nonatomic, copy) NSString *nickName;              // 昵称
@property (nonatomic, copy) NSString *friendId;              // 分享人ID
@property (nonatomic, copy) NSString *userType;              // 分享人身份标识（1：普通用户  2：客服）

#pragma mark - 文件
@property (nonatomic, copy) NSString *fileName;                     // 文件名
@property (nonatomic, assign) NSInteger fileSize;                   // 文件大小
@property (nonatomic, copy) NSString *fileUrl;                      // 文件下载地址
@property (nonatomic, copy) NSString *fileLocationPath;              // 文件本地地址
@property (nonatomic , assign) SWMessageFileDownStatus downStatus;   //文件下载状态
@property (nonatomic , assign) CGFloat downProgress;                //文件下载进度
@property (nonatomic , strong) NSURLSessionDownloadTask *downFileTask;  //下载任务

#pragma mark - 扩展
@property (nonatomic , copy) NSString *note;                 //扩展内容


/// 获取消息类型
+ (SWMessageType)messageModelTypeWith:(int32_t)type;

/// 创建要发送的MessageModel
+ (ChatMessageModel *)creatMessageModelWithType:(SWMessageType)type;

/// ChatMessageModel转Msg(会话发送消息，必须通过这个方法，转Msg)
- (Msg *)messageModelToMsg:(ChatConverModel *)conversation;


@end

NS_ASSUME_NONNULL_END
