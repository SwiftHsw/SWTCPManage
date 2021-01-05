//
//  SWTCPManager.h
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "SWNettySocketMsg.pbobjc.h"
#import <SWKit.h>
#import <ReactiveObjC.h>
#import <MJExtension.h>
#import "Msg+msg_Extension.h"



NS_ASSUME_NONNULL_BEGIN


UIKIT_STATIC_INLINE NSString *iOS_TCPID_HandshakeKEY()
{
    return @"handshake";
}
UIKIT_STATIC_INLINE NSString *iOS_TCPIDKEY()
{
    return @"iOS_TCPID";
}

typedef Msg * _Nullable(^SWTCPConnectSocketSucessfullMsgCallBack)(GCDAsyncSocket * socket);

typedef void(^SWNetRequestTokenOverdueBlock)(BOOL *flag);

typedef void(^SWTCPConnectSocketSucessfullHandle) (void);

typedef NS_ENUM(NSInteger) {
    //未链接
    SWTCPManagerType_NotConnetted = 0,
    //连接中
    SWTCPManagerType_Connecting,
    //连接成功
    SWTCPManagerType_ConnectionOfSuccessful,
    //连接失败
    SWTCPManagerType_ConnectionOfFail,
    
} SWTCPManagerType;

  
 
@protocol SWTCPManagerDelaget;

@interface SWTCPManager : NSObject

@property (nonatomic,copy) NSString *host; //ip

@property (nonatomic,assign) uint16_t port; //端口号

@property (nonatomic,assign) SWTCPManagerType connectType; //链接状态
 
@property (nonatomic,weak) id <SWTCPManagerDelaget> delegate;
  
@property (nonatomic,strong) GCDAsyncSocket *socket;


+ (instancetype)shareManager;
 
+ (instancetype)shareManagerWithHost:(NSString *)host port:(uint16_t)port;
 
/// 连接成功，会索要第一次要发送的内容
/// @param callBack 通过代码块回调
- (void)connectSocketSucessfullWithSendMsg:(SWTCPConnectSocketSucessfullMsgCallBack _Nullable)callBack;

/// 连接成功，会执行该回调
- (void)connectSocketSucessfullWithHandle:(SWTCPConnectSocketSucessfullHandle _Nullable)handle;

/// 直接连接
- (void)connectSocket;

/// 重连成功，会索要第一次要发送的内容
- (void)reConnectSocketWithHost:(NSString *)host port:(uint16_t)port sucessfullWithSendMsg:(SWTCPConnectSocketSucessfullMsgCallBack _Nullable)callBack;

/// 重连成功，会执行该回调
- (void)reConnectSucessfullWithHandle:(SWTCPConnectSocketSucessfullHandle _Nullable)handle;

/// 重连
- (void)reConnectSocket;

/// 断开连接
- (void)disconnectSocket;

/// 发送消息
- (void)sendMsd:(Msg *)message;

/// TokenFlag复位
- (void)reSetupTokenFlag;
/// 写入tokenflag的状态
- (void)setTokenFlag:(BOOL)tokenFlag_;

/// 移除所有未发送的消息
- (void)removeAllUnSentMessagge;

/// 移出去token过期的标识
- (void)removeTokenCodeAndBlock;

/// token过期处理
/// @param tokenCode token过期对应的code
/// @param tokenOverdueBlock 发现token过期时的回调
- (void)addTokenCode:(int32_t)tokenCode tokenOverdue:(SWNetRequestTokenOverdueBlock)tokenOverdueBlock;

@end

 
@protocol SWTCPManagerDelaget <NSObject>

//链接成功回调
- (void)TCPManager:(SWTCPManager *)manager
             socket:(GCDAsyncSocket *)sock
              didConnectToHost:(NSString *)host
              port:(uint16_t)port;

//链接失败回调
- (void)TCPManager:(SWTCPManager *)manager
             socketDidDisconnect:(GCDAsyncSocket *)sock
             withError:(NSError *)err;
//发送数据成功回调
- (void)TCPManager:(SWTCPManager *)manager
              socket:(GCDAsyncSocket *)sock
              didWriteDataWithTag:(long)tag;
//解析正常数据回调
- (void)TCPManager:(SWTCPManager *)manager
              didReadMessage:(Msg *)message;

@end

NS_ASSUME_NONNULL_END
