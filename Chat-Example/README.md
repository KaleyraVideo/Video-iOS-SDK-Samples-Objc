# Bandyer SDK Chat Example

This sample app is going to show you how the Bandyer SDK should be configured, initialized, and how you can interact with it.

This example is only related to let users make and receive messages from the chat service. For other examples, please visit the [Sample apps index page](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples).

## Quickstart

1. Obtain a Mobile API key.
2. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#getting-started) .
3. In terminal, `cd` to the sample project directory you are interested in and type `pod install`.
4. Open the project in Xcode using the `.xcworkspace` file just created.
5. Replace "PUT YOUR APP ID HERE" placeholder inside `AppDelegate` class with the app id provided. 
6. Replace the app bundle identifier and set up code signing if you want to run the example on a real device.

## Caveats

This app uses fake users fetched from our backend system. We provide access to those user through a REST api which requires another set of access keys. Once obtained, replace "REST API KEY" and "REST URL" placeholders inside `UserRepository` class.

If your backend system already provides Bandyer "user alias" for your users, then you should modify the app in order to fetch users information from you backend system instead of ours.

## Usage

In this demo app, all the integration work is already done for you. In this section we will explain how to take advantage of the feature provided by Bandyer SDK in another app.

### Setup

To let you build on physical devices, you should set *No* to  *Enable Bitcode* on **Build Settings** tab under **Build Options** section of your target settings.

### Initialization

First of all you have to initialize the SDK using the unique instance of [BandyerSDK](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/BandyerSDK.html) and configure it using [BDKConfig](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/BDKConfig.html) class. You can follow this code snippet:

```objective-c
//Here we are going to initialize the Bandyer SDK.
//The sdk needs a configuration object where it is specified which environment the sdk should work in.
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

### Chat client start

Once the end user has selected which user wants to impersonate, you have to start the SDK client. 

We did it inside the `LoginViewController` class.

```objective-c
//We are registering as a chat client observer in order to be notified when the client changes its state.
//We are also providing the main queue telling the SDK onto which queue should notify the observer provided,
//otherwise the SDK will notify the observer onto its background internal queue.
[BandyerSDK.instance.chatClient addObserver:self queue:dispatch_get_main_queue()];

//Here we start the chat client, providing the "user alias" of the user selected.
[BandyerSDK.instance.chatClient start:@"SELECTED USER ID"];
```

Your class responsible of starting the client has the possibility to become an observer of the [BCHChatClient](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Protocols/BCHChatClient.html) life cycle, implementing the [BCHChatClientObserver](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Protocols/BCHChatClientObserver.html). Once the `chatClientDidStart` callback is fired, you can start to interact with our system.

Please remember to stop the chat client once the user wants to log out. In this way it's possible to start again the chat client whit a new user.

```objective-c
[BandyerSDK.instance.chatClient stop];
```

### Start a chat

In order to chat, we provide you a custom `UIViewController`: the [BCHChannelViewController](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/ChannelViewController.html).

Inside the `ContactsViewController` class you can find some code snippet on how to manage initialization of a ChannelViewController instance. 

When you want to start a new chat session, you need to configure the ChannelViewController instance with a [BCHChannelViewControllerConfiguration](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/ChannelViewControllerConfiguration.html):

```objective-c
BCHChannelViewController *channelViewController = [[BCHChannelViewController alloc] init];
channelViewController.delegate = self;

//Here we are configuring the channel view controller:
// if audioButton is true, the channel view controller will show audio button on nav bar;
// if videoButton is true, the channel view controller will show video button on nav bar;

BCHChannelViewControllerConfiguration* configuration = [[BCHChannelViewControllerConfiguration alloc] initWithAudioButton:YES videoButton:YES];

//Otherwise you can use other initializer.
//BCHChannelViewControllerConfiguration* configuration = [[BCHChannelViewControllerConfiguration alloc] init]; //Equivalent to BCHChannelViewControllerConfiguration* configuration = [[BCHChannelViewControllerConfiguration alloc] initWithAudioButton:NO videoButton:NO];

//If no configuration is provided, the default one will be used, the one with nil user info fetcher and showing both of the buttons 
//-> [[BCHChannelViewControllerConfiguration alloc] initWithAudioButton:YES videoButton:YES];

channelViewController.configuration = configuration;
```

Once the ChannelViewController is properly configured, you have to pass an instance of [OpenChatIntent](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/OpenChatIntent.html) to it. You can open the chat controller directly with the counterpart id or from a `BCHChatNotification` instance.

```objective-c
BCHOpenChatIntent *intent = [BCHOpenChatIntent openChatWith:@"Counterpart ID"];
```

```objective-c
(BCHChatNotification *)notification;

BCHOpenChatIntent *intent = [BCHOpenChatIntent openChatFrom:notification];
```

```objective-c
//Please make sure to set intent after configuration, otherwise the configuration will be not taking in charge.
channelViewController.intent = intent;
```
Finally, you can present the ChannelViewController.

```objective-c
[controller presentViewController:channelViewController animated:YES completion:nil];
```

### Message Notification View

When your logged user receives a chat message, your view controller can show a custom `UIView` at the top of the screen. This view acts like a in-app notification, so user can click it to open the chat or can dismiss it just swiping to the top.

You don't have to manage by yourself the behaviour of the notification view, inside the SDK you can find the [BDKInAppNotificationsCoordinator](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Protocols/BDKInAppNotificationsCoordinator.html) that does the job for you.

To enable view the chat In-app notifications, you have to start the coordinator. 
You can start it only after the BandyerSDK is initialized, otherwise the notificationsCoordinator will be nil, 

You can easily start the coordinator using this code snippet:

```objective-c
[BandyerSDK.instance.notificationsCoordinator start];
```

Once started, if you want to be notified of the touch events on the notification view, you have to attach the chat listener.

```objective-c
BandyerSDK.instance.notificationsCoordinator.chatListener = self;
```

Please remember to stop the notificationsCoordinator when your view controller will disappear, so the view controller will dispaly no more the In-app notification view.

```objective-c
[BandyerSDK.instance.notificationsCoordinator stop];
```

On `ContactsViewController` class you can find all this code snippets working and commented, plus more (like the management of transition between `BCHChatNotification` and `BCHChannelViewController`).

## Support

From here, please have a look to [Bandyer SDK Wiki](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki). You will easily find guides to all the Bandyer world! 

To get basic support please submit an Issue. We will help you as soon as possible.

If you prefer commercial support, please contact bandyer.com sending an email at: [info@bandyer.com](mailto:info@bandyer.com).

## Credits

- Sample video file taken from [Sample Videos](https://sample-videos.com/).
- Sample user profile images taken from [RANDOM USER GENERATOR](https://randomuser.me/).
- Icons are part of the [Feather icon set](https://www.iconfinder.com/iconsets/feather-2) by [Cole Bemis](https://www.iconfinder.com/colebemis) distributed under [Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/) downloaded from [Iconfinder](https://www.iconfinder.com/) website.

## License

Using this software, you agree to our license. For more details, see [LICENSE](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples/blob/master/LICENSE) file.
