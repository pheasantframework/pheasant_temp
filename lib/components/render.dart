import 'elements/types.dart';

class PheasantComponent {
  ComponentType componentType;
  String script;
  String component;

  PheasantComponent({required this.script, required this.component, required this.componentType});

  @override
  String toString() {
    return "PheasantComponent of Component Type: ${componentType.name}";
  }
}


