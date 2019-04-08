# dine-out

This iOS App uses the Google Places REST API and the 
IBM Watson Tone Analyzer REST API to list nearby restaurants 
filtered by keyword.

The app uses RxSwift with MVVM. Services for Google Places 
and the Tone Analyzer client publish events on ReplaySubjects, 
that are subscribed to by the ViewModel. The ViewModel publishes 
updates to view model sequences, that are consumed by the 
ViewController.

The Google Places client tries to fetch the current location 
after location permissions are granted, on app startup, and 
before the View Controller appears. A REST call to the Google 
Places 'nearby" search fetches restaurants nearby, filtered 
by a keyword. A REST call then fetches details about the 
retrieved places, including reviews. The reviews are sent 
to the Tone Analyzer to request the set of all tones detected 
in the reviews.

### Building and Running the App with XCode

- Create a property list file 
named **ApiKeys.plist**, with two key-value pairs:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>ToneAnalyzerApiKey</key>
	<string>YOUR-TONE-ANALYZER-KEY</string>
	<key>GoogleCloudPlatformApiKey</key>
	<string>YOUR-GOOGLE_CLOUD-PLATFORM-KEY</string>
</dict>
</plist>
```

- cd into the root directory and enter `pod install`
- click on **dineout.xcworkspace** to open the project
- Set your bundle id and your team in Project settings
- Build and run   

See this link for a demo:
[Dine Out Demo](https://youtu.be/z68OES3vns0)
