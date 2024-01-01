import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart' hide Directive;

import 'package:code_builder/code_builder.dart';

import '../analyze/imports/combinators.dart';
import '../analyze/imports/extension.dart';

import 'functions/deps.dart';
import 'functions/functions.dart';

import 'variables/variable_info.dart';
import 'variables/variable_extractor_visitor.dart';

class PheasantScript {
  final List<VariableDefinition> varDef;
  final List<FunctionDeclaration> funDef;
  final List<ImportDirective> impDef;

  const PheasantScript({this.varDef = const [], this.funDef = const [], this.impDef = const []});

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

  List<Directive> get nonDartImports {
    return imports.where((element) => fileExtension(element.url) != 'dart').toList();
  } 

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

List<FunctionDeclaration> extractFunction(String script) {
  final parseResult = parseString(content: script);
  return extractFunctions(parseResult.unit);
}

List<ImportDirective> extractImports(String script) {
  CompilationUnit newUnit = parseString(content: script).unit;
  return newUnit.directives.whereType<ImportDirective>().toList();
}