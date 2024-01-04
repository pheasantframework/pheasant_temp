import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart' hide Directive;

import 'package:code_builder/code_builder.dart';

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
  const PheasantScript({this.varDef = const [], this.funDef = const [], this.impDef = const []});

  /// Getter to get the fields for the desired pheasant app component.
  /// 
  /// This method translates the ast definition [varDef] stored in the class to the `code_builder` type [Field] to use in the `renderFunc` function.
  List<Field> get fields {
    return List.generate(varDef.length, (index) {
      final variable = varDef[index];
      return Field((f) => f
      ..name = "${variable.declaration.name}"
      ..type = refer(variable.dataType)
      ..late = variable.declaration.isLate
      ..modifier = modifier(variable.declaration)
      ..assignment = Code('${variable.declaration.initializer}')
      );
    });
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
      ..requiredParameters.addAll(
        List.generate(function.functionExpression.parameters?.parameters
        .where((element) => !element.isOptional).length ?? 0, (index) {
          final param = function.functionExpression.parameters!.parameters[index];
          return Parameter((p) => p
          ..name = param.name.toString()
          ..covariant = param.covariantKeyword == null ? false : true
          ..named = param.isNamed
          ..required = param.requiredKeyword == null ? false : true
          ..type = refer('${param.name?.previous}')
          );
        })
      )
      ..optionalParameters.addAll(
        List.generate(function.functionExpression.parameters?.parameters
        .where((element) => element.isOptional).length ?? 0, (index) {
          final param = function.functionExpression.parameters!.parameters[index];
          return Parameter((p) => p
          ..name = param.name.toString()
          ..covariant = param.covariantKeyword == null ? false : true
          ..named = param.isNamed
          ..defaultTo = param.childEntities.length > 2 ? Code('${param.childEntities.last}') : null
          ..type = refer('${param.name?.previous}')
          );
        })
      )
      ..annotations.addAll(List.generate(
        function.metadata.length, 
        (index) => CodeExpression(Code('${function.metadata[index]}'))
        ))
      ..external = function.externalKeyword == null ? false : true
      ..type = function.isGetter ? MethodType.getter : (function.isSetter ? MethodType.setter : null)
      ..body = funBody(function)
      );
    });
  }

  /// Getter to get the imports for the desired pheasant app component.
  /// 
  /// This method translates the ast definition [impDef] stored in the class to the `code_builder` type [Directive] to use in the `renderFunc` function.
  List<Directive> get imports {
    return List.generate(impDef.length, (index) {
      final import = impDef[index];
      return Directive.import(
        import.uri.toSource().replaceAll('\'', ''),
        as: import.prefix?.toSource(),
        show: getShowCombinators(import),
        hide: getHideCombinators(import)
      )
      ;
    });
  }

  /// Getter to get the pheasant component imports
  /// 
  /// Since pheasant component files are not dart files by nature, the generated file instead should be imported. 
  /// Therefore this method gets the formatted imports for the dart files generated for the pheasant components.
  List<Directive> get nonDartImports {
    return imports.where((element) => fileExtension(element.url) != 'dart').toList();
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
List<VariableDefinition> extractVariable(String script) {
  List<VariableDefinition> outputList = [];
  CompilationUnit newUnit = parseString(content: script).unit;
  VariableExtractorVisitor visitor = VariableExtractorVisitor();

  newUnit.declarations.forEach((element) {
    element.accept(visitor);
    outputList.addAll(visitor.variableList);
    visitor = VariableExtractorVisitor();
  });
  return outputList;
}

/// Function used to extract function definitions from the [script] of a pheasant component file.
List<FunctionDeclaration> extractFunction(String script) {
  final parseResult = parseString(content: script);
  return extractFunctions(parseResult.unit);
}

/// Function used to extract import directives from the [script] of a pheasant component file.
List<ImportDirective> extractImports(String script) {
  CompilationUnit newUnit = parseString(content: script).unit;
  return newUnit.directives.whereType<ImportDirective>().toList();
}