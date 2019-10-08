# Bandyer SDK Basic Example

This sample app is going to show you how the Bandyer SDK should be configured, initialized, and how you can interact with it.

This example is only related to let users make and receive a call. For other examples, please visit the git [index page](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples).

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

First of all you have to initialize the SDK using the unique instance of [BandyerSDK](https://docs.bandyer.com/Bandyer-iOS-SDK/BandyerSDK/Classes/BandyerSDK.html) and configure it using this code snippet:

```objective-c
//Here we are going to initialize the Bandyer SDK
//The sdk needs a configuration object where it is specified which environment the sdk should work in
BDKConfig *config = [BDKConfig new];

//Here we are telling the SDK we want to work in a sandbox environment.
//Beware the default environment is production, we strongly recommend to test your app in a sandbox environment.
config.environment = BDKEnvironment.sandbox;

//Here we are disabling CallKit support
config.callKitEnabled = NO;

//Now we are ready to initialize the SDK providing the app id token identifying your app in Bandyer platform.
[BandyerSDK.instance initializeWithApplicationId:@"PUT YOUR APP ID HERE" config:config];
```
In the demo project, we did it inside `AppDelegate` class, but you can do everywhere you need, just before using our SDK.

###SDK Start



## Support

To get basic support please submit an Issue

If you prefer commercial support, please contact bandyer.com sending an email at: [info@bandyer.com](mailto:info@bandyer.com.)

## Credits

- Sample video file taken from https://sample-videos.com/
- Sample user profile images taken from https://randomuser.me/
- Icons are part of the [Feather icon set](https://www.iconfinder.com/iconsets/feather-2) by [Cole Bemis](https://www.iconfinder.com/colebemis) distributed under [Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/) downloaded from [Iconfinder](https://www.iconfinder.com/) website.

## License

Using this software, you agree to our license. For more details, see [LICENSE](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples/blob/master/LICENSE) file.
