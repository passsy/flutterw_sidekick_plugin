## Flutter Wrapper Sidekick Plugin

Plugin for [phntmxyz/sidekick](https://github.com/phntmxyz/sidekick)

Pins a Flutter version with [`flutter_wrapper`](https://github.com/passsy/flutter_wrapper) and exposes two commands via the Sidekick CLI:
- `<cli> flutter` - runs the pinned Flutter version
- `<cli> dart` - runs the pinned Dart version

You can continue using the `flutter()` and `dart()` functions in your scripts, because `flutterSdkPath: '.flutter'` binds the pinned SDK. 
If you want to be explicit, use `flutterw()`.

## Installation

```bash
<cli> sidekick plugins install flutterw_sidekick_plugin
```

## License

```
Copyright 2022 Pascal Welsch

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```