# Bandyer SDK Basic Example

This sample app is going to show you how the Bandyer SDK should be configured, initialized, and how you can interact with it.

This example is only related to let users make and receive a call. For other examples, please visit the [Sample apps index page](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples).

## Quickstart

1. Obtain a Mobile API key.
2. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#getting-started) .
3. In terminal, `cd` to the sample project directory you are interested in and type `pod install`.
4. Open the project in Xcode using the `.xcworkspace` file just created.
5. Add `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` keys to the app's Info.plist file.
6. Replace "PUT YOUR APP ID HERE" placeholder inside `AppDelegate` class with the app id provided. 
7. Replace the app bundle identifier and set up code signing if you want to run the example on a real device.

## Caveats

This app uses fake users fetched from our backend system. We provide access to those user through a REST api which requires another set of access keys. Once obtained, replace "REST API KEY" and "REST URL" placeholders inside `UserRepository` class.

If your backend system already provides Bandyer "user alias" for your users, then you should modify the app in order to fetch users information from you backend system instead of ours.

## Usage

In this demo app, all the integration work is already done for you. In this section we will explain how to take advantage of the basic feature provided by Bandyer SDK in another app.

###Initialization

First of all you have to initialize the SDK using the unique instance of [BandyerSDK](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/BandyerSDK.html) and configure it using [BDKConfig](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/BDKConfig.html) class. Yuo can follow this code snippet:

```objective-c
//Here we are going to initialize the Bandyer SDK.
//The sdk needs a configuration object where it is specified which environment the sdk should work in
BDKConfig *config = [BDKConfig new];

//Here we are telling the SDK we want to work in a sandbox environment.
//Beware the default environment is production, we strongly recommend to test your app in a sandbox environment.
config.environment = BDKEnvironment.sandbox;

//Here we are disabling CallKit support. 
//Make sure to disable CallKit, otherwise it will be enable by default if the system supports CallKit (i.e iOS >= 10.0).
config.callKitEnabled = NO;

//Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
[BandyerSDK.instance initializeWithApplicationId:@"PUT YOUR APP ID HERE" config:config];
```
In the demo project, we did it inside `AppDelegate` class, but you can do everywhere you need, just before using our SDK.

###SDK Start

Once the end user has selected which user wants to impersonate, you have to start the SDK client. 

We did it inside the `LoginViewController` class.

```objective-c
//We are registering as a call client observer in order to be notified when the client changes its state.
//We are also providing the main queue telling the SDK onto which queue should notify the observer provided,
//otherwise the SDK will notify the observer onto its background internal queue.
[BandyerSDK.instance.callClient addObserver:self queue:dispatch_get_main_queue()];

//Then we start the call client providing the "user alias" of the user selected.
[BandyerSDK.instance.callClient start:@"SELECTED USER ID"];
```
Yuor class responsible of starting the client has the possibility to become an observer of the [BCXCallClient](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Protocols/BCXCallClient.html) lifecycle, implementing the [BCXCallClientObserver](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Protocols/BCXCallClientObserver.html). Once the `callClientDidStart` callback is fired, you can start to interact with our system.

###Make a Call

In order to make a call, we provide you a custom `UIWindow`: the [CallWindow](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/CallWindow.html).

Inside the `ContactsViewController` class you can find some code snippet on how to manage initialization of a CallWindow instance. Please make sure to have only one instance of CallWindow in memory at a time, otherwise an exception will be thrown. This rule is desingned in a way that your view controllers can share the same ongoing call. 

```objective-c
//Please remember to reference the call window only once in order to avoid the reset of BDKCallViewController.
if (self.callWindow)
{
	return;
}

//Please be sure to have in memory only one instance of BDKCallWindow, otherwise an exception will be thrown.

BDKCallWindow *window;

if (BDKCallWindow.instance)
{
	window = BDKCallWindow.instance;
} else
{
//This will automatically save the new instance inside BDKCallWindow.instance.
	window = [[BDKCallWindow alloc] init];
}

//Remember to subscribe as the delegate of the window. The window  will notify its delegate when it has finished its job.
window.callDelegate = self;

self.callWindow = window;
```

When you want to start a new call, you need to configure the CallWindow instance with a [BDKCallViewControllerConfiguration](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/BDKCallViewControllerConfiguration.html), passing to it your implementation of [BDKUserInfoFetcher](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Protocols/BDKUserInfoFetcher.html) protocol. This protocol is intended to manage your custom formatting of an user instance. The CallViewController will use this fetcher to properly present contact information in its views. For further information on how it works, please have a look to our [sample app](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples/tree/master/UserInfoFetcher-Example) related to this argument. 

