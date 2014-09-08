#import "STNHomeViewController.h"
#import "STNChessBoardViewController.h"
#import "STNDiff.h"
#import "STNWebSocket.h"
#import "STNConfig.h"

/// EXERCISE 0: FORMALITIES
///
/// Please Build and Run on the iPad Air simulator.
/// Let us know in chat or in person if you have any
/// problems. The chat URL is:
///
///  http://www.hipchat.com/gBH2nxWKC

@interface STNHomeViewController ()

@property (strong, nonatomic) STNChessBoardViewController *boardController;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) STNWebSocket *socket;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UILabel *countLabel;

@end

@implementation STNHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareSocket];
}

- (void)prepareSocket {
    self.label = [[UILabel alloc] init];
    self.label.font = [UIFont fontWithName:@"Futura" size:18];
}

- (void)viewWillAppearHide:(BOOL)animated {
    [super viewWillAppear:animated];
    self.countLabel = [[UILabel alloc] init];
    self.countLabel.frame = CGRectMake(0, 200, self.view.bounds.size.width, 100);
    self.countLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.countLabel];

    self.textView = [[UITextView alloc] init];
    self.textView.frame = CGRectMake(0, 100, self.view.bounds.size.width, 100);
    self.countLabel.font = self.textView.font = [UIFont systemFontOfSize:40];
    [self.view addSubview:self.textView];
    self.view.backgroundColor = [UIColor purpleColor];

    RACSignal *countSignal = [self.textView.rac_textSignal map:^id(NSString *text) {
        return [NSString stringWithFormat:@"%i", text.length];
    }];
    // self.countLabel.text is _always_ the value of countSignal
    RAC(self.countLabel, text) = countSignal;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    STNWebSocket *socket = [STNWebSocket webSocketWithEmail:stn_email()];

    /// EXERCISE ONE: HELLO, REACTIVE COCOA
    ///
    /// As self.socket.openedSignal sends you @YESes and @NOs, please
    /// reactively update self.label.text. This will give you a fun and,
    /// more importantly, useful indicator of the server status.
    ///
    /// Solution: git stash; git co 1

    RAC(self, label.text) = [[socket.connectedSignal map:^id(NSNumber *n) {
        return n.boolValue ? @"+ WebSocket: connected ∰." : @"+ WebSocket: disconnected ☁.";
    }] startWith:@"+ WebSocket: initializing..."];

    self.boardController = [[STNChessBoardViewController alloc] initWithSocket:socket];

    CGFloat side = MIN(self.view.frameSizeHeight, self.view.frameSizeWidth);
    self.boardController.view.frame = CGRectMake(0, 0, side, side);
    self.boardController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    self.boardController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.boardController.view];
    [self.boardController didMoveToParentViewController:self];

    CGFloat bottom = self.boardController.view.frameOriginY + self.boardController.view.frameSizeHeight;
    self.label.frame = CGRectMake(0, bottom, side, side);
    [self.view addSubview:self.label];
    self.label.frameSizeHeight = [self.label sizeThatFits:CGSizeMake(side, CGFLOAT_MAX)].height;
}

@end
