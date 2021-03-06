#import <Preferences/Preferences.h>
//#import <Preferences/PSViewController.h>
//#import <Preferences/PSDetailController.h>
//#import <Preferences/PSTableCell.h>
//#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>
#import "VKPrefsPasscode.h"
NSString *const BKPasscodeKeychainServiceName = @"ru.anonz.vkpass";
NSMutableDictionary *passcodeF;
NSMutableDictionary *settingsVKP;
BKPasscodeViewController *viewController;

@implementation VKPrefsPasscode

//@synthesize passcodeFile;
@synthesize passcode;
@synthesize deletePasscode;
@synthesize disablePasscode;
@synthesize disableVKPasscode;
@synthesize lostPassAuthCompl;
//@synthesize lostPasswrd;

+(VKPrefsPasscode *) sharedInstance
{
    static dispatch_once_t p = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&p, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

static void reloadSettings()
{
    passcodeF = [[NSMutableDictionary alloc] initWithContentsOfFile:passcodePath];
}

//+(void)passcodeSettings
//{
//    passcodeFile ;
//
//}

-(id)init
{
    self = [super init];
    if(self)
    {
        self.passcode = self.passcode;
    }
    return self;
}

// - (void)openPasscodeViewControllerWithType:(NSString *)type {
//     if ([type isEqualToString:@"setPIN"]) {
//       [self setPINVC];
//     }
// }

-(id)setPINVC
{
    [[VKPassLP sharedInstance] noLostPass];
    viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    viewController.type = BKPasscodeViewControllerNewPasscodeType;

    passcodeF = [[NSMutableDictionary alloc] initWithContentsOfFile:passcodePath];
    reloadSettings();
    // if (![[NSFileManager defaultManager] fileExistsAtPath:passcodePath] || ![passcodeF objectForKey:@"Passcode"])
    // {
    //
    //     viewController.type = BKPasscodeViewControllerNewPasscodeType;
    // }
    // else
    // {
    //     viewController.type = BKPasscodeViewControllerChangePasscodeType;
    // }
    // viewController.type = BKPasscodeViewControllerChangePasscodeType;    // for change
    // viewController.type = BKPasscodeViewControllerCheckPasscodeType;   // for authentication
    settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
    if ([[settingsVKP objectForKey:@"sPINHard"] boolValue])
    {
        viewController.passcodeStyle = BKPasscodeInputViewNormalPasscodeStyle; // for ASCII style passcode.
    }
    else
    {
        viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
    }

    // To supports Touch ID feature, set BKTouchIDManager instance to view controller.
    // It only supports iOS 8 or greater.
    viewController.touchIDManager = [[BKTouchIDManager alloc] initWithKeychainServiceName:BKPasscodeKeychainServiceName];
    viewController.touchIDManager.promptText = @"Scan fingerprint to authenticate";   // You can set prompt text.

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    viewController.navigationItem.title = @"VKPass";
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Отменить"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(closeViewSetPass:)];
    viewController.navigationItem.leftBarButtonItem = closeButton;
    [self presentViewController:navController animated:YES completion:nil];

    return viewController;
}

-(id)changePINVC
{
    [[VKPassLP sharedInstance] noLostPass];
    viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
    if ([[settingsVKP objectForKey:@"sPINHard"] boolValue])
    {
        viewController.passcodeStyle = BKPasscodeInputViewNormalPasscodeStyle; // for ASCII style passcode.
    }
    else
    {
        viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
    }
    viewController.delegate = self;
    viewController.type = BKPasscodeViewControllerChangePasscodeType;
    //viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(passcodeViewCloseButtonPressed:)];
    [self setRootController: [self rootController]];
    [self setParentController: [self parentController]];
    //viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; //Animation
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Отменить"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(closeView:)];
    viewController.navigationItem.leftBarButtonItem = closeButton;
    viewController.navigationItem.title = @"VKPass";
    [self presentViewController:navController animated:YES completion:nil];
    viewController.touchIDManager = [[BKTouchIDManager alloc] initWithKeychainServiceName:BKPasscodeKeychainServiceName];
    viewController.touchIDManager.promptText = @"Scan fingerprint to authenticate";   // You can set prompt text.

    // Show Touch ID user interface
    [viewController startTouchIDAuthenticationIfPossible:^(BOOL prompted) {

        // If Touch ID is unavailable or disabled, present passcode view controller for manual input.
        if (NO == prompted) {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [self presentViewController:navController animated:YES completion:nil];
        }
    }];
    return viewController;
}

- (id)checkPINVCWithType:(NSString *)typePasscode {
    /*
    BKPasscodeViewController *viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
    viewController.type = BKPasscodeViewControllerCheckPasscodeType;
    viewController.delegate = self;
    [self setRootController: [self rootController]];
    [self setParentController: [self parentController]];
     */
    [[VKPassLP sharedInstance] noLostPass];
    viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    if ([typePasscode isEqualToString:@"EnablePIN"]) {
      viewController.type = BKPasscodeViewControllerCheckPasscodeType;   // for authentication
    }
    else if ([typePasscode isEqualToString:@"Dialogs"]) {
      viewController.type = BKPasscodeViewControllerCheckDialogsPasscodeType;
    }
    //viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(passcodeViewCloseButtonPressed:)];

    settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
    if ([[settingsVKP objectForKey:@"sPINHard"] boolValue])
    {
        viewController.passcodeStyle = BKPasscodeInputViewNormalPasscodeStyle; // for ASCII style passcode.
    }
    else
    {
        viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
    }

    // To supports Touch ID feature, set BKTouchIDManager instance to view controller.
    // It only supports iOS 8 or greater.
    NSString *localizationReason;
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    if ([language isEqualToString:@"ru"])
    {
        localizationReason = @"Приложите палец для аутентификации.";
    }
    else
    {
        localizationReason = @"Scan your fingerprint for access.";
    }
    if ([[settingsVKP objectForKey:@"sTouchID"] boolValue])
    {
        LAContext *myContext = [[LAContext alloc] init];
        NSError *authError = nil;
        if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {

            //BKPasscodeViewController *viewControllerCheckPin = [[VKPrefsPasscode sharedInstance] checkPINVC];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            //[self showModalViewController:navController];

            [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                      localizedReason:localizationReason
                                reply:^(BOOL succes, NSError *error) {

                                    if (succes)
                                    {
                                        [viewController dismissViewControllerAnimated:YES completion:nil];
                                        //[self showMessage:@"Authentication is successful" withTitle:@"Success"];
                                        //NSLog(@"User authenticated");
                                    }
                                    else
                                    {
                                        switch (error.code) {
                                            case LAErrorAuthenticationFailed:
                                                [self presentViewController:navController animated:YES completion:nil];
                                                break;

                                            case LAErrorUserCancel:
                                                [self presentViewController:navController animated:YES completion:nil];
                                                //NSLog(@"User pressed Cancel button");
                                                break;

                                            case LAErrorUserFallback:
                                                [self presentViewController:navController animated:YES completion:nil];
                                                //NSLog(@"User pressed \"Enter Password\"");
                                                break;

                                            case LAErrorTouchIDNotAvailable:
                                                [self presentViewController:navController animated:YES completion:nil];
                                                //NSLog(@"Touch ID is not configured");
                                                break;

                                            case LAErrorTouchIDNotEnrolled:
                                                [self presentViewController:navController animated:YES completion:nil];
                                                //[self showMessage:@"Touch ID is not configured" withTitle:@"Error"];
                                                //NSLog(@"Touch ID is not configured");
                                                break;
                                        }
                                    }
                                }];
        }
    }
    UIBarButtonItem *lpButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Забыли пароль?"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(lpViewButton:)];

    if ([passcodeF objectForKey:@"Secrets"])
    {
        viewController.navigationItem.rightBarButtonItem = lpButton;
    }

    // else if ([[settingsVKP objectForKey:@"sTouchID"] boolValue] == NO)
    // {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        viewController.navigationItem.title = @"VKPass";
        [self presentViewController:navController animated:YES completion:nil];
    // }
    return viewController;
    //[viewController release];
}

-(id)checkDisablePINVCWithType:(NSString *)typePasscode
{
    disablePasscode = YES;
    [[VKPassLP sharedInstance] noLostPass];
    viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    if ([typePasscode isEqualToString:@"DisablePIN"]) {
      viewController.type = BKPasscodeViewControllerCheckPasscodeType;   // for authentication
    }
    else if ([typePasscode isEqualToString:@"DisableDialogsPIN"]) {
      disablePasscode = NO;
      viewController.type = BKPasscodeViewControllerDisableDialogsPasscodeType;
    }
    //viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(passcodeViewCloseButtonPressed:)];
    settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
    if ([[settingsVKP objectForKey:@"sPINHard"] boolValue])
    {
        viewController.passcodeStyle = BKPasscodeInputViewNormalPasscodeStyle; // for ASCII style passcode.
    }
    else
    {
        viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
    }

    // To supports Touch ID feature, set BKTouchIDManager instance to view controller.
    // It only supports iOS 8 or greater.
    viewController.touchIDManager = [[BKTouchIDManager alloc] initWithKeychainServiceName:BKPasscodeKeychainServiceName];
    viewController.touchIDManager.promptText = @"Scan fingerprint to authenticate";   // You can set prompt text.

    // Show Touch ID user interface
    [viewController startTouchIDAuthenticationIfPossible:^(BOOL prompted) {

        // If Touch ID is unavailable or disabled, present passcode view controller for manual input.
        if (NO == prompted) {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            viewController.navigationItem.title = @"VKPass";
            /*
            UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
                                            initWithTitle:@"Закрыть"
                                            style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(closeView:)];
            viewController.navigationItem.leftBarButtonItem = closeButton;
             */
            [self presentViewController:navController animated:YES completion:nil];
            //[self pushController:viewController];
        }
    }];
    return viewController;
}

-(id)checkDisableVKPINVC
{
    disableVKPasscode = YES;
    [[VKPassLP sharedInstance] noLostPass];
    viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    viewController.type = BKPasscodeViewControllerCheckDisablePasscodeType;   // for authentication
    //viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(passcodeViewCloseButtonPressed:)];
    settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
    if ([[settingsVKP objectForKey:@"sPINHard"] boolValue])
    {
        viewController.passcodeStyle = BKPasscodeInputViewNormalPasscodeStyle; // for ASCII style passcode.
    }
    else
    {
        viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
    }

    // To supports Touch ID feature, set BKTouchIDManager instance to view controller.
    // It only supports iOS 8 or greater.
    viewController.touchIDManager = [[BKTouchIDManager alloc] initWithKeychainServiceName:BKPasscodeKeychainServiceName];
    viewController.touchIDManager.promptText = @"Scan fingerprint to authenticate";   // You can set prompt text.

    // Show Touch ID user interface
    [viewController startTouchIDAuthenticationIfPossible:^(BOOL prompted) {

        // If Touch ID is unavailable or disabled, present passcode view controller for manual input.
        if (NO == prompted) {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            viewController.navigationItem.title = @"VKPass";
            [self presentViewController:navController animated:YES completion:nil];
            //[self pushController:viewController];
        }
    }];
    return viewController;
}

-(id)deletePINVC
{
    deletePasscode = YES;
    [[VKPassLP sharedInstance] noLostPass];
    viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    viewController.type = BKPasscodeViewControllerDeletePasscodeType;   // for authentication
    //viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(passcodeViewCloseButtonPressed:)];
    settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
    if ([[settingsVKP objectForKey:@"sPINHard"] boolValue])
    {
        viewController.passcodeStyle = BKPasscodeInputViewNormalPasscodeStyle; // for ASCII style passcode.
    }
    else
    {
        viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
    }

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Отменить"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(closeView:)];
    viewController.navigationItem.leftBarButtonItem = closeButton;

    // To supports Touch ID feature, set BKTouchIDManager instance to view controller.
    // It only supports iOS 8 or greater.
    viewController.touchIDManager = [[BKTouchIDManager alloc] initWithKeychainServiceName:BKPasscodeKeychainServiceName];
    viewController.touchIDManager.promptText = @"Scan fingerprint to authenticate";   // You can set prompt text.

    // Show Touch ID user interface
    [viewController startTouchIDAuthenticationIfPossible:^(BOOL prompted) {

         //If Touch ID is unavailable or disabled, present passcode view controller for manual input.
        if (NO == prompted) {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            viewController.navigationItem.title = @"VKPass";
            [self presentViewController:navController animated:YES completion:nil];
            //[self pushController:viewController];
        }
    }];
    return viewController;
}

- (id)lostPassword
{
    viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    reloadSettings();
    if ([passcodeF objectForKey:@"Passcode"] && ![passcodeF objectForKey:@"Secrets"])
    {
        [[VKPassLP sharedInstance] lostPass];
        viewController.type = BKPasscodeViewControllerNewPasscodeType;
    }
    else if ([passcodeF objectForKey:@"Passcode"] && [passcodeF objectForKey:@"Secrets"])
    {
        [[VKPassLP sharedInstance] authSecret];
        viewController.type = BKPasscodeViewControllerCheckPasscodeType;
    }
    viewController.delegate = self;
    viewController.passcodeStyle = BKPasscodeInputViewNormalPasscodeStyle;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.navigationItem.title = @"VKPass";
    [self presentViewController:navController animated:YES completion:nil];
    return viewController;
}

- (void)lpViewButton:(id)sender
{
    [self lostPassword];
}

- (void)closeViewSetPass:(id)sender
{
    NSMutableDictionary *settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
    [settingsVKP setValue:@NO forKey:@"sPINEnabled"];
    [settingsVKP writeToFile:settingsPath atomically:NO];
    [viewController dismissViewControllerAnimated:YES completion:nil];
    //exit(0);
}

- (void)closeView:(id)sender
{
    deletePasscode = NO;
    [viewController dismissViewControllerAnimated:YES completion:nil];
    //exit(0);
}

- (void)passcodeViewController:(BKPasscodeViewController *)aViewController authenticatePasscode:(NSString *)aPasscode resultHandler:(void (^)(BOOL))aResultHandler
{
    passcodeF = [[NSMutableDictionary alloc] initWithContentsOfFile:passcodePath];
    NSString *key = @"Moifjn989ncv9ca0(*f3j09c0(Ulfv3-lo+_KLc30-";
    NSString *passcodeEncrypted = nil;
    int lostP = [[VKPassLP sharedInstance] z];
    if (lostP == 1 || lostP == 2)
        passcodeEncrypted = [FBEncryptorAES decryptBase64String:[passcodeF objectForKey:@"Secrets"] keyString:key];
    else
        passcodeEncrypted = [FBEncryptorAES decryptBase64String:[passcodeF objectForKey:@"Passcode"] keyString:key];
    if ([aPasscode isEqualToString:passcodeEncrypted])
    {
        _lockUntilDate = nil;
        _failedAttempts = 0;
        aResultHandler(YES);
        if(disablePasscode == YES)
        {
            //NSLog(@"YEP");
            NSMutableDictionary *settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
            [settingsVKP setValue:@NO forKey:@"sPINEnabled"];
            [settingsVKP writeToFile:settingsPath atomically:NO];
            disablePasscode = NO;
        }
        if(disableVKPasscode == YES)
        {
            NSMutableDictionary *settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
            [settingsVKP setValue:@NO forKey:@"sPINVKEnabled"];
            [settingsVKP writeToFile:settingsPath atomically:NO];
            disableVKPasscode = NO;
        }
        if(deletePasscode == YES)
        {
            NSMutableDictionary *settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
            [settingsVKP setValue:@NO forKey:@"sPINEnabled"];
            [settingsVKP setValue:@NO forKey:@"sDialPass"];
            [settingsVKP setValue:@NO forKey:@"sTouchID"];
            [settingsVKP writeToFile:settingsPath atomically:NO];
               CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("ru.anonz.vkpassbundle/post"), NULL, NULL, YES);
            //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            //NSString *documentsDirectory = [paths objectAtIndex:0];
            //NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/Documents/ru.anonz.vkpasscode.plist"];

            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:passcodePath error:&error];
            // if(![[NSFileManager defaultManager] removeItemAtPath:passcodePath error:&error])
            // {
            //     //TODO: Handle/Log error
            // }
            deletePasscode = NO;
        }
        if(lostP == 2)
        {
            passcodeEncrypted = [FBEncryptorAES decryptBase64String:[passcodeF objectForKey:@"Passcode"] keyString:key];
            NSString *localizationMessage;
            NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
            if ([language isEqualToString:@"ru"]) {
                    localizationMessage = [NSString stringWithFormat:@"Пароль удален, был %@", passcodeEncrypted];
            } else {
                    localizationMessage = [NSString stringWithFormat:@"Passcode deleted, was %@", passcodeEncrypted];
            }
            [UIAlertView showWithTitle:@"VKPass"
                                                 message:localizationMessage
                             cancelButtonTitle:@"ОК"
                             otherButtonTitles:nil
                                                tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                        if (buttonIndex == [alertView cancelButtonIndex])
                                                        {

                                                        }
                                                }];
            NSMutableDictionary *settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
            [settingsVKP setValue:@NO forKey:@"sPINEnabled"];
            [settingsVKP setValue:@NO forKey:@"sDialPass"];
            [settingsVKP writeToFile:settingsPath atomically:NO];
            passcodeF = [[NSMutableDictionary alloc] initWithContentsOfFile:passcodePath];
            [passcodeF removeObjectForKey:@"Passcode"];
            [passcodeF writeToFile:passcodePath atomically:NO];
        }
    }
    else
    {
        aResultHandler(NO);
        if(disablePasscode == YES)
        {
            NSMutableDictionary *settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
            [settingsVKP setValue:@YES forKey:@"sPINEnabled"];
            [settingsVKP writeToFile:settingsPath atomically:NO];
        }
        if(disableVKPasscode == YES)
        {
            NSMutableDictionary *settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
            [settingsVKP setValue:@YES forKey:@"sPINVKEnabled"];
            [settingsVKP writeToFile:settingsPath atomically:NO];
        }
        if(deletePasscode == YES)
        {
            NSMutableDictionary *settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
            [settingsVKP setValue:@YES forKey:@"sPINEnabled"];
            [settingsVKP setValue:@YES forKey:@"sPINVKEnabled"];
            [settingsVKP writeToFile:settingsPath atomically:NO];
        }
        if(lostP == 2)
        {
            NSMutableDictionary *settingsVKP = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
            [settingsVKP setValue:@YES forKey:@"sPINEnabled"];
            [settingsVKP setValue:@YES forKey:@"sDialPass"];
            [settingsVKP writeToFile:settingsPath atomically:NO];
        }
    }
}



