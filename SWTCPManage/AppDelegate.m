//
//  AppDelegate.m
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import "AppDelegate.h"
#import "SWChatTool.h"
#import <MJExtension.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
     
    
    //TCP握手配置、并连接
    [SWChatTool.shareManager.tcpManager connectSocket];
    
     
//    [SWChatTool.shareManager.tcpManager connectSocketSucessfullWithSendMsg:^Msg * _Nullable(GCDAsyncSocket * _Nonnull socket) {
//        return [Msg createMsgForFirstHand];
//    }];
    
//    重新链接
//    [SWChatTool.shareManager.tcpManager reConnectSocket];
    
    //关闭链接 一般在退出登陆
//    [SWChatTool.shareManager.tcpManager disconnectSocket];
    return YES;
}

 

@end
