import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'variable_info.dart';

class VariableExtractorVisitor extends RecursiveAstVisitor<void> {
  List<VariableDefinition> variableList = [];

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    super.visitVariableDeclaration(node);

    variableList.add(VariableDefinition(declaration: node, dataType: '${(node.parent as VariableDeclarationList).type?.toSource() ?? 'dynamic'}'));
  }
}