//
//  SRDataPoint.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//



#import "SRDataPoint.h"
#import "SRUtils.h"

@implementation SRDataPoint

#pragma mark - General helpers

+ (BOOL) isSimulator {
    return [SRUtils isSimulator];
}

#pragma mark - Realm relationship methods

+ (NSString *)primaryKey
{
    return @"pointId";
}

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{@"pointId": @(-1) };
//}

#pragma mark - JSON helper methods

- (NSDictionary *) toDict {
    return @{
             @"acc"  : @[ self.accX, self.accY, self.accZ ],
             @"mag"  : @[ self.magX, self.magY, self.magZ ],
             @"gyro" : @[ self.gyroX, self.gyroY, self.gyroZ ],
             @"steps": self.numberOfSteps,
             @"dist" : self.distance,
             @"pace" : self.currentPace,
             @"cad"  : self.currentCadence,
             @"fla"  : self.floorsAscended,
             @"fld"  : self.floorsDescended,
             @"fileId" : @(self.fileId),
             @"curTime" : self.curTime
    };
}

#pragma mark - Singletons

+ (CMMotionManager *)motionManager {
    __block CMMotionManager *motionManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        motionManager = [CMMotionManager new];
    });

    return motionManager;
}

+ (CMPedometer *)pedometerInstance {
    __block CMPedometer *pedometer = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pedometer = [CMPedometer new];
    });

    return pedometer;
}

+ (CMMotionActivityManager *)activityManager {
    __block CMMotionActivityManager *activityManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        activityManager = [CMMotionActivityManager new];
    });

    return activityManager;
}

+ (CMPedometerData *)pedometerDataUpdate:(CMPedometerData *)data {
    static CMPedometerData *pedometerData = nil;

    if (data != nil) {
        pedometerData = data;
    }

    return pedometerData;
}

+ (NSInteger) nextPointId:(NSNumber *)number {
    static NSInteger pointId = 0;
    if (number != nil) {
        pointId = [number integerValue];
    } else {
        pointId += 1;
    }
    return pointId;
}

#pragma mark - Actual sensor data fetching

- (CMAcceleration) curAccData {
    CMAcceleration vals;
    if (![SRDataPoint isSimulator]) {
        return [[[SRDataPoint motionManager] accelerometerData] acceleration];
    }
    vals.x = (double)arc4random();
    vals.y = (double)arc4random();
    vals.z = (double)arc4random();
    return vals;
}

- (CMMagneticField) curMagData {
    CMMagneticField vals;
    if (![SRDataPoint isSimulator]) {
        return [[[SRDataPoint motionManager] magnetometerData] magneticField];
    }
    vals.x = (double)arc4random();
    vals.y = (double)arc4random();
    vals.z = (double)arc4random();
    return vals;
}

- (CMRotationRate) curGyroData {
    CMRotationRate vals;
    if (![SRDataPoint isSimulator]) {
        return [[[SRDataPoint motionManager] gyroData] rotationRate];
    }
    vals.x = (double)arc4random();
    vals.y = (double)arc4random();
    vals.z = (double)arc4random();
    return vals;
}

#pragma mark - initializer

- (instancetype) initWithTime:(NSTimeInterval)timeVal {
    self = [super init];
    if (!self) {
        return self;
    }

    self.curTime = @(timeVal);
    self.pointId = [SRDataPoint nextPointId:nil];

    CMAcceleration  acc = [self curAccData];
    CMMagneticField mag = [self curMagData];
    CMRotationRate gyro = [self curGyroData];

    self.accX = @(acc.x);
    self.accY = @(acc.y);
    self.accZ = @(acc.z);

    self.magX = @(mag.x);
    self.magY = @(mag.y);
    self.magZ = @(mag.z);

    self.gyroX = @(gyro.x);
    self.gyroY = @(gyro.y);
    self.gyroZ = @(gyro.z);

    CMPedometerData *pedometerData = [SRDataPoint pedometerDataUpdate:nil];
    self.numberOfSteps = [pedometerData numberOfSteps] ? [pedometerData numberOfSteps] : @(-1);
    self.distance = [pedometerData distance] ? [pedometerData distance] : @(-1);
    self.currentPace = [pedometerData currentPace] ? [pedometerData currentPace] : @(-1);
    self.currentCadence = [pedometerData currentCadence] ? [pedometerData currentCadence] : @(-1);
    self.floorsAscended = [pedometerData floorsAscended] ? [pedometerData floorsAscended] : @(-1);
    self.floorsDescended = [pedometerData floorsDescended] ? [pedometerData floorsDescended] : @(-1);

    return self;
}

- (instancetype) init {
    return [self initWithTime:CACurrentMediaTime()];
}

@end
