// Copyright (c) 2024 The Pheasant Group. All Rights Reserved.
// Please see the AUTHORS files for more information.
// Intellectual property of third-party.
// 
// This file, as well as use of the code in it, is governed by an MIT License
// that can be found in the LICENSE file.
// You may not use this file except in compliance with the License.
  
import 'package:analyzer/dart/ast/ast.dart'
    show FunctionDeclaration, VariableDeclaration;
import 'package:code_builder/code_builder.dart' show Code, FieldModifier;

FieldModifier modifier(VariableDeclaration vd) {
  String mod = vd.beginToken.isModifier ? vd.beginToken.toString() : 'dynamic';
  if (mod == 'const') {
    return FieldModifier.constant;
  } else if (mod == 'final') {
    return FieldModifier.final$;
  } else {
    return FieldModifier.var$;
  }
}

Code? funBody(FunctionDeclaration fd) {
  String body = fd.functionExpression.body.toSource();
  body = body.replaceRange(body.length - 1, null, '').replaceFirst('{', '');
  return body.isEmpty ? null : Code(body);
}
