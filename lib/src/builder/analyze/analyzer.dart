// Copyright (c) 2024 The Pheasant Group. All Rights Reserved.
// Please see the AUTHORS files for more information.
// Intellectual property of third-party.
// 
// This file, as well as use of the code in it, is governed by an MIT License
// that can be found in the LICENSE file.
// You may not use this file except in compliance with the License.
  
import 'package:analyzer/dart/analysis/utilities.dart' show parseString;
import 'package:analyzer/dart/ast/ast.dart' hide Directive;

import 'package:code_builder/code_builder.dart'
    show
        Code,
        CodeExpression,
        Directive,
        DirectiveBuilder,
        Field,
        FieldBuilder,
        Method,
        MethodType,
        Parameter,
        refer;

import 'metadata/props.dart';

import '../../exceptions/exceptions.dart';

import '../analyze/imports/combinators.dart';
import '../analyze/imports/extension.dart';

import 'functions/deps.dart';
import 'functions/functions.dart';

import 'variables/variable_info.dart';
import 'variables/variable_extractor_visitor.dart';

/// The `PheasantScript` class, a class used to encapsulate code defined in the `<script>` part of a pheasant file.
/// Code defined in the script consist of none or at least one of the following:
///
/// 1. Variable Definitions: Definition of variables used for either code manipulation in the script part, or for interpolation and manipulation in the template part.
/// In future versions, variables may also be used in sass-enabled style parts (PSM).
/// ```dart
/// int myNum = 9
/// ```
///
/// 2. Function Definitions: Perform similar purposes with variables, but they are functions (of course), and they can also be used in situations such as onclick events, input events and others.
/// In future versions, functions may also be used in sass-enabled style parts (PSM).
/// ```dart
/// void addNum() {
///   myNum++;
/// }
/// ```
///
/// 3. Import Directives: These are used to import at least one of the following:
/// dart files used in the code,
/// pheasant components used in the **template** section of the file,
/// (future version) dart-pheasant components used in the **template** section of the file.
/// ```dart
/// import 'file.dart';
/// ```
///
/// The [PheasantScript] class contains three variables used to store these declarations respectively, which are lists of ASTs - [VariableDefinition], [FunctionDeclaration] and [ImportDirective].
/// The difference between [VariableDefinition] and [VariableDeclaration] is the fact that [VariableDefinition] is an encapsulated extension of [VariableDeclaration] that includes the variable's type.
///
/// The functions [extractVariable], [extractFunction] and [extractImport] are used to get these definitions and store them in the class.
///
/// In order to translate these to desired code blocks, we have getters [fields], [methods] and [imports].
class PheasantScript {
  final List<VariableDefinition> varDef;
  final List<FunctionDeclaration> funDef;
  final List<ImportDirective> impDef;

  /// Constructor to instantiate a [PheasantScript] object.
  ///
  /// None of the parameters are required, so you can therefore parse only the ones required for your use case (getter).
  const PheasantScript(
      {this.varDef = const [], this.funDef = const [], this.impDef = const []});

  /// Getter to get the fields for the desired pheasant app component.
  ///
  /// This method translates the ast definition [varDef] stored in the class to the `code_builder` type [Field] to use in the `renderFunc` function.
  List<Field> get fields {
    return List.generate(varDef.length, (index) {
      final variable = varDef[index];
      var field = FieldBuilder()
        ..name = "${variable.declaration.name}"
        ..type = refer(variable.dataType)
        ..late = variable.declaration.isLate
        ..modifier = modifier(variable.declaration)
        ..annotations
            .addAll(List.generate(variable.annotations.length, (index) {
          return CodeExpression(Code(
              variable.annotations[index].toSource().replaceAll('@', '_i1.')));
        }));
      if (variable.declaration.initializer == null &&
          !variable.dataType.contains('?')) {
      } else {
        field.assignment = Code(
            '${variable.declaration.initializer == null && variable.dataType.contains('?') ? variable.declaration.initializer : (variable.declaration.initializer ?? "")}');
      }
      return field.build();
    });
  }

