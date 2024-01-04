import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'variable_info.dart';

/// Visitor used to get variables from a [CompilationUnit]
/// 
/// The difference between this and a normal Variable Visitor, is the use of the class [VariableDefinition] rather than [VariableDeclaration]
class VariableExtractorVisitor extends RecursiveAstVisitor<void> {
  List<VariableDefinition> variableList = [];

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    super.visitVariableDeclaration(node);

    variableList.add(VariableDefinition(declaration: node, dataType: (node.parent as VariableDeclarationList).type?.toSource() ?? 'dynamic'));
  }
}