import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import '../analyze/imports/extension.dart';

import '../code/funbuilder.dart';

import '../analyze/analyzer.dart';

/// Model Function to render class function code during build
String renderFunc({required String script, required String template, String buildExtension = '.raven.dart'}) {
  final formatter = DartFormatter(); 
  final emitter = DartEmitter.scoped();
  var item = LibraryBuilder();
  // Add necessary imports
  item.directives.add(Directive.import('package:html/parser.dart', as: '_i0'));
  item.directives.addAll(
    RavenScript(
        varDef: extractVariable(script), 
        funDef: extractFunction(script),
        impDef: extractImports(script)
      ).imports.where((element) => fileExtension(element.url) == 'dart')
  );
  item.directives.addAll(
    RavenScript(
        varDef: extractVariable(script), 
        funDef: extractFunction(script),
        impDef: extractImports(script)
      ).dartedNonDartImports(newExtension: buildExtension)
  );
  // Create class for template
  item.body.add(
    Class((c) => c
    ..name = 'AppComponent'
    ..extend = refer('RavenTemplate', 'package:raven/components.dart')
    ..methods.addAll(
      RavenScript(
        varDef: extractVariable(script), 
        funDef: extractFunction(script)
      ).methods
    )
    ..fields.addAll(
      RavenScript(
        varDef: extractVariable(script), 
        funDef: extractFunction(script)
      ).fields
    )
    ..fields.add(
      Field((f) => f
      ..name = 'template'
      ..annotations.add(CodeExpression(Code('override')))
      ..type = refer('String')
      ..assignment = Code("'''$template'''")
      )
    )
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
        ravenScript: RavenScript(
          varDef: extractVariable(script), 
          funDef: extractFunction(script),
          impDef: extractImports(script)
        ))
      )
    )
    )
  );

  return formatter.format("${item.build().accept(emitter)}");
}


