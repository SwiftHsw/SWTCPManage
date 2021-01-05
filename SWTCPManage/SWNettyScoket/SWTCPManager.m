//
//  SWTCPManager.m
//  SWTCPManage
//
//  Created by mac on 2021/1/5.
//

#import "SWTCPManager.h"
#import "Msg+msg_Extension.h"

#define HTTP_IP                         @"3.1.92.88"
#define HTTP_PORT                        6006



@interface SWTCPManager ()

<
  GCDAsyncSocketDelegate
>

//主动跟外部获取握手消息内容
@property (nonatomic , copy) SWTCPConnectSocketSucessfullMsgCallBack connectSocketSucessfullMsgCallBack;
//链接成功回调属性
@property (nonatomic , copy) SWTCPConnectSocketSucessfullHandle connectSocketSucessfullWithHandle;

///是否握手成功(只看链接后，发送握手消息，接受服务端的结果做处理)
@property (nonatomic , assign) BOOL isTheHandshakeSuccessful;
///是否主动断开
@property (nonatomic , assign) BOOL isInitiativeDisconnectSocket;
///等待发送的消息
@property (nonatomic , strong) NSMutableDictionary<NSString * , Msg *> *msgDataSource;


/// token过期的code字段
@property (nonatomic , assign) int32_t tokenCode;

/// token过期回调
@property (nonatomic , copy) SWNetRequestTokenOverdueBlock tokenOverdueBlock;

///接收到的数据拼接
@property (nonatomic , strong) NSMutableData *receiveData;

//处理心跳机制
@property (nonatomic , strong) NSThread *thread;
@property (nonatomic , strong) NSTimer *timer;

@end


static SWTCPManager *instance = nil;


@implementation SWTCPManager

+ (instancetype)shareManager{
    return  [self shareManagerWithHost:HTTP_IP port:HTTP_PORT];
}

+ (instancetype)shareManagerWithHost:(NSString *)host port:(uint16_t)port{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[SWTCPManager alloc]init];
            instance.host = host;
            instance.port = port;
            instance.isTheHandshakeSuccessful = instance.isInitiativeDisconnectSocket = NO;
            //创建socket
            instance.socket = [[GCDAsyncSocket alloc]initWithDelegate:instance delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
            
            
        }
        
    });
    
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

- (instancetype)init{
    if ([super init]) {
         //监听链接状态
        @weakify(self);
        [RACObserve(self, connectType) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            //链接成功
            if (self.connectType == 2) {
                //主动发送握手消息
                [self sendHandshakeMessages:self.socket];
            }else if(self.connectType == 0){
                if (self.isTheHandshakeSuccessful) self.isTheHandshakeSuccessful = NO;
            }
            
        }];
        
    }
    return self ;
}

- (void)connectSocketSucessfullWithSendMsg:(SWTCPConnectSocketSucessfullMsgCallBack _Nullable)callBack{
    
    self.connectSocketSucessfullMsgCallBack = callBack;
    [self connectSocket];
    
}

- (void)connectSocketSucessfullWithHandle:(SWTCPConnectSocketSucessfullHandle _Nullable)handle{
    self.connectSocketSucessfullWithHandle = handle;
    [self connectSocket];
}

- (void)reConnectSucessfullWithHandle:(SWTCPConnectSocketSucessfullHandle)handle{
    self.connectSocketSucessfullWithHandle = handle;
    [self reConnectSocket];
}

- (void)reConnectSocketWithHost:(NSString *)host port:(uint16_t)port sucessfullWithSendMsg:(SWTCPConnectSocketSucessfullMsgCallBack)callBack{
    self.host = host;
    self.port = port;
    self.connectSocketSucessfullMsgCallBack = callBack;
    [self reConnectSocket];
}

