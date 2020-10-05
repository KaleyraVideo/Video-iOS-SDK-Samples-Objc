# Bandyer SDK UI Customization Example

This sample app is going to show you how the Bandyer SDK should be configured, initialized, and how you can interact with it.

This example is only related to let you customize our UI components. For other examples, please visit the [Sample apps index page](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples).

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

To initialize our SDK, start the call and chat modules and push the Bandyer View Controllers please refer to related [Bandyer SDK Wiki](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki) pages. 

### Global UI theme

The core of customization is [BDKTheme](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/BDKTheme.html) class. You can override every property of the theme, typically inside your AppDelegate implementation.

```objective-c
//This is the core of your customisation possibility using Bandyer SDK theme.
//Let's suppose that your app is highly customised. Setting the following properties will let you to apply your colors, bar properties and fonts to all Bandyer's view controllers.
        
//Colors
BDKTheme.defaultTheme.accentColor = a UIColor instance
BDKTheme.defaultTheme.primaryBackgroundColor = a UIColor instance
BDKTheme.defaultTheme.secondaryBackgroundColor = a UIColor instance
BDKTheme.defaultTheme.tertiaryBackgroundColor = a UIColor instance
        
//Bars
BDKTheme.defaultTheme.barTranslucent = TRUE/FALSE
BDKTheme.defaultTheme.barStyle = a UIBarStyle case
BDKTheme.defaultTheme.keyboardAppearance = a UIKeyboardAppearance case
BDKTheme.defaultTheme.barTintColor = a UIColor instance

//Fonts
BDKTheme.defaultTheme.navBarTitleFont = a UIFont instance
BDKTheme.defaultTheme.secondaryFont = a UIFont instance 
BDKTheme.defaultTheme.bodyFont = a UIFont instance
BDKTheme.defaultTheme.font = a UIFont instance
BDKTheme.defaultTheme.emphasisFont = a UIFont instance
BDKTheme.defaultTheme.mediumFontPointSize = a CGFloat
BDKTheme.defaultTheme.largeFontPointSize = a CGFloat
```

We strongly recommend you to read the [UI-customization](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki/UI-customization) wiki page to have a look for the mapping between those properties and the UI components. 

### Call related UI theme

You can also customize every Bandyer view controller using the appropriate configuration object. For the call related view controllers you have to set the BDKTheme kind properties of [BDKCallViewControllerConfiguration](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/BDKCallViewControllerConfiguration.html):

```objective-c
//Here we are configuring the BDKCallWindow instance
//A `BDKCallViewControllerConfiguration` object instance is needed to customize the behaviour and appearance of the view controller.
BDKCallViewControllerConfiguration *config = [[BDKCallViewControllerConfiguration alloc] init];

//Let's suppose that you want to change the navBarTitleFont only inside the BDKCallViewController.
//You can achieve this result by allocate a new instance of the theme and set the navBarTitleFont property whit the wanted value.
BDKTheme *callTheme = [BDKTheme new];
callTheme.navBarTitleFont = [UIFont .robotoBold fontWithSize:30];

config.callTheme = callTheme;

//The same reasoning will let you change the accentColor only inside the Whiteboard view controller.
BDKTheme *whiteboardTheme = [BDKTheme new];
whiteboardTheme.accentColor = [UIColor systemBlueColor];

config.whiteboardTheme = whiteboardTheme;

//You can also customize the theme only of the Whiteboard text editor view controller.
BDKTheme *whiteboardTextEditorTheme = [BDKTheme new];
whiteboardTextEditorTheme.bodyFont = [UIFont .robotoThin fontWithSize:30];

config.whiteboardTextEditorTheme = whiteboardTextEditorTheme;

//In the next lines you can see how it's possible to customize the File Sharing view controller theme.
BDKTheme *fileSharingTheme = [BDKTheme new];
//By setting a point size property of the theme you can change the point size of all the medium/large labels.
fileSharingTheme.mediumFontPointSize = 20;
fileSharingTheme.largeFontPointSize = 40;

config.fileSharingTheme = fileSharingTheme;
```

