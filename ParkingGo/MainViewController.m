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


@interface MainViewController () <WKNavigationDelegate, WKUIDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseView;

@property (strong, nonatomic) WKCookieWebView *webView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    NSString *url = SERVER_URL;

    [self setupWebView];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *validDomain = request.URL.host;
    const BOOL requestIsSecure = [request.URL.scheme isEqualToString:@"https"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([cookie.name rangeOfString:@"'"].location != NSNotFound) {
            NSLog(@"Skipping %@ because it contains a '", cookie.properties);
            continue;
        }

        // Is the cookie for current domain?
        if (![cookie.domain hasSuffix:validDomain]) {
            NSLog(@"Skipping %@ (because not %@)", cookie.properties, validDomain);
            continue;
        }

        // Are we secure only?
        if (cookie.secure && !requestIsSecure) {
            NSLog(@"Skipping %@ (because %@ not secure)", cookie.properties, request.URL.absoluteString);
            continue;
        }
//
        NSString *value = [NSString stringWithFormat:@"%@=%@", cookie.name, cookie.value];
        [array addObject:value];
    }
    NSString *header = [array componentsJoinedByString:@";"];
    [request setValue:header forHTTPHeaderField:@"Cookie"];
    [self.webView loadRequest:request];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setupWebView {
    self.webView = [[WKCookieWebView alloc] initWithFrame:CGRectZero configurationBlock:^(WKWebViewConfiguration * _Nonnull configuration) {
    }];
    
    _webView.wkNavigationDelegate = self;
    [_baseView addSubview:_webView];
    
    _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _webView.scrollView.bounces = NO;

    [self.webView setOnDecidePolicyForNavigationAction:^(WKWebView * _Nonnull webView,
                                                         WKNavigationAction * _Nonnull navigationAction,
                                                         void (^ _Nonnull decisionHandler)(WKNavigationActionPolicy)) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }];
    
    [self.webView setOnDecidePolicyForNavigationResponse:^(WKWebView * _Nonnull webView, WKNavigationResponse * _Nonnull navigationResponse, void (^ _Nonnull decisionHandler) (WKNavigationResponsePolicy)) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }];
    
    __weak typeof(self) weakSelf = self;
    [self.webView setOnUpdateCookieStorage:^(WKCookieWebView * _Nonnull webView) {
        [weakSelf printCookies];
    }];
    
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    [_webView.leadingAnchor constraintEqualToAnchor:_baseView.leadingAnchor constant:0].active = YES;
    [_webView.trailingAnchor constraintEqualToAnchor:_baseView.trailingAnchor constant:0].active = YES;
    [_webView.topAnchor constraintEqualToAnchor:_baseView.topAnchor constant:0].active = YES;
    [_webView.bottomAnchor constraintEqualToAnchor:_baseView.bottomAnchor constant:0].active = YES;
}

- (void)printCookies {
    NSLog(@"==========cookie start==========\n");
    for (NSHTTPCookie *cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies) {
        NSLog(@"%@", cookie);
    }
    NSLog(@"\n==========cookie end==========\n");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}


#pragma mark -- keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    
}
- (void)keyboardWillHide:(NSNotification *)notification {
    _webView.scrollView.contentOffset = CGPointZero;
}

@end
