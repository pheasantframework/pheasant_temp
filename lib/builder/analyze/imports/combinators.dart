import 'package:analyzer/dart/ast/ast.dart';

List<String> getShowCombinators(ImportDirective directive) {
  List<String> items = <String>[];
  for (final item in directive.combinators) {
    if (item.keyword.toString() == 'show') {
      String stringList = item.toSource().replaceFirst('show ', '');
      items.addAll(stringList.split(', '));
    }
  }
  return items;
}

List<String> getHideCombinators(ImportDirective directive) {
  List<String> items = <String>[];
  for (final item in directive.combinators) {
    if (item.keyword.toString() == 'hide') {
      String stringList = item.toSource().replaceFirst('hide ', '');
      items.addAll(stringList.split(', '));
    }
  }
  return items;
}