import Starscream
import Foundation

public class AVASocketCluster: Listener {
    
    var authToken: String?
    var url: String?
    var socket: WebSocket
    var counter: AtomicInteger
    
    var onConnect: ((AVASocketCluster)-> Void)?
    var onConnectError: ((AVASocketCluster, Error?)-> Void)?
    var onDisconnect: ((AVASocketCluster, Error?)-> Void)?
    var onSetAuthentication: ((AVASocketCluster, String?)-> Void)?
    var onAuthentication: ((AVASocketCluster, Bool?)-> Void)?
    
    public func setAuthToken(token: String) {
        authToken = token
    }
    
    public func getAuthToken () -> String?{
        return authToken
    }
    
    public func setBasicListener(onConnect: ((AVASocketCluster)-> Void)?,
                                 onConnectError: ((AVASocketCluster, Error?)-> Void)?,
                                 onDisconnect: ((AVASocketCluster, Error?)-> Void)?) {
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        self.onConnectError = onConnectError
    }
    
    public func setAuthenticationListener (onSetAuthentication: ((AVASocketCluster, String?)-> Void)?,
                                           onAuthentication: ((AVASocketCluster, Bool?)-> Void)?) {
        self.onSetAuthentication = onSetAuthentication
        self.onAuthentication = onAuthentication
    }
    
    public init(url: String,
                authToken: String? = nil) {
        counter = AtomicInteger()
        self.authToken = authToken
        socket = WebSocket(url: URL(string: url)!)
        
        super.init()
        
        socket.delegate = self
    }
    
    public init(urlRequest: URLRequest,
                authToken: String? = nil,
                protocols: [String]? = nil) {
        counter = AtomicInteger()
        self.authToken = authToken
        socket = WebSocket(request: urlRequest,
                                protocols: protocols)
        
        super.init()
        
        socket.delegate = self
    }
    
    public func connect() {
        socket.connect()
    }
    
    public func isConnected() -> Bool{
        return socket.isConnected;
    }
    
    public func setBackgroundQueue(queueName: String) {
        socket.callbackQueue = DispatchQueue(label: queueName)
    }
    
    internal func sendHandShake() {
        let handshake = Model.getHandshakeObject(authToken: authToken,
                                                 messageId: counter.incrementAndGet())
        guard let message = handshake.toJSONString() else { return }
        socket.write(string: message)
    }
    
    internal func ack(cid: Int) -> (AnyObject?, AnyObject?) -> Void {
        return  {
            (error: AnyObject?, data: AnyObject?) in
            let ackObject = Model.getReceiveEventObject(data: data,
                                                        error: error,
                                                        messageId: cid)
            self.socket.write(string: ackObject.toJSONString()!)
        }
    }
    
    public func emit (eventName: String,
                      data: AnyObject?) {
        let emitObject = Model.getEmitEventObject(eventName: eventName,
                                                  data: data,
                                                  messageId: counter.incrementAndGet())
        socket.write(string: emitObject.toJSONString()!)
    }
    
    public func emitAck (eventName: String,
                         data: AnyObject?,
                         ack: @escaping (String, AnyObject?, AnyObject?)-> Void) {
        let id = counter.incrementAndGet()
        let emitObject = Model.getEmitEventObject(eventName: eventName,
                                                  data: data,
                                                  messageId: id)
        
        putEmitAck(id: id,
                   eventName: eventName,
                   ack: ack)
        
        guard let message = emitObject.toJSONString() else { return }
        socket.write(string: message)
    }
    
    public func subscribe(channelName: String,
                          token: String? = nil) {
        let subscribeObject = Model.getSubscribeEventObject(channelName: channelName,
                                                            messageId: counter.incrementAndGet(),
                                                            token: token)
        guard let message = subscribeObject.toJSONString() else { return }
        socket.write(string: message)
    }
    
    public func subscribeAck(channelName: String,
                             token: String? = nil,
                             ack: @escaping (String, AnyObject?, AnyObject?)-> Void) {
        let id = counter.incrementAndGet()
        let subscribeObject = Model.getSubscribeEventObject(channelName: channelName,
                                                            messageId: id,
                                                            token: token)
        
        putEmitAck(id: id,
                   eventName: channelName,
                   ack: ack)
        
        guard let message = subscribeObject.toJSONString() else { return }
        socket.write(string: message)
    }
    
    public func unsubscribe(channelName: String) {
        let unsubscribeObject = Model.getUnsubscribeEventObject(channelName: channelName,
                                                                messageId: counter.incrementAndGet())
        guard let message = unsubscribeObject.toJSONString() else { return }
        socket.write(string: message)
    }
    