#pragma mark - 直接链接
- (void)connectSocket{
    if (!self.socket.isConnected) {
        if (self.connectType != 1) {
            //链接中
            self.connectType = 1;
        }
        //链接
        NSError *error = nil;
        self.isInitiativeDisconnectSocket = NO;
        [self.socket connectToHost:self.host onPort:self.port withTimeout:-1 error:&error];
        if (error) {
            SWLog(@"%@",error);return;
        }
    }
}
#pragma mark - 重新链接
- (void)reConnectSocket{
    [self disconnectSocket];
    if (!self.socket) {
        self.socket = [[GCDAsyncSocket alloc]initWithDelegate:instance delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    [self connectSocket];
}

#pragma mark - 关闭链接
-(void)disconnectSocket{
    if (self.socket.isConnected) {
        
        _timer.fireDate = [NSDate distantFuture];
        [_timer invalidate];
        _timer = nil;
        [_thread cancel];
        _thread = nil;
        
        if (self.connectType != 0) {
            self.connectType = 0;
        }
        self.isInitiativeDisconnectSocket = true;
        [self.socket disconnect];
    }
}
#pragma mark - 发送消息
- (void)sendMsd:(Msg *)message{
    
    //已经链接
    if (self.socket.isConnected) {
        //校验是否握手成功
        if (self.isTheHandshakeSuccessful == YES) {
            //成功
            //转字典
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[message.head.extend dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            //添加正常的消息到等待区
            if (message.head.msgType == 2001 || message.head.msgType == 2002) {
                [self.msgDataSource setObject:message forKey:dic[iOS_TCPIDKEY()]];
            }
            //发送消息发送成功回执 （message.head.msgType == 1009）
            else if (message.head.msgType == 1009) {
                [self.msgDataSource removeObjectForKey:dic[iOS_TCPIDKEY()]];
//               SWLog(@"msgDataSource:%@",self.msgDataSource);
            }
            //token没有过期时
            if (!tokenFlag) {
                [self sendProbufData:[message data] CommandId:message.head.msgType];
            }
        }else{
            //失败 继续发送握手消息
            [self sendHandshakeMessages:self.socket];
        }
        
    }else{
        //未链接
        @weakify(self);
        [self connectSocketSucessfullWithHandle:^{
            @strongify(self);
            self.connectSocketSucessfullWithHandle = nil;
            [self sendMsd:message];
        }];
        
    }
    
}


#pragma mark - 发送握手消息
- (void)sendHandshakeMessages:(GCDAsyncSocket *)sock{
     
    if (self.connectSocketSucessfullMsgCallBack && !self.isTheHandshakeSuccessful) {
        Msg *message = self.connectSocketSucessfullMsgCallBack(sock);
        SWLog(@"握手消息Message%@",message);
        [self.msgDataSource setObject:message forKey:iOS_TCPID_HandshakeKEY()];
        [self sendProbufData:message.data CommandId:message.head.msgType];
    }
}
- (void)addTokenCode:(int32_t)tokenCode tokenOverdue:(SWNetRequestTokenOverdueBlock)tokenOverdueBlock
{
    self.tokenCode = tokenCode;
    self.tokenOverdueBlock = tokenOverdueBlock;
}
#pragma mark - 重新发送未成功的数据
- (void)reSendAllMessage
{
    @weakify(self);
    SWLog(@"重新所有未发送成功的数据")
    [self.msgDataSource.allValues.rac_sequence.signal subscribeNext:^(Msg * _Nullable x) {
        @strongify(self);
        NSMutableDictionary *dic = [[NSJSONSerialization JSONObjectWithData:[x.head.extend dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil] mutableCopy];
            [dic setValue:@"写入一个access_token" forKey:@"token"];
        x.head.extend = [dic mj_JSONObject]; //转模型
        [self sendMsd:x];
    }];
}

#pragma mark - GCDAsyncSocketDelegate
//链接成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    SWLog(@"链接成功：%@",sock);
    
    if (self.connectType != 2) {
        self.connectType = 2;
    }
    
    //链接成功时，执行代码块
    if (self.connectSocketSucessfullWithHandle) self.connectSocketSucessfullWithHandle();
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(TCPManager:socket:didConnectToHost:port:)])
    {
        [self.delegate TCPManager:self socket:sock didConnectToHost:host port:port];
    }
}

//链接失败
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err)
    {
        if (self.connectType != 3) {
            self.connectType = 3;
        }
         
        //重连
        //非用户主动断开，全部重新链接
        if (!self.isInitiativeDisconnectSocket)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reConnectSocket];
            });
        }
        else
        {
            SWLog(@"其他情况断开");
        }
    }
    else
    {
        SWLog(@"正常断开");
        if (self.connectType != 0) {
            self.connectType = 0;
        }
        [_thread cancel];
        _thread = nil;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(TCPManager:socketDidDisconnect:withError:)])
    {
        [self.delegate TCPManager:self socketDidDisconnect:sock withError:err];
    }
}

