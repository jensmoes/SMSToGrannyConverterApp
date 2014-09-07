//
//  TGTwilioManager.m
//  TextGranny
//
//  Created by Jens Troest on 9/4/14.
//  Copyright (c) 2014 Jens Troest. All rights reserved.
//

#import "TGTwilioManager.h"
@interface TGTwilioManager () <TCConnectionDelegate,TCDeviceDelegate>
@end

@implementation TGTwilioManager {
    //"Private" ivars
    NSString* capabilityToken;
}
static NSString* kTokenUrl = @"http://raspberry.troest.com/auth.php?client=%@";

+ (TGTwilioManager*) sharedInstance
{
    static dispatch_once_t onceToken;
    static TGTwilioManager *sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[TGTwilioManager alloc] init];
    });
    return sSharedInstance;
}
-(id) init
{
    self = [super init];
    
    if(self != Nil)
    {
        [self connectDevice];
    }
    return self;
}

-(id) initWithName:(NSString*) name
{
    if(name != Nil && [name length] > 0)
    {
        _clientName = name;
        return [self init];
    }
    return nil;
}

-(void) setClientName:(NSString*) name
{
//    if([name isEqualToString:_clientName])
//        return;
    //clientName has been changed, generate new token and device
    if (_device) {
        [_device disconnectAll];
        _device = nil;
    }
    _clientName = name;
    if(_clientName != nil && [_clientName length] > 0)
    {
        [self connectDevice];
    }

    else
    {
        [self respondDidNotListen];
    }
    
}

-(void) connectDevice
{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat: kTokenUrl,_clientName]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    NSOperationQueue* queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:request queue: queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        //Act on result
        if(connectionError == nil && [data length] >0)
        {
            capabilityToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //Make sure you run the Twilio SDK on main thread, it uses dispatch to do many things I gather from viewing the callstack
            [self performSelectorOnMainThread:@selector(createDevice) withObject:nil waitUntilDone:NO];
        }
        else
            [self performSelectorOnMainThread:@selector(respondDidNotListen) withObject:nil waitUntilDone:NO];
    }];
    
}

-(void) reConnect
{
    if (_clientName.length
        && _device.state  == TCDeviceStateOffline) {
        [self connectDevice];
    }
}

-(void) respondDidNotListen
{
    if([self.delegate respondsToSelector:@selector(didNotListen)])
    {
        [self.delegate didNotListen];
    }
}

-(void) respondDidStartListening
{
    if([self.delegate respondsToSelector:@selector(didStartListening)] && _device != nil)
    {
        [self.delegate didStartListening];
    }
}

-(void) respondDidStopListening
{
    if([self.delegate respondsToSelector:@selector(didStopListening)] && _device != nil)
    {
        [self.delegate didStopListening];
    }
}

-(void) createDevice
{
    _device = [[TCDevice alloc] initWithCapabilityToken:capabilityToken
                                               delegate:self];
    [self performSelectorOnMainThread:@selector(respondDidStartListening) withObject:nil waitUntilDone:NO];
}

-(void) connectCall:(NSString *)destination withConnectionHandler:(TGConnectionHandlerBlock)handler
{
    _connectionHandler = handler;
    NSDictionary* parameters = [NSDictionary dictionaryWithObject:destination forKey:@"PhoneNumber"];
    if(destination && [destination length] > 0)
    {
        _connection = [_device connect:parameters delegate:self];
//        _connection.delegate = self;
    }
}

-(void) resetConnection
{
    if(_connection)
    {
        [_connection disconnect];
        _connection = Nil;
    }
}


#pragma mark - TCConnectionDelegate

//Will respond to TGCalls delegate if any and execute any connection handler there might be present

-(void) connection:(TCConnection*)connection didFailWithError:(NSError*)error
{
    NSLog(@"Error Connecting");
    if([_delegate respondsToSelector:@selector(connectionStateChanged:)])
    {
        [_delegate connectionStateChanged:TCConnectionStateDisconnected];
    }
    if (_connectionHandler)
    {
        _connectionHandler(TCConnectionStateDisconnected);
    }
}

-(void)connectionDidStartConnecting:(TCConnection*)connection
{
    NSLog(@"Connecting...");
    if([_delegate respondsToSelector:@selector(connectionStateChanged:)])
    {
        [_delegate connectionStateChanged:TCConnectionStateConnecting];
    }
    if (_connectionHandler)
    {
        _connectionHandler(TCConnectionStateConnecting);
    }
}

-(void)connectionDidConnect:(TCConnection*)connection
{
    NSLog(@"Connected");
    if(_connection != connection)
    {
        [self resetConnection];
    }
    if([_delegate respondsToSelector:@selector(connectionStateChanged:)])
    {
        [_delegate connectionStateChanged:TCConnectionStateConnected];
    }
    if (_connectionHandler)
    {
        _connectionHandler(TCConnectionStateConnected);
    }
}
-(void)connectionDidDisconnect:(TCConnection*)connection
{
    NSLog(@"Disconnected");
    if([_delegate respondsToSelector:@selector(connectionStateChanged:)])
    {
        [_delegate connectionStateChanged:TCConnectionStateDisconnected];
    }
    if (_connectionHandler)
    {
        _connectionHandler(TCConnectionStateDisconnected);
    }
}

#pragma mark - TCDeviceDelegate

-(void) device:(TCDevice *)device didStopListeningForIncomingConnections:(NSError *)error
{
    NSLog(@"didStopListeningForIncomingConnections %@", error.localizedFailureReason);
    [self performSelectorOnMainThread:@selector(respondDidStopListening) withObject:nil waitUntilDone:NO];
}
-(void) device:(TCDevice *)device didReceiveIncomingConnection:(TCConnection *)connection
{
    NSLog(@"didReceiveIncomingConnection");
    if (self.connection.state != TCConnectionStateConnected) {
        _connection = connection;
        _connection.delegate = self;
        if([_delegate respondsToSelector:@selector(incomingConnection:)])
        {
            [_delegate incomingConnection:connection];
        }
    }
    else
    {
        [connection disconnect];
    }
    
    
    
}
@end
