# Bandyer SDK CallKit - VoIP Sample

This sample application shows you how it's easy and simple to integrate CallKit and VoIP notifications capabilities with Bandyer in your app.

This example is only related to manage CallKit and VoIP notifications. For other examples, please visit the [Sample apps index page](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples).


## Quickstart

1. Obtain a Mobile API key.
2. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#getting-started).
3. In terminal, run the `pod install` command.
4. Open the project workspace in Xcode.
5. Add `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` keys to the app's Info.plist file.
6. Replace "PUT YOUR APP ID HERE" placeholder inside `AppDelegate` class with the app id provided. 
7. Replace the app bundle identifier and set up code signing if you want to run the example on a real device.
8. Update application capabilities turning on **Background Modes** and **Push Notifications** in your project **Capabilites** tab in Xcode. Flag `Audio, Airplay and Picture in Picture` and `Voice over IP` checkboxes on, under **Background modes** section 
9. Replace "SET YOUR PAYLOAD KEY PATH HERE" keypath placeholder in `notificationPayloadKeyPath` property of configuration class.

## Caveats

This app uses fake users fetched from our backend system. We provide access to those user through a REST api which requires another set of access keys. Once obtained, replace "REST API KEY" and "REST URL" placeholders inside `UserRepository` class.

Bandyer back-end system does not deliver notifications to APNS directly, you must setup your own delivery service or use an online service like [OneSignal](https://onesignal.com/). 

## Usage

#### Notification Payload

The client SDK expects a payload in the following format:

```JSON
{
    "initiator": "usr_e39b045f215f",
    "users": [
      {
        "user": {
          "companyId": "4bf3fe3d-7775-422a-9463-93554a60d2c2",
          "userAlias": "usr_a12f412g31c9",
          "firstName": "",
          "lastName": "",
          "email": null,
          "image": "",
          "role": 80,
          "status": "online",
          "canVideo": true
        },
        "status": "invited"
      },
      {
        "user": {
          "companyId": "4bf3fe3d-7775-422a-9463-93554a60d2c2",
          "userAlias": "usr_e39b045f215f",
          "firstName": "",
          "lastName": "",
          "email": "",
          "image": "",
          "role": 80,
          "status": "online",
          "canVideo": true
        },
        "status": "invited"
      }
    ],
    "roomAlias": "room_d86dc2065fd5",
    "options": {
      "duration": 0,
      "record": false,
      "creationDate": "2019-01-14T15:49:38.752Z",
      "callType": "audio_video"
    }
}

```

You must provide a dictionary to call client `handleNotification:` method formatted with the format above.

For further usage guideline, you can visit our dedicated [Wiki page](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki/VOIP-notifications).

## Support

From here, please have a look to [Bandyer SDK Wiki](https://github.com/Bandyer/Bandyer-iOS-SDK/wiki). You will easly find guides to all the Bandyer world! 

To get basic support please submit an Issue. We will help you as soon as possible.

If you prefer commercial support, please contact bandyer.com sending an email at: [info@bandyer.com](mailto:info@bandyer.com.)

## Credits

- Sample video file taken from [Sample Videos](https://sample-videos.com/).
- Sample user profile images taken from [RANDOM USER GENERATOR](https://randomuser.me/).
- Icons are part of the [Feather icon set](https://www.iconfinder.com/iconsets/feather-2) by [Cole Bemis](https://www.iconfinder.com/colebemis) distributed under [Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/) downloaded from [Iconfinder](https://www.iconfinder.com/) website.

## License

Using this software, you agree to our license. For more details, see [LICENSE](https://github.com/Bandyer/Bandyer-iOS-SDK-Samples/blob/master/LICENSE) file.
