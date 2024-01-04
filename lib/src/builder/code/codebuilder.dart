import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import '../analyze/analyze.dart';

import '../code/funbuilder.dart';

/// Function to render class function code during build
/// 
/// This is the main function behind rendering Pheasant Code to Dart Code.
/// In this function, we basically convert the data from the `script` part and the `template` part of a pheasant component into a Component class.
/// 
/// This class, which has a name of [componentName] which defaults to `'AppComponent'`, extends the [RavenTemplate] class, and therefore overrides two main functionality.
/// 
/// The key functionality that this function generates is the [render] function, which is generated via the [renderRenderFunc], in order to return the desired html component to be rendered in the DOM.
/// 
/// This function returns a string, which is the composition for the generated dart file with the extension [buildExtension] which defaults to `'.phs.dart'`.
/// 
/// The function does the following, in the given order:
/// 1. Adds the required directives needed for the code: It starts off with the directives needed for every instance of a component, then adds imports included in the pheasant file.
/// 
/// 2. Generates the class with name [componentName] to extend `RavenTemplate`.
/// 
/// 3. Adds all variable and function definitions in the class, from the `script` part of the pheasant file.
/// 
/// 4. Creates the constructor, to call super, and overrides the `template` variable from the parent class.
/// 
/// 5. Generates the definition for, and overrides, the `render` function in the parent class, to return an element of type `Element`
String renderFunc({required String script, required String template, String componentName = 'AppComponent', String buildExtension = '.phs.dart'}) {
  // Get emitter and formatter 
  final formatter = DartFormatter(); 
  final emitter = DartEmitter.scoped();

  // Create library to generate dart code
  var item = LibraryBuilder();

  // Add necessary imports
  item.directives.add(Directive.import('package:html/parser.dart', as: '_i0')); // Required import
  item.directives.addAll(
    PheasantScript(
        varDef: extractVariable(script), 
        funDef: extractFunction(script),
        impDef: extractImports(script)
      ).imports.where((element) => fileExtension(element.url) == 'dart')
  ); // Dart imports
  item.directives.addAll(
    PheasantScript(
        varDef: extractVariable(script), 
        funDef: extractFunction(script),
        impDef: extractImports(script)
      ).dartedNonDartImports(newExtension: buildExtension)
  ); // Non-dart imports - importing dartified (dart-generated) files

  // Create class for template
  item.body.add(
    Class((c) => c
    ..name = componentName
    ..extend = refer('PheasantTemplate', 'package:pheasant_temp/pheasant_build.dart')
    // Add methods generated from `script` file
    ..methods.addAll(
      PheasantScript(
        varDef: extractVariable(script), 
        funDef: extractFunction(script)
      ).methods
    )
    // Add fields generated from `script` file
    ..fields.addAll(
      PheasantScript(
        varDef: extractVariable(script), 
        funDef: extractFunction(script)
      ).fields
    )
    // Override `template` variable
    ..fields.add(
      Field((f) => f
      ..name = 'template'
      ..annotations.add(CodeExpression(Code('override')))
      ..type = refer('String?')
      ..assignment = Code("'''$template'''")
      )
    )

    // Create Constructor to call `super`
    ..constructors.add(
      Constructor((con) => con
      ..optionalParameters.add(
        Parameter((p) => p
        ..toSuper = true
        ..name = 'template'
        ..named = true
        )
      )
      )
    )
    // Override and generate definition for `render` function
    ..methods.add(
      Method((m) => m
      ..annotations.add(CodeExpression(Code('override')))
      ..name = 'render'
      ..requiredParameters.add(
        Parameter((p) => p
        ..name = 'temp'
        ..type = refer('String')
        )
      )
      ..returns = refer('Element', 'dart:html')
      ..docs.addAll(['  // Override function for creating an element'])
      ..body = renderRenderFunc(
        template: template, 
        pheasantScript: PheasantScript(
          varDef: extractVariable(script), 
          funDef: extractFunction(script),
          impDef: extractImports(script)
        )
        )
      )
    )
    )
  );

  // Return complete class instance as formatted string
  return formatter.format("${item.build().accept(emitter)}");
}


