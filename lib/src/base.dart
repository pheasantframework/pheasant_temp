import 'dart:html';

abstract class PheasantTemplate {
  String? template;

  PheasantTemplate({required this.template});

  Element render(String temp);
}