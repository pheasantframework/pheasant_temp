import 'dart:html' show Element;

import 'package:pheasant_meta/pheasant_meta.dart' show From;

import 'state/state.dart' show TemplateState;

/// The base class for all Pheasant App Components
///
/// All Pheasant app components are derived from this base class, and are used to render pheasant code internally and return the desired html app component.
///
/// Every [PheasantTemplate] class instance has two main parts:
///
/// 1. The `template` field, which represents the pheasant template string that is to be rendered.
/// The [template] variable is of type [String] and is automatically overrided for every instance of this class from the `renderFunc` function
///
/// 2. The `render` function, which returns the rendered html element to be injected into the DOM.
/// The [render] function takes in one required parameter, the [template], and one optional parameter, [state].
/// There is no base definition of this function, as the definition of the function is generated by the `renderFunc` function.
///
/// Any other variables or functions defined in the `<script>` part of the `.phs` file, is added as normal fields and methods repsectively to the class.
///
/// Here is an instance of this class definition:
///
/// ```
/// class MyComponent extends PheasantTemplate {
///   @override
///   String? template = """
/// <div>
///   <p>Hello World</p>
/// </div>
/// """
///
///   PheasantTemplate({super.template});
///
///   @override
///   Element render(String temp) {
///     // Generated Code
///     return element;
///   }
/// }
/// ```
///
/// This class is not intended for direct usage, but mainly for implementation
abstract class PheasantTemplate {
  /// The `template` variable, which forms the html text body to be rendered.
  String? template;

  PheasantTemplate({required this.template});

  @From('0.1.3')
  void init() {}

  @From('0.1.3')
  void del() {}

  /// The `render` function.
  ///
  /// This function accepts two parameters:
  /// `temp` which is of type [String] which represents the desired templating string to be rendered, and
  /// `state` which represents the state of the application, as a [TemplateState].
  ///
  /// The function returns a html element of type [Element].
  Element render(String temp, [TemplateState? state]);
}