### Chat channel UI theme

It's also easy to customize the [BCHChannelViewController](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/ChannelViewController.html) using the [BCHChannelViewControllerConfiguration](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/ChannelViewControllerConfiguration.html) class. You just have to init the class passing the BDKTheme object as initialization parameter.

```objective-c
//Let's suppose that you want to change the tertiaryBackgroundColor only inside the ChannelViewController.
//You can achieve this result by allocate a new instance of the theme and set the tertiaryBackgroundColor property whit the wanted value.
BDKTheme *theme = [BDKTheme new];
theme.tertiaryBackgroundColor = [UIColor colorWithRed:204/255.0f green:210/255.0f blue:226/255.0f alpha:1];

BCHChannelViewControllerConfiguration* configuration = [[BCHChannelViewControllerConfiguration alloc] initWithAudioButton:YES videoButton:YES theme: theme];
    
channelViewController.configuration = configuration;
```

### In-app notification UI theme

In the next code snippet you can find an example of how to customize the theme of our In-app notification view.

```objective-c
//Only after the SDK is initialized, you can change the In-app notification theme.
//If you try to set the theme before SDK initialization, the notificationsCoordinator will be nil and the theme will not be applied.

BDKTheme *theme = [BDKTheme new];
theme.secondaryFont = [UIFont.robotoRegular fontWithSize:5];
BandyerSDK.instance.notificationsCoordinator.theme = theme;
```

### Formatters

With our SDK you can decide how the user information are displayed on the screen. You just need to subclass the [NSFormatter](https://developer.apple.com/documentation/foundation/nsformatter) class and implement the `func string(for: Any?) -> String?` casting the Any object to an array of 
[BDKUserInfoDisplayItem](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/latest/Classes/BDKUserInfoDisplayItem.html).

In the next code snippets you will see how to use your custom formatters. 

You can format the way our SDK displays the user information inside the call page:

```objective-c
//Here we are configuring the BDKCallWindow instance
//A `BDKCallViewControllerConfiguration` object instance is needed to customize the behaviour and appearance of the view controller.
BDKCallViewControllerConfiguration *config = [[BDKCallViewControllerConfiguration alloc] init];

//You can also format the way our SDK displays the user information inside the call page. In this example, the user info will be preceded by a percentage.

config.callInfoTitleFormatter = [PercentageFormatter new];
```

You can do the same for the chat channel page:

```objective-c
//In this example, the user info will be preceded by an asterisk.
BCHChannelViewControllerConfiguration* configuration = [[BCHChannelViewControllerConfiguration alloc] initWithAudioButton:YES videoButton:YES formatter:[AsteriskFormatter new]];
```

Only after the SDK is initialized, you can change the In-app notification default formatter. 
If you try to set the formatter before SDK initialization, the notificationsCoordinator will be nil and your custom formatter will not be applied. 
The formatter will be used to display the user information on the In-app notification heading.

```objective-c
//In this example, the user info will be preceded by an hashtag.
BandyerSDK.instance.notificationsCoordinator.formatter = [HashtagFormatter new];
```

## Support

From here, please have a look to [Bandyer SDK Wiki](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki). You will easily find guides to all the Bandyer world! 

To get basic support please submit an Issue. We will help you as soon as possible.

If you prefer commercial support, please contact bandyer.com sending an email at: [info@bandyer.com](mailto:info@bandyer.com).

## Credits

- Sample video file taken from [Sample Videos](https://sample-videos.com/).
- Sample user profile images taken from [RANDOM USER GENERATOR](https://randomuser.me/).
- Icons are part of the [Feather icon set](https://www.iconfinder.com/iconsets/feather-2) by [Cole Bemis](https://www.iconfinder.com/colebemis) distributed under [Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/) downloaded from [Iconfinder](https://www.iconfinder.com/) website.
- Custom font 'Roboto' is taken from [dafont.com](https://www.dafont.com/it/roboto.font).

## License

Using this software, you agree to our license. For more details, see [LICENSE](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples-Swift/blob/master/LICENSE) file.
