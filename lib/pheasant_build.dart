
/// This library is not intended for use within this package, but is used by sibling packages like pheasant_build for the [createApp] function.
/// 
/// The reason this library is separate from [pheasant_temp] is becuase of unsupported libraries like "dart:html".
/// 
/// In this library, the base definition for [RavenTemplate] is defined here, and so is used for external functions or processes, 
/// like the files built from the text returned by [renderFunc] and [renderMain], in order to make use of the functionality during build processes.
/// 
// TODO: Include description of new [State] library, and annotations.
library pheasant_build;

export 'src/base.dart';
export 'src/state/state.dart';
export 'package:pheasant_meta/src/meta/metadata.dart';
export 'package:pheasant_meta/src/meta/pheasant_temp/props.dart' hide BuildAnnotationObject;