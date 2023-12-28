import 'package:raven_temp/components/elements/types.dart';

class RavenComponent {
  ComponentType componentType;
  String script;
  String component;

  RavenComponent({required this.script, required this.component, required this.componentType});

  @override
  String toString() {
    return "RavenComponent of Component Type: ${componentType.name}";
  }
}


