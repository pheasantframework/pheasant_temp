import 'package:analyzer/dart/ast/ast.dart';

class VariableDefinition {
  VariableDeclaration declaration;
  String dataType;
  
  VariableDefinition({required this.declaration, required this.dataType});
}
