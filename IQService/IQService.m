//
//  IQService.m
//  IQService
//
//  Created by lobster on 2019/4/28.
//  Copyright © 2019 lobster. All rights reserved.
//

#import "IQService.h"
#import <objc/runtime.h>
#import <objc/message.h>

static NSString *kIQService = @"IQService";

@interface IQService ()

@end

@implementation IQService

+ (instancetype)sharedService {
    static id service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc]init];
    });
    return service;
}

+ (void)invokeMicroService:(NSString *)service,... {
    va_list arguments;
    va_start(arguments, service);
    [[IQService sharedService] invokeService:arguments];
    va_end(arguments);
}

+ (id)invokeMicroServiceSync:(NSString *)service,... {
    return nil;
}

- (void)invokeService:(va_list)arguments {
    NSMutableArray *argsArray = [NSMutableArray array];
    id param = nil;
    while ((param = va_arg(arguments, id))) {
        [argsArray addObject:param];
    }
    
    Class serviceCls = NSClassFromString(@"IQPrintClassNameService");
    id instance = [[serviceCls alloc]init];
    unsigned int count;
    Method *methods = class_copyMethodList(serviceCls, &count);
    Method oneMethod = methods[0];
    SEL selector = method_getName(oneMethod);
    
    NSMethodSignature *mSignature = [instance methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:mSignature];
    invocation.selector = selector;
    NSInteger index = 2;
    for (id arg in argsArray) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types-discards-qualifiers"
        [invocation setArgument:&arg atIndex:index];
#pragma clang diagnostic pop
        index++;
    }
    [invocation invokeWithTarget:instance];
    
}

+ (void)registerMicroServices {
    [[IQService sharedService] registerMicroServicesStatic];
}

/**
 静态注册
 */
- (void)registerMicroServicesStatic {
    
    NSString *servicePath = [[NSBundle mainBundle] pathForResource:kIQService ofType:@"plist"];
    if (!servicePath) {
        return;
    }
    
    NSArray *servicesList = [NSArray arrayWithContentsOfFile:servicePath];
    
    if (!servicesList.count) {
        return;
    }
    
    for (NSString *moduleName in servicesList) {
        NSString *microServicePath = [[NSBundle mainBundle] pathForResource:moduleName ofType:@"plist"];
        if (!microServicePath) {
            continue;
        }
        
        
        
    }
    
    
}


@end
