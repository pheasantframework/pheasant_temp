import 'package:html/dom.dart';
import 'package:raven_temp/builder/code/src/cc.dart';

void formatCustomComponents(Map<String, String> importMap, String template, Element RavenHtml) {
  String componentName = "";
  importMap.keys.forEach((element) {
    componentName = element;
    var regen = RegExp('<(?<component>$componentName)\\s*(?:/|></\\k<component>)?>');
    Iterable<Match> regexMatches = regen.allMatches(template);
    regexMatches.map((e) => e[0]).forEach((el) {
      if ((el ?? '').contains('/')) {
        serveSingleComponents(RavenHtml, componentName);
      }
    });
  });
}