//发送数据成功
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    SWLog(@"发送数据成功:%@  tag:%ld",sock,tag);
    //发送完数据循环读取，-1不设置超时
    [sock readDataWithTimeout:-1 tag:tag];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(TCPManager:socket:didWriteDataWithTag:)])
    {
        [self.delegate TCPManager:self socket:sock didWriteDataWithTag:tag];
    }
}



static BOOL tokenFlag = NO;

- (void)reSetupTokenFlag{
    [self setTokenFlag:NO];
}
- (void)setTokenFlag:(BOOL)tokenFlag_
{
    tokenFlag = tokenFlag_;
}

- (void)removeAllUnSentMessagge
{
    [self.msgDataSource removeAllObjects];
}
- (void)removeTokenCodeAndBlock{
    self.tokenCode = -1000;
    self.tokenOverdueBlock = nil;
}


#pragma mark - 重点部分 拆包解包模块
//读取数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //发送完数据循环读取，-1不设置超时
//    [sock readDataWithTimeout:-1 tag:tag];
    
    [self.receiveData appendData:data];
        
    //读取data的头部占用字节 和 从头部读取内容长度
    //验证结果：数据比较小时头部占用字节为1，数据比较大时头部占用字节为2
    int32_t headL = 0;
    int32_t contentL = [self getContentLength:self.receiveData withHeadLength:&headL];
    
    if (contentL < 1){
        [sock readDataWithTimeout:-1 tag:0];
        return;
    }
    
    //拆包情况下：继续接收下一条消息，直至接收完这条消息所有的拆包，再解析
    if (headL + contentL > self.receiveData.length){
        [sock readDataWithTimeout:-1 tag:0];
        return;
    }
    
    //当receiveData长度不小于第一条消息内容长度时，开始解析receiveData
    [self parseContentDataWithHeadLength:headL withContentLength:contentL];
}


#pragma mark - private methods  辅助方法
- (void)sendProbufData:(NSData *)data
             CommandId:(long)commandId {
    NSMutableData *protobufData = [[NSMutableData alloc] init];

    // data
    [protobufData appendData:[self dataWithRawVarint32:data.length]];
    [protobufData appendData:data];

    // 写入数据
    [self.socket writeData:protobufData withTimeout:-1 tag:commandId];
}
//进行128编码
-(NSMutableData *)dataWithRawVarint32:(int64_t)value
{
    NSMutableData *valData = [[NSMutableData alloc] init];

    while (true) {
        if ((value & ~0x7F) == 0) {//如果最高位是0，只要一个字节表示
            [valData appendBytes:&value length:1];
            break;
        } else {
            int valChar = (value & 0x7F) | 0x80;//先写入低7位，最高位置1

            [valData appendBytes:&valChar length:1];
            value = value >> 7;//再写高7位
        }
    }
    return valData;
    
}
/** 解析二进制数据：NSData --> 自定义模型对象 */
- (void)parseContentDataWithHeadLength:(int32_t)headL withContentLength:(int32_t)contentL{
    
    NSRange range = NSMakeRange(0, headL + contentL);   //本次解析data的范围
    NSData *data = [self.receiveData subdataWithRange:range]; //本次解析的data
    
    GPBCodedInputStream *inputStream = [GPBCodedInputStream streamWithData:data];
    
    NSError *error;
    Msg *obj = [Msg parseDelimitedFromCodedInputStream:inputStream extensionRegistry:nil error:&error];
    
    if (!error){
        if (obj) {
            [self saveReceiveInfo:obj];
            //保存解析正确的模型对象
            [self.receiveData replaceBytesInRange:range withBytes:NULL length:0];  //移除已经解析过的data
        }
    }
    
    if (self.receiveData.length < 1) return;
    
    //对于粘包情况下被合并的多条消息，循环递归直至解析完所有消息
    headL = 0;
    contentL = [self getContentLength:self.receiveData withHeadLength:&headL];
    if (headL + contentL > self.receiveData.length) return; //实际包不足解析，继续接收下一个包

    [self parseContentDataWithHeadLength:headL withContentLength:contentL]; //继续解析下一条
}
/** 获取data数据的内容长度和头部长度: index --> 头部占用长度 (头部占用长度1-4个字节) */
- (int32_t)getContentLength:(NSData *)data withHeadLength:(int32_t *)index{
    
    int8_t tmp = [self readRawByte:data headIndex:index];
    
    if (tmp >= 0) return tmp;
    
    int32_t result = tmp & 0x7f;
    if ((tmp = [self readRawByte:data headIndex:index]) >= 0) {
        result |= tmp << 7;
    } else {
        result |= (tmp & 0x7f) << 7;
        if ((tmp = [self readRawByte:data headIndex:index]) >= 0) {
            result |= tmp << 14;
        } else {
            result |= (tmp & 0x7f) << 14;
            if ((tmp = [self readRawByte:data headIndex:index]) >= 0) {
                result |= tmp << 21;
            } else {
                result |= (tmp & 0x7f) << 21;
                result |= (tmp = [self readRawByte:data headIndex:index]) << 28;
                if (tmp < 0) {
                    for (int i = 0; i < 5; i++) {
                        if ([self readRawByte:data headIndex:index] >= 0) {
                            return result;
                        }
                    }
                    
                    result = -1;
                }
            }
        }
    }
    return result;
}
/** 读取字节 */
- (int8_t)readRawByte:(NSData *)data headIndex:(int32_t *)index{
    
    if (*index >= data.length) return -1;
    
    *index = *index + 1;
    
    return ((int8_t *)data.bytes)[*index - 1];
}

