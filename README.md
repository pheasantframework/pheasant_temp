# <center>Raven <br /> The Raven Template Engine</center>
<!-- Add basic info about this thing -->
Welcome to the Raven Templating engine package. 



This package is used to render content from .raven files into dart template files to be used during build time.

This resource is not intended for use by the end user or for general use, but mainly for the background/behind-the-scenes working of the Raven Framework. 
It can be used for low-level handling of raven file data.

### Some things to note

This package is constantly under development, and may not be perfect. If you have any issues with this package, or any packages that depend on it because of this package, please feel free to raise an issue, and we will work on it. 

If you have any contributions to make, feel free. Please read the Contributing document, and make your contributions as guided. All contributions concerning this package are welcome and are reviewed in order to constantly give performant features.

## Features

For basic usage of this package, there really isn't much to it. 

There is only one basic function, `renderFunc`, which takes in two required and one optional parameter: **`script`**, which represents the script portion of a '.raven' file, **`template`** which represents the template part of a '.raven' file, and the optional **`buildExtension`** parameter, which must represent the extension of built raven files (when building them to dart files) when using this package as a part of the much larger Raven Framework - by default, it is set to `'.raven.dart'`.

The function returns the desired Dart Code Composition for the built raven file, including all necessary imports and the Component Class. In the later future, the code will be optimized, and there may be alternative ways to achieve this effect, but would be presented differently. The Dart Code Composition is formatted and returned as a `String`.

## Getting started

In order to install this package, you can use the `dart pub` command as you would with any other raven package.

```bash
dart pub add dev:raven_temp # Dev Dependency

dart pub add raven_temp # Dependency
```

You can also clone this git repository and work with it from there.

Afterwards, you can make use of the features in the package by adding the necessary import

```dart
import 'package:raven_temp/raven_temp.dart';
```

## Usage
Here is an example usage of the `renderFunc` function.

```dart
import 'package:raven_temp/raven_temp.dart';


void main() {
  print(
    renderFunc(script: """
String myData = "Hello World";
""", template: """
<div>
  Welcome to Raven
  <p>{{myData}}</p>
</div>
""")
  );
}

```

## Contributing

All contributions are welcome, and we continuously review them to make necessary and important changes to our framework.

Please read the [contribution file](./CONTRIBUTING.md) for more information on how you can make a contribution.

## License
This package is licensed under the same license as the Raven Framework. For more info [check it out](./LICENSE)

## Additional information

For more information on how this package is used in the Raven Framework, please check out the full framework on [Github]() or on [Dart Pub]().
