//
//  TGTwilioManager.h
//  TextGranny
//
//  Created by Jens Troest on 9/4/14.
//  Copyright (c) 2014 Jens Troest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCDevice.h"
#import "TCConnection.h"

@protocol TGTwilioManagerDelegate
@optional
-(void) didStartListening;//Device connected
-(void) didNotListen;//Device could not connect
-(void) didStopListening;//Same as didNotListen but not triggered by a failure to connect
-(void) connectionStateChanged:(TCConnectionState) state;//Delivers state of call connection
-(void) incomingConnection:(TCConnection*) connection;
@end

@interface TGTwilioManager : NSObject
+(TGTwilioManager*) sharedInstance;
@property (nonatomic, strong) TGTwilioManager* twilioManagerInstance;

//Device
@property (nonatomic, readwrite) NSString* clientName;
@property (strong, nonatomic) TCDevice* device;
-(id) initWithName:(NSString *)name;


//Connection
- (void) reConnect;

//Handler block definition for call connection state monitoring
typedef void (^ TGConnectionHandlerBlock)(TCConnectionState state);
@property (nonatomic, copy) TGConnectionHandlerBlock connectionHandler;
@property (strong, nonatomic) TCConnection *connection;
@property (nonatomic, assign) id delegate;
-(void) connectCall:(NSString*) destination withConnectionHandler:(TGConnectionHandlerBlock) handler;
-(void) resetConnection;
@end