  /// Code to get the "prop fields" in a class
  /// The prop fields are fields uninitialised in a class, and therefore will be passed as parameters into the constructor.
  ///
  /// These fields are encapsulated in a [PropField] class, which gives relevant information as to how these fields are presented in the constructor.
  ///
  /// These feilds are usually denoted with an `@prop` or `@Prop()` annotation on them.
  /// By default all uninitialised variables, except those bearing an `@noprop` annotation are passed as props.
  ///
  /// The `@Prop()` annotation helps define the kind of prop field it is (whether it has a default value or not), and this information is stored in the [PropField] class.
  List<PropField> get props {
    List<PropField> initList = List<PropField>.generate(
        varDef.where((element) {
          return element.annotations
              .where((el) =>
                  el.name.toSource() == 'prop' || el.name.toSource() == 'Prop')
              .isNotEmpty;
        }).length, (index) {
      final variable = varDef
          .where((element) => element.annotations
              .where((el) =>
                  el.name.toSource() == 'prop' || el.name.toSource() == 'Prop')
              .isNotEmpty)
          .toList()[index];
      var field = FieldBuilder()
        ..name = "${variable.declaration.name}"
        ..type = refer(variable.dataType)
        ..late = variable.declaration.isLate
        ..modifier = modifier(variable.declaration);
      if (variable.declaration.initializer == null &&
          !variable.dataType.contains('?')) {
      } else {
        field.assignment = Code(
            '${variable.declaration.initializer == null && variable.dataType.contains('?') ? variable.declaration.initializer : (variable.declaration.initializer ?? "")}');
      }
      Iterable<Annotation> propAnnotations = variable.annotations.where(
          (element) =>
              element.name.toSource() == 'prop' ||
              element.name.toSource() == 'Prop');
      return PropField(
          fieldDef: field.build(),
          annotationInfo: PropAnnotationInfo(data: {
            'defaultTo': propAnnotations.first.name.toSource() == 'prop' ||
                    propAnnotations.first.arguments!.arguments
                        .where((element) =>
                            element.beginToken.toString() == 'defaultTo')
                        .isEmpty
                ? ''
                : propAnnotations.first.arguments?.arguments
                    .singleWhere((element) =>
                        element.beginToken.toString() == 'defaultTo')
                    .childEntities
                    .last
                    .toString(),
            'optional': propAnnotations.first.name.toSource() == 'prop' ||
                    propAnnotations.first.arguments!.arguments
                        .where((element) =>
                            element.beginToken.toString() == 'optional')
                        .isEmpty
                ? false
                : bool.parse(propAnnotations.first.arguments?.arguments
                        .singleWhere((element) =>
                            element.beginToken.toString() == 'optional')
                        .childEntities
                        .last
                        .toString() ??
                    "false"),
          }));
    });

    List<PropField> indirectList = List<PropField>.generate(
        fields.where((element) {
          return element.annotations.where((p0) {
                return p0.toString().contains('noprop') &&
                    !p0.toString().contains('prop') &&
                    !p0.toString().contains('Prop');
              }).isEmpty &&
              element.assignment == null &&
              !((element.type?.symbol ?? 'var').contains('?') ||
                  ['var', 'final', 'const', 'dynamic']
                      .contains(element.type?.symbol ?? 'var')) &&
              !initList.map((e) => e.fieldDef.name).contains(element.name);
        }).length, (index) {
      return PropField(
          fieldDef: fields.where((element) {
            return element.annotations.where((p0) {
                  return p0.toString().contains('noprop') &&
                      !(p0.toString() == 'prop') &&
                      !(p0.toString() == 'Prop');
                }).isEmpty &&
                element.assignment == null &&
                !((element.type?.symbol ?? 'var').contains('?') ||
                    ['var', 'final', 'const', 'dynamic']
                        .contains(element.type?.symbol ?? 'var')) &&
                !initList.map((e) => e.fieldDef.name).contains(element.name);
          }).toList()[index],
          annotationInfo:
              PropAnnotationInfo(data: {'defaultTo': '', 'optional': false}));
    });
    return (initList + indirectList);
  }

  /// Getter to get the methods for the desired pheasant app component.
  ///
  /// This method translates the ast definition [funDef] stored in the class to the `code_builder` type [Method] to use in the `renderFunc` function.
  List<Method> get methods {
    return List.generate(funDef.length, (index) {
      final function = funDef[index];
      return Method((m) => m
        ..name = function.name.toString()
        ..returns = refer(function.returnType?.toSource() ?? 'dynamic')
        ..requiredParameters.addAll(List.generate(
            function.functionExpression.parameters?.parameters
                    .where((element) => !element.isOptional)
                    .length ??
                0, (index) {
          final param =
              function.functionExpression.parameters!.parameters[index];
          return Parameter((p) => p
            ..name = param.name.toString()
            ..covariant = param.covariantKeyword == null ? false : true
            ..named = param.isNamed
            ..required = param.requiredKeyword == null ? false : true
            ..type = refer('${param.name?.previous}'));
        }))
        ..optionalParameters.addAll(List.generate(
            function.functionExpression.parameters?.parameters
                    .where((element) => element.isOptional)
                    .length ??
                0, (index) {
          final param =
              function.functionExpression.parameters!.parameters[index];
          return Parameter((p) => p
            ..name = param.name.toString()
            ..covariant = param.covariantKeyword == null ? false : true
            ..named = param.isNamed
            ..defaultTo = param.childEntities.length > 2
                ? Code('${param.childEntities.last}')
                : null
            ..type = refer('${param.name?.previous}'));
        }))
        ..annotations.addAll(List.generate(function.metadata.length, (index) {
          return CodeExpression(!function.metadata[index]
                  .toString()
                  .contains('JS')
              ? Code(function.metadata[index].toString().replaceAll('@', ''))
              : Code(
                  function.metadata[index].toString().replaceAll('@', '_i0.')));
        }))
        ..external = function.externalKeyword == null ? false : true
        ..type = function.isGetter
            ? MethodType.getter
            : (function.isSetter ? MethodType.setter : null)
        ..body = funBody(function));
    });
  }