#pragma mark - 数据解析
/** 处理解析出来的信息 */
- (void)saveReceiveInfo:(Msg *)messag
{
//    CPLog(@"message:%@",messag)
    
    //token过期
    if (messag.head.statusReport == self.tokenCode)
    {
        //防止多次进入换取新token
        if (tokenFlag == NO)
        {
            tokenFlag = YES;
            //token回调过期处理,获取新token
            if (self.tokenOverdueBlock)
            {
                self.tokenOverdueBlock(&tokenFlag);
            }
        }
        
        return;
    } 
    //握手信息
    if (messag.head.msgType == 1001)
    {
//        SWLog(@"握手信息回调告知 tag:%ld 这里解析正常数据:%@ \nstatusReport:%d",tag,messag,messag.head.statusReport);
        //握手成功
        if (messag.head.statusReport == 0) {
            //握手成功，移除记录
            SWLog(@"握手成功")
            [self.msgDataSource removeObjectForKey:iOS_TCPID_HandshakeKEY()];
            
            //握手成功标识
            if (!self.isTheHandshakeSuccessful) self.isTheHandshakeSuccessful = YES;
            
            //重新发送消息
            [self reSendAllMessage];
            
            //开启心跳包
            @try {
                if (!self.thread.isExecuting) {
                    [self.thread start];
                }
            } @catch (NSException *exception) {
                SWLog(@"心跳包定时器开启失败：%@",exception);
            } @finally {
                SWLog(@"心跳包定时器开启成功");
            }
        }
        //握手失败
        else {
            //重新发送握手消息
            [self sendHandshakeMessages:self.socket];
        }
    }
    else if (messag.head.msgType == 1002)
    {
        //如果握手失败则，重新握手
        if (messag.head.statusReport == -1 ) {
            [self disconnectSocket];
            [self reConnectSucessfullWithHandle:^{
//                SWLog(@"tag:%ld 心跳校验失败，重新连接成功",tag);
            }];;
        }
        //正常心跳
        else
        {
            SWLog(@"收到了心跳包回调告知");
            // 心跳包不做处理
            SWLog(@"==收到了心跳包回调告知：%@",messag);
        }
    }
    else{
        SWLog(@"msgType:%d 这里解析正常数据:%@ \nstatusReport:%d",messag.head.msgType,messag,messag.head.statusReport);
        if (self.delegate && [self.delegate respondsToSelector:@selector(TCPManager:didReadMessage:)])
        {
            [self.delegate TCPManager:self didReadMessage:messag];
        }
    }
}

- (void)threadStart
{
    @autoreleasepool {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    }
}
- (void)heartBeat
{
    [self sendMsd:[Msg createMsgForHeart]];
}


#pragma mark - lazy

- (NSMutableData *)receiveData
{
    if (_receiveData == nil) {
        _receiveData = [NSMutableData data];
    }
    return _receiveData;
}

 
- (NSThread *)thread
{
    if (_thread == nil) {
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadStart) object:nil];
    }
    return _thread;
}

- (NSMutableDictionary<NSString *,Msg *> *)msgDataSource
{
    if (_msgDataSource == nil) {
        _msgDataSource = [NSMutableDictionary dictionary];
    }
    return _msgDataSource;
}

@end
