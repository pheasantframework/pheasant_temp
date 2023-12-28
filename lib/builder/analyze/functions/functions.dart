import 'package:analyzer/dart/ast/ast.dart';

List<FunctionDeclaration> extractFunctions(CompilationUnit unit) {
  final functions = <FunctionDeclaration>[];

  for (var declaration in unit.declarations) {
    if (declaration is FunctionDeclaration) {
      functions.add(declaration);
    }
  }

  return functions;
}
