import 'objects.dart';

/// Declares objects that are not supported in HTML5 Standard. These should therefore not be used in a HTML5 interface.
/// The build system takes note of this and excludes all instances of the object this annotation is annotated to.
/// 
/// The [info] field gives information about what alternative can be used instead.
class NoHTML5 extends RestrictedAnnotation {
  const NoHTML5({required super.info});
}


const html5 = AnnotationObject(info: 'This object is only allowed in HTML5');

/// Declares objects that are not supported in HTML5 Standard. These should therefore not be used in a HTML5 interface.
/// The build system takes note of this and excludes all instances of the object this annotation is annotated to.
const nohtml5 = RestrictedAnnotation(info: 'This object is not allowed in HTML5');