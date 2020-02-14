//
//  MainViewController.m
//  ParkingGo
//
//  Created by 김학철 on 03/11/2019.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "MainViewController.h"
#import "Bridging-Header.h"
#import "AppDelegate.h"
#import <WebKit/WebKit.h>
@import WKCookieWebView;


@interface MainViewController () <WKNavigationDelegate, WKUIDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseView;

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.scrollView.contentInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        [self.webView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
//    POSTMB LBH
    NSString *url = SERVER_URL;

//    [self setupWebView];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *validDomain = request.URL.host;
    const BOOL requestIsSecure = [request.URL.scheme isEqualToString:@"https"];
    
    NSMutableArray *array = [NSMutableArray array];
    NSData *tmpData = [[NSUserDefaults standardUserDefaults] objectForKey:@"Cookie"];
    NSArray *arrCookie = [NSKeyedUnarchiver unarchiveObjectWithData:tmpData];
    
    for (NSHTTPCookie *cookie in arrCookie) {
        if ([cookie.name rangeOfString:@"'"].location != NSNotFound) {
            NSLog(@"Skipping %@ because it contains a '", cookie.properties);
            continue;
        }

        // Is the cookie for current domain?
        if (![validDomain containsString:cookie.domain]) {
            NSLog(@"Skipping %@ (because not %@)", cookie.properties, validDomain);
            continue;
        }
        
        // Are we secure only?
        if (cookie.secure && !requestIsSecure) {
            NSLog(@"Skipping %@ (because %@ not secure)", cookie.properties, request.URL.absoluteString);
            continue;
        }
        
        [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookie:cookie];
        NSString *value = [NSString stringWithFormat:@"%@=%@", cookie.name, cookie.value];
        [array addObject:value];
    }
    NSString *header = [array componentsJoinedByString:@";"];
    
    if (header.length > 0) {
        [request setValue:header forHTTPHeaderField:@"Cookie"];
    }
//    else {
//        NSDictionary *tmpdic = @{NSHTTPCookieDomain:validDomain,
//                                 NSHTTPCookiePath:@"/",
//                                 NSHTTPCookieName:@"access_token",
//                                 NSHTTPCookieValue:@"value"};
//        [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookie:[NSHTTPCookie cookieWithProperties:tmpdic]];
//    }
    
    [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    [self.webView loadRequest:request];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"== url : %@\n", [request.URL absoluteString]);
    NSLog(@"== header filed = %@\n", [request allHTTPHeaderFields]);
    NSLog(@"== requst query = %@\n", [request.URL query]);
    NSLog(@"== cookie = %@\n", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]);
    
    if ([[request.URL absoluteString] containsString:@"LogOff"]
        ||[[request.URL absoluteString] containsString:@"LogOut"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Cookie"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    else {
        
        [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        NSArray *arrCookie = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookies];
        NSMutableArray *arrTmp = [NSMutableArray array];
        
        for (NSHTTPCookie *cookie in arrCookie) {
            if ([cookie.name rangeOfString:@"'"].location != NSNotFound) {
//                NSLog(@"Skipping %@ because it contains a '", cookie.properties);
                continue;
            }
            
            // Is the cookie for current domain?
            if (![SERVER_URL containsString:cookie.domain]) {
//                NSLog(@"Skipping %@ (because not %@)", cookie.properties, validDomain);
                continue;
            }
            [arrTmp addObject:cookie];
        }
        
        if (arrTmp.count > 0) {
            NSData *tmpData = [NSKeyedArchiver archivedDataWithRootObject:arrCookie];
            [[NSUserDefaults standardUserDefaults] setObject:tmpData forKey:@"Cookie"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    }
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}


//- (void)setupWebView {
//    self.webView = [[WKCookieWebView alloc] initWithFrame:CGRectZero configurationBlock:^(WKWebViewConfiguration * _Nonnull configuration) {
//    }];
//
//    _webView.wkNavigationDelegate = self;
//    [_baseView addSubview:_webView];
//
//    _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    _webView.scrollView.bounces = NO;
//
//    [self.webView setOnDecidePolicyForNavigationAction:^(WKWebView * _Nonnull webView,
//                                                         WKNavigationAction * _Nonnull navigationAction,
//                                                         void (^ _Nonnull decisionHandler)(WKNavigationActionPolicy)) {
//        decisionHandler(WKNavigationActionPolicyAllow);
//    }];
//
//    [self.webView setOnDecidePolicyForNavigationResponse:^(WKWebView * _Nonnull webView, WKNavigationResponse * _Nonnull navigationResponse, void (^ _Nonnull decisionHandler) (WKNavigationResponsePolicy)) {
//        decisionHandler(WKNavigationResponsePolicyAllow);
//    }];
//
//    __weak typeof(self) weakSelf = self;
//    [self.webView setOnUpdateCookieStorage:^(WKCookieWebView * _Nonnull webView) {
//        [weakSelf printCookies:webView];
//    }];
//
//    _webView.translatesAutoresizingMaskIntoConstraints = NO;
//    [_webView.leadingAnchor constraintEqualToAnchor:_baseView.leadingAnchor constant:0].active = YES;
//    [_webView.trailingAnchor constraintEqualToAnchor:_baseView.trailingAnchor constant:0].active = YES;
//    [_webView.topAnchor constraintEqualToAnchor:_baseView.topAnchor constant:0].active = YES;
//    [_webView.bottomAnchor constraintEqualToAnchor:_baseView.bottomAnchor constant:0].active = YES;
//}
//
//- (void)printCookies:(WKCookieWebView *)webView {
//
//    if ([[webView.URL absoluteString] containsString:@"LogOff"]
//        ||[[webView.URL absoluteString] containsString:@"LogOut"]) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Cookie"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    else {
//        NSArray *arrCookie = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookies];
//
//        if (arrCookie != nil && arrCookie.count > 0) {
//            NSMutableArray *cookies = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Cookie"]] mutableCopy];
//            [cookies addObjectsFromArray:arrCookie];
//            NSData *tmpData = [NSKeyedArchiver archivedDataWithRootObject:cookies];
//            [[NSUserDefaults standardUserDefaults] setObject:tmpData forKey:@"Cookie"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    }
//
////    NSLog(@"==========cookie start==========\n");
////
////    for (NSHTTPCookie *cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies) {
////        NSLog(@"%@", cookie);
////        webView onUpdateCookieStorage
////    }
////    NSLog(@"\n==========cookie end==========\n");
//}
//
//- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
//
//}
//
//- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
//
//}


#pragma mark -- keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    
}
- (void)keyboardWillHide:(NSNotification *)notification {
    _webView.scrollView.contentOffset = CGPointZero;
}

@end