    public func unsubscribeAck(channelName: String,
                               ack: @escaping (String, AnyObject?, AnyObject?)-> Void) {
        let id = counter.incrementAndGet()
        let unsubscribeObject = Model.getUnsubscribeEventObject(channelName: channelName,
                                                                messageId: id)
        
        putEmitAck(id: id,
                   eventName: channelName,
                   ack: ack)
        
        socket.write(string: unsubscribeObject.toJSONString()!)
    }
    
    public func publish(channelName: String,
                        data: AnyObject?) {
        let publishObject = Model.getPublishEventObject(channelName: channelName,
                                                        data: data,
                                                        messageId: counter.incrementAndGet())
        socket.write(string: publishObject.toJSONString()!)
    }
    
    public func publishAck(channelName: String,
                           data: AnyObject?,
                           ack: @escaping (String, AnyObject?, AnyObject?)-> Void) {
        let id = counter.incrementAndGet()
        let publishObject = Model.getPublishEventObject(channelName: channelName,
                                                        data: data,
                                                        messageId: id)
        
        putEmitAck(id: id,
                   eventName: channelName,
                   ack: ack)
        
        socket.write(string: publishObject.toJSONString()!)
    }
    
    public func onChannel(channelName: String,
                          ack: @escaping (String, AnyObject?) -> Void) {
        putOnListener(eventName: channelName,
                      onListener: ack)
    }
    
    public func on(eventName: String,
                   ack: @escaping (String, AnyObject?) -> Void) {
        putOnListener(eventName: eventName,
                      onListener: ack)
    }
    
    public func onAck(eventName: String,
                      ack: @escaping (String, AnyObject?, (AnyObject?, AnyObject?) -> Void) -> Void) {
        putOnAckListener(eventName: eventName,
                         onAckListener: ack)
    }
    
    public func disconnect() {
        socket.disconnect()
    }
    
    public func disableSSLVerification(value: Bool) {
        socket.disableSSLCertValidation = value
    }
    
    /**
    Uses the .cer files in your app's bundle
    */
    public func useSSLCertificate() {
        socket.security = SSLSecurity()
    }
    
    /**
    You load either a Data blob of your certificate or you can use a SecKeyRef if you have a public key you want to use.
     - Parameters:
        - data: Data blob of your certificate.
        - usePublicKeys: The usePublicKeys bool is whether to use the certificates for validation or the public keys.
    */
    public func loadSSLCertificateFromData(data: Data,
                                           usePublicKeys: Bool = false) {
        socket.security = SSLSecurity(certs: [SSLCert(data: data)],
                                      usePublicKeys: usePublicKeys)
    }
    
}

 extension AVASocketCluster: WebSocketDelegate {
    
    public func websocketDidConnect(socket: WebSocketClient) {
        counter.value = 0
        self.sendHandShake()
        onConnect?(self)
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient,
                                       error: Error?) {
        onDisconnect?(self, error)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient,
                                           text: String) {
        if (text == "#1") {
            socket.write(string: "#2")
            return
        }
        
        guard let messageObject = JSONConverter.deserializeString(message: text) else { return }
        guard let (data, rid, cid, eventName, error) = Parser.getMessageDetails(myMessage: messageObject) else { return }
        
        let parseResult = Parser.parse(rid: rid, cid: cid, event: eventName)
        
        switch parseResult {
            
        case .isAuthenticated:
            let isAuthenticated = ClientUtils.getIsAuthenticated(message: messageObject)
            onAuthentication?(self, isAuthenticated)
        case .publish:
            guard let channel = Model.getChannelObject(data: data as AnyObject) else { return }
            handleOnListener(eventName: channel.channel,
                             data: channel.data as AnyObject)
        case .removeToken:
            self.authToken = nil
        case .setToken:
            authToken = ClientUtils.getAuthToken(message: messageObject)
            self.onSetAuthentication?(self,
                                      authToken)
        case .ackReceive:
            handleEmitAck(id: rid!,
                          error: error as AnyObject,
                          data: data as AnyObject)
        case .event:
            if hasEventAck(eventName: eventName!) {
                handleOnAckListener(eventName: eventName!,
                                    data: data as AnyObject,
                                    ack: self.ack(cid: cid!))
            } else {
                handleOnListener(eventName: eventName!,
                                 data: data as AnyObject)
            }
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient,
                                        data: Data) {
        
    }
    
}