- (void)passcodeViewControllerDidFailAttempt:(BKPasscodeViewController *)viewControllerwww
{
    _failedAttempts++;
    //Convert From NSUInteger
    //NSInteger failsUI = (NSInteger)_failedAttempts;
    //[passcodeF setValue:[NSNumber numberWithInt:failsUI] forKey:@"Failed Attempts"];
    //[passcodeF writeToFile:passcodePath atomically:NO];

    //Read attemps from plist
    //NSInteger failsAttemps = [[passcodeF objectForKey:@"Failed Attempts"] intValue];

    if (_failedAttempts > 5) {

        NSTimeInterval timeInterval = 60;

        if (_failedAttempts > 6) {

            NSUInteger multiplier = _failedAttempts - 6;

            timeInterval = (5 * 60) * multiplier;

            if (timeInterval > 3600 * 24) {
                timeInterval = 3600 * 24;
            }
        }

        _lockUntilDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    }
}

- (NSUInteger)passcodeViewControllerNumberOfFailedAttempts:(BKPasscodeViewController *)viewController
{
    return _failedAttempts;
}

- (NSDate *)passcodeViewControllerLockUntilDate:(BKPasscodeViewController *)viewController
{
    return _lockUntilDate;
}

- (void)passcodeViewController:(BKPasscodeViewController *)aViewController didFinishWithPasscode:(NSString *)aPasscode
{
  // [self.delegate passcodeHasBeenCreatedWithCode:aPasscode];
    switch (aViewController.type) {
        case BKPasscodeViewControllerNewPasscodeType:
          [self.delegate passcodeHasBeenCreated];
          // [self passcodeSuccessCreated];
          break;
        case BKPasscodeViewControllerCheckDisablePasscodeType:
          [self.delegate passcodeHasBeenDisabled];
          break;
        case BKPasscodeViewControllerCheckDialogsPasscodeType:
          [self.delegate passcodeForDialogsChecked];
          break;
        case BKPasscodeViewControllerDisableDialogsPasscodeType:
          [self.delegate passcodeForDialogsDisabled];
          break;
        case BKPasscodeViewControllerDeletePasscodeType:
          [self.delegate passcodeHasBeenDeleted];
          break;
        case BKPasscodeViewControllerChangePasscodeType:
            self.passcode = aPasscode;
            _failedAttempts = 0;
            _lockUntilDate = nil;
            [self.delegate passcodeHasBeenChanged];
            break;
        default:
            break;

    }
    [aViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)passcodeSuccessCreated {
  UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"VKPass"
                                 message:@"Passcode created!"
                                 preferredStyle:UIAlertControllerStyleAlert];

    //Add Buttons
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];

    //Add your buttons to alert controller
    [alert addAction:okButton];

    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ...

    //[[BKPasscodeLockScreenManager sharedManager] setDelegate:self];

    // ...
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // ...
    // show passcode view controller when enter background. Screen will be obscured from here.
    [[BKPasscodeLockScreenManager sharedManager] showLockScreen:NO];
}

- (BOOL)lockScreenManagerShouldShowLockScreen:(BKPasscodeLockScreenManager *)aManager
{
    return YES;   // return NO if you don't want to present lock screen.
}

- (UIViewController *)lockScreenManagerPasscodeViewController:(BKPasscodeLockScreenManager *)aManager
{
    BKPasscodeViewController *viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    viewController.type = BKPasscodeViewControllerCheckPasscodeType;
    viewController.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
    return viewController;
}

@end
// vim:ft=objc
