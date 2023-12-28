import 'dart:html';

abstract class RavenTemplate {
  String template;

  RavenTemplate({required this.template});

  Element render(String temp);
}