//
//  STReachabilityExampleViewController.m
//  STReachability
//
//  Created by Scott Talbot on 9/08/12.
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import "STReachabilityExampleViewController.h"
#import "STReachability.h"


static NSString *NSStringFromSTReachabilityStatus(enum STReachabilityStatus);

static UIView *UIViewFindFirstResponder(UIView *);


@interface STReachabilityExampleViewController () <UITextFieldDelegate>
@property (nonatomic,copy) STReachability *reachability;
@property (nonatomic,copy) NSString *reachabilityHostname;
@property (nonatomic,readonly) NSCharacterSet *reachabilityHostnameBlacklistCharacterSet;
@end


@implementation STReachabilityExampleViewController {
    STReachability *_reachability;
    NSString *_reachabilityHostname;
    __weak UITextField *_reachabilityHostnameTextField;
    NSCharacterSet *_reachabilityHostnameBlacklistCharacterSet;
    __weak UILabel *_reachabilityStatusLabel;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"Reachability";

        _reachability = [STReachability reachability];
        [_reachability addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:&_reachability];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.title = @"Reachability";

        _reachability = [STReachability reachability];
        [_reachability addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:&_reachability];
    }
    return self;
}

- (void)dealloc {
    [_reachability removeObserver:self forKeyPath:@"status" context:&_reachability];
}


- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    self.view.backgroundColor = [UIColor whiteColor];

    UIGestureRecognizer *backgroundTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [self.view addGestureRecognizer:backgroundTapGestureRecogniser];

    UITextField *reachabilityHostnameTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 50, 240, 40)];
    reachabilityHostnameTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    reachabilityHostnameTextField.borderStyle = UITextBorderStyleBezel;
    reachabilityHostnameTextField.textAlignment = NSTextAlignmentCenter;
    reachabilityHostnameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    reachabilityHostnameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    reachabilityHostnameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    reachabilityHostnameTextField.keyboardType = UIKeyboardTypeURL;
    reachabilityHostnameTextField.returnKeyType = UIReturnKeyDone;
    reachabilityHostnameTextField.delegate = self;
    [self.view addSubview:reachabilityHostnameTextField];
    _reachabilityHostnameTextField = reachabilityHostnameTextField;

    UILabel *reachabilityStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 110, 240, 240)];
    reachabilityStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    reachabilityStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:reachabilityStatusLabel];
    _reachabilityStatusLabel = reachabilityStatusLabel;

}

- (void)viewDidLoad {
    [_reachabilityHostnameTextField setText:_reachabilityHostname];
    [_reachabilityStatusLabel setText:NSStringFromSTReachabilityStatus(_reachability.status)];
}


#pragma mark - Private

@synthesize reachabilityHostnameBlacklistCharacterSet = _reachabilityHostnameBlacklistCharacterSet;
- (NSCharacterSet *)reachabilityHostnameBlacklistCharacterSet {
    if (!_reachabilityHostnameBlacklistCharacterSet) {
        NSMutableCharacterSet *whitelistCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@".-"];
        [whitelistCharacterSet addCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
        [whitelistCharacterSet addCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        [whitelistCharacterSet addCharactersInString:@"0123456789"];

        _reachabilityHostnameBlacklistCharacterSet = [whitelistCharacterSet invertedSet];
    }
    return _reachabilityHostnameBlacklistCharacterSet;
}

- (void)viewTapped {
    [UIViewFindFirstResponder(self.view) resignFirstResponder];
}

@synthesize reachability = _reachability;
- (void)setReachability:(STReachability *)reachability {
    if (_reachability != reachability) {
        [_reachability removeObserver:self forKeyPath:@"status" context:&_reachability];
        _reachability = reachability;
        [_reachability addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:&_reachability];
    }
}

@synthesize reachabilityHostname = _reachabilityHostname;
- (void)setReachabilityHostname:(NSString *)reachabilityHostname {
    if (![_reachabilityHostname isEqualToString:reachabilityHostname]) {
        _reachabilityHostname = [reachabilityHostname copy];
        if ([_reachabilityHostname length] == 0) {
            [self setReachability:[STReachability reachability]];
        } else {
            [self setReachability:[STReachability reachabilityWithHost:_reachabilityHostname]];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string rangeOfCharacterFromSet:self.reachabilityHostnameBlacklistCharacterSet].length != 0) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text length] == 0) {
        [self setReachabilityHostname:nil];
    } else {
        [self setReachabilityHostname:textField.text];
    }
}


#pragma mark - NSKVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &_reachability) {
        [_reachabilityStatusLabel setText:NSStringFromSTReachabilityStatus(_reachability.status)];
    }
}

@end


static NSString *NSStringFromSTReachabilityStatus(enum STReachabilityStatus status) {
    switch (status) {
        case STReachabilityStatusUnknown:
            return @"Unknown";
        case STReachabilityStatusUnreachable:
            return @"Unreachable";
        case STReachabilityStatusReachableViaWifi:
            return @"Reachable (WiFi)";
        case STReachabilityStatusReachableViaWWAN:
            return @"Reachable (WWAN)";
    }

    NSCAssert(0, @"unreachable");

    return [NSString stringWithFormat:@"Unknown STReachabilityStatus: %d", status];
}

static UIView *UIViewFindFirstResponder(UIView *view) {
    if ([view isFirstResponder]) {
        return view;
    }

    for (UIView *subview in view.subviews) {
        UIView *responder = UIViewFindFirstResponder(subview);
        if (responder) {
            return  responder;
        }
    }

    return nil;
}