```objective-c
//Here we are configuring the BDKCallWindow instance
//A `BDKCallViewControllerConfiguration` object instance is needed to customize the behaviour and appearance of the view controller.
BDKCallViewControllerConfiguration *config = [[BDKCallViewControllerConfiguration alloc] init];

//This url points to a sample mp4 video in the app bundle used only if the application is run in the simulator.
NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SampleVideo_640x360_10mb" ofType:@"mp4"]];
config.fakeCapturerFileURL = url;

//This statement tells the view controller which object, conforming to `BDKUserInfoFetcher` protocol, should use to present contact
//information in its views.
//The backend system does not send any user information to its clients, the SDK and the backend system identify the users in a call
//using their user aliases, it is your responsibility to match "user aliases" with the corresponding user object in your system
//and provide those information to the view controller
config.userInfoFetcher = [[UserInfoFetcher alloc] initWithAddressBook:self.addressBook];

//Here, we set the configuration object created. You must set the view controller configuration object before the view controller
//view is loaded, otherwise an exception is thrown.
//If a call is already ongoing, the new configuration is skipped.
[self.callWindow setConfiguration:config];
```

Once the CalllWindow is inited and the CallViewController is properly configured, you can present it, passing an implementation of [BDKIntent](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Protocols/BDKIntent.html) protocol to the CallWindow. In this sample app, we support two kind of call: outgoing and incoming, so there are two implementations of intent for the same ([BDKMakeCallIntent](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/BDKMakeCallIntent.html) and [BDKIncomingCallHandlingIntent](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/BDKIncomingCallHandlingIntent.html)).

```objective-c
//To start an outgoing call we must create a `BDKMakeCallIntent` object specifying who we want to call, the type of call
//we want to be performed, along with any call option.

//Here we create the array containing the "user aliases" we want to contact.
NSMutableArray *aliases = [NSMutableArray arrayWithCapacity:self.selectedContacts.count];
for (NSIndexPath *indexPath in self.selectedContacts)
{
	[aliases addObject:self.addressBook.contacts[(NSUInteger) indexPath.row].alias];
}

//Then we create the intent providing the aliases array (which is a required parameter) along with the type of call we want perform.
//The record flag specifies whether we want the call to be recorded or not.
//The maximumDuration parameter specifies how long the call can last.
//If you provide 0, the call will be created without a maximum duration value.
//We store the intent for later use, because we can present again the BDKCallViewController with the same call.
self.intent = [BDKMakeCallIntent intentWithCallee:aliases type:self.options.type record:self.options.record maximumDuration:self.options.maximumDuration];
```

```objective-c
//When the client detects an incoming call it will notify its observers through this method.
//Here we are creating an `BDKIncomingCallHandlingIntent` object, storing it for later use,
self.intent = [[BDKIncomingCallHandlingIntent alloc] init];
```

Since there must be only one ongoing call at a time, the CallViewController will be presented only if there is no an ongoing call or if you want to present a call that is already ongoing.

```objective-c
//Here we tell the call window what it should do and we present the BDKCallViewController if there is no another call in progress.
//Otherwise you should manage the behaviour, for example with a UIAlert warning.

[self.callWindow shouldPresentCallViewControllerWithIntent:self.intent completion:^(BOOL succeeded) {

	if (!succeeded)
	{
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Another call ongoing." preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
              [alert dismissViewControllerAnimated:YES completion:nil];
         }];

         [alert addAction:defaultAction];
         [self presentViewController:alert animated:YES completion:nil];
 	}
}];
```

###Call Banner View

When there is an ongoing call but the CallViewController is not presented, your view controller can show a green banner view just under the status bar. The custom `UIView` that the SDK will show is the [CallBannerView](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/CallBannerView.html).

Yuo don't have to manage by yourself the behaviour of the banner, inside the SDK you can find the [CallBannerController](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/CallBannerController.html) that does the job for you.

You can easly init the controller using this code snippet:

```objective-c
_callBannerController = [BDKCallBannerController new];
```

Once inited, you have to setup the controller, attaching the delegate and the view controller. If you don't pass the parentViewController an exception will be throwed, since the call banner controller needs it to add the banner to your view hierarchy.

```objective-c
self.callBannerController.delegate = self;
self.callBannerController.parentViewController = self;
```

When your view controller is hidden you have to tell the call banner controller to stop work on your view controller. You can achieve this result using the `show` and `hide` methods:

```objective-c
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.callBannerController show];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.callBannerController hide];
}  
```

Since the size of the banner changes with orientation, you have to update the UI of the banner:

```objective-c
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    //Remember to call viewWillTransitionTo on custom view controller to update UI while rotating.
    [self.callBannerController viewWillTransitionTo:size withTransitionCoordinator:coordinator];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
```

On `ContactsViewController` class you can find all this code snippets working and commented, plus more (like the management of transition between `CallBannerView` and `CallViewController`).

## Support

From here, please have a look to [Bandyer SDK Wiki](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki). You will easly find guides to all the Bandyer world! 

To get basic support please submit an Issue. We will help you as soon as possible.

If you prefer commercial support, please contact bandyer.com sending an email at: [info@bandyer.com](mailto:info@bandyer.com.)

## Credits

- Sample video file taken from https://sample-videos.com/
- Sample user profile images taken from https://randomuser.me/
- Icons are part of the [Feather icon set](https://www.iconfinder.com/iconsets/feather-2) by [Cole Bemis](https://www.iconfinder.com/colebemis) distributed under [Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/) downloaded from [Iconfinder](https://www.iconfinder.com/) website.

## License

Using this software, you agree to our license. For more details, see [LICENSE](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples/blob/master/LICENSE) file.
