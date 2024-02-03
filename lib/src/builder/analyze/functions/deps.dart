import 'package:analyzer/dart/ast/ast.dart' show FunctionDeclaration, VariableDeclaration;
import 'package:code_builder/code_builder.dart' show Code, FieldModifier;


FieldModifier modifier(VariableDeclaration vd) {
  String mod = vd.beginToken.isModifier ? vd.beginToken.toString() : 'dynamic';
  if (mod == 'const') {
    return FieldModifier.constant;
  } else if (mod == 'final') {
    return FieldModifier.final$;
  }
  else {
    return FieldModifier.var$;
  }
}


Code funBody(FunctionDeclaration fd) {
  String body = fd.functionExpression.body.toSource();
  return Code(body.replaceRange(body.length - 1, null, '').replaceFirst('{', ''));
}