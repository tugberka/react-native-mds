
# react-native-mds / React Native Movesense Library

## Getting started

`$ npm install react-native-mds --save`

### RN 60 and later

add `Movesense` to your `ios/Podfile`

```
pod 'Movesense', :git => 'ssh://git@altssh.bitbucket.org:443/suunto/movesense-mobile-lib.git'
```

### Mostly automatic installation

`$ react-native link react-native-mds`

### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-mds` and add `RNMds.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNMds.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.mdsrn.RNMdsPackage;` to the imports at the top of the file
  - Add `new RNMdsPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-mds'
  	project(':react-native-mds').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-mds/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-mds')
  	```
### Additional steps

#### iOS

1. Intall Movesense iOS library using CocoaPods with adding this line to your app's Podfile:
  ```
  pod 'Movesense', :git => 'ssh://git@altssh.bitbucket.org:443/suunto/movesense-mobile-lib.git'
  ```
2. Add 'libmds.a' from Movesense pod to your list of linked libraries. You may need to also add library search path for it.

#### Android

1. Download 'mdslib-x.x.x-release.aar' from movesense-mobile-lib repository and put it somewhere under 'android' folder of your app. Preferably create a new folder named 'android/libs' and put it there. Minimum supported version is 1.6.0.

2. In 'build.gradle' of your android project, add the following lines (assuming .aar file is in android/libs):
```
allprojects {
    repositories {
        ...
        flatDir{
            dirs "$rootDir/libs"
        }
    }
}
```

### Troubleshoot

#### Android

1. 'minSdkVersion' needs to be at least 18.

#### iOS

1. You may need to set "Swift Language Version" for Movesense Pod to 3.2 or 4.0. This setting can be found in "Build Settings" of Movesense pod in XCode project of your app.

2. If you get the following error while building your app:

```
ld: library not found for -lswiftSwiftOnoneSupport for architecture arm64
```

then you need to add library search path for that library. One of the common places is:

```
-L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphoneos
```

However, the correct answer may depend on XCode version.

3. Movesense library doesn't have bitcode support at the moment. You need to disable it for your app as well.

## Usage
```javascript
import MDS from 'react-native-mds';

// Scan for bluetooth devices
MDS.scan((name, address) => {this.scanHandler(name, address);})

// Stop scanning
MDS.stopScan();

// Set dis/connection handlers
MDS.setHandlers((serial) => { this.deviceConnected(serial) },
(serial) => { this.deviceDisconnected(serial) });

// Connect to a device using address
MDS.connect(address);

// Disconnect from a device using address
MDS.disconnect(address);

// Get a resource
MDS.get(serial, resource, contract,
   (response) => { this.onResponse(response) },
   (error) => { this.onError(error) });

// Put a resource
MDS.put(serial, resource, contract,
  (response) => { this.onResponse(response) },
  (error) => { this.onError(error) });

// Post a resource
MDS.post(serial, resource, contract,
   (response) => { this.onResponse(response) },
   (error) => { this.onError(error) });

// Del a resource
MDS.del(serial, resource, contract,
  (response) => { this.onResponse(response) },
  (error) => { this.onError(error) });

// Subscribe to a resource
var key = MDS.subscribe(serial, resource, contract,
  (notification) => { this.onResponse(notification) },
  (error) => { this.onError(error) }));

// Unsubscribe from a subsciption
MDS.unsubscribe(key);
```

## Example

Very soon!
