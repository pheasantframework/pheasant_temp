import 'dart:html';

import 'package:pheasant_temp/src/base.dart';
import 'package:pheasant_temp/src/state/state.dart';

/// Base component for creating a custom component
abstract class PheasantComponent extends PheasantTemplate {
  PheasantComponent({required super.template});

  @override
  void init() {}

  @override
  void del() {}

  Element renderComponent([TemplateState? state]);

  Map<String, AttrFunc> attributes = {};

  @override
  Element render(String temp, [TemplateState? state]) {
    return renderComponent(state);
  }
  
}

typedef AttrFunc = void Function(String value, Element target);