  List<Method> get jsMethods => methods.where((element) {
        return element.annotations.where((p0) {
          return p0.code.toString().contains('JS');
        }).isNotEmpty;
      }).toList();

  // List<Method> get internaljsMethods;

  List<Method> get nonjsMethods => methods.where((element) {
        return !element.annotations.where((p0) {
          return p0.code.toString().contains('JS');
        }).isNotEmpty;
      }).toList();

  /// Getter to get the imports for the desired pheasant app component.
  ///
  /// This method translates the ast definition [impDef] stored in the class to the `code_builder` type [Directive] to use in the `renderFunc` function.
  List<Directive> get imports {
    return List.generate(impDef.length, (index) {
      final import = impDef[index];
      return Directive.import(import.uri.toSource().replaceAll('\'', ''),
          as: import.prefix?.toSource(),
          show: getShowCombinators(import),
          hide: getHideCombinators(import));
    });
  }

  /// Getter to get the pheasant component imports
  ///
  /// Since pheasant component files are not dart files by nature, the generated file instead should be imported.
  /// Therefore this method gets the formatted imports for the dart files generated for the pheasant components.
  List<Directive> get nonDartImports {
    return imports
        .where((element) => fileExtension(element.url) != 'dart')
        .toList();
  }

  /// Function to format the extensions created by [nonDartImports] for use in the `renderFunc` function.
  List<Directive> dartedNonDartImports({String newExtension = '.phs.dart'}) {
    List<Directive> imports = nonDartImports;
    List<Directive> output = [];
    for (var element in imports) {
      DirectiveBuilder rebuild = element.toBuilder();
      rebuild.url = rebuild.url?.replaceAll('.phs', newExtension);
      output.add(rebuild.build());
    }
    return output;
  }
}

/// Function used to extract variable definitions from the [script] of a pheasant component file.
///
/// Throws a [PheasantTemplateException] in the event of any errors during parsing.
List<VariableDefinition> extractVariable(String script) {
  List<VariableDefinition> outputList = [];
  final result = parseString(content: script);
  if (result.errors.isNotEmpty) {
    throw PheasantTemplateException(
      '''
Error Reading Script Component: Variable Error: ${result.errors.map((e) => e.problemMessage)} 
Fix: ${result.errors.map((e) => e.correctionMessage)} 
''',
      exitCode: result.errors.map((e) => e.errorCode.numParameters).first,
    );
  }
  CompilationUnit newUnit = parseString(content: script).unit;
  VariableExtractorVisitor visitor = VariableExtractorVisitor();

  for (var element in newUnit.declarations) {
    element.accept(visitor);
    outputList.addAll(
        visitor.variableList.map((e) => e..annotations = element.metadata));
    visitor = VariableExtractorVisitor();
  }
  return outputList;
}

/// Function used to extract function definitions from the [script] of a pheasant component file.
///
/// Throws a [PheasantTemplateException] in the event of any errors during parsing.
List<FunctionDeclaration> extractFunction(String script) {
  final result = parseString(content: script);
  if (result.errors.isNotEmpty) {
    throw PheasantTemplateException(
      '''
Error Reading Script Component: Variable Error: ${result.errors.map((e) => e.problemMessage)} 
Fix: ${result.errors.map((e) => e.correctionMessage)} 
''',
      exitCode: result.errors.map((e) => e.errorCode.numParameters).first,
    );
  }
  return extractFunctions(result.unit);
}

/// Function used to extract import directives from the [script] of a pheasant component file.
///
/// Throws a [PheasantTemplateException] in the event of any errors during parsing.
List<ImportDirective> extractImports(String script) {
  final result = parseString(content: script);
  if (result.errors.isNotEmpty) {
    throw PheasantTemplateException(
      '''
Error Reading Script Component: Variable Error: ${result.errors.map((e) => e.problemMessage)} 
Fix: ${result.errors.map((e) => e.correctionMessage)} 
''',
      exitCode: result.errors.map((e) => e.errorCode.numParameters).first,
    );
  }
  CompilationUnit newUnit = parseString(content: script).unit;
  return newUnit.directives.whereType<ImportDirective>().toList();
}
