import 'package:code_builder/code_builder.dart';
import 'package:html/parser.dart';

import 'custom_components.dart';
import '../analyze/analyzer.dart';
import 'src/deps.dart';
import '../../components/attributes/attr.dart';

Code renderRenderFunc({RavenScript ravenScript = const RavenScript(), required String template}) {
  String beginningFunc = '''

''';
  // Perform String concatenation switch
  final regex = RegExp(r'\{\{([^\}]+)\}\}');
  Iterable<Match> matches = regex.allMatches(template);
  for (var match in matches) {
    String statement = 'String template = temp.replaceAll("${match[0]}", ${match[1]});\n';
    beginningFunc += statement;
  }
  // Create the element 
  // final RavenNodes = parse(template).body?.nodes;
  final RavenHtml = parse(template).body!.children.first;
  beginningFunc += '''
final RavenHtml = _i0.parse(template).body!.children.first;
final RavenText = _i0.parse(template).body?.nodes;
_i2.Element _element = _i2.Element.tag(RavenHtml.localName);
''';
  // Configure the custom components
  Map<String, String> importMap = { for (var element in ravenScript.nonDartImports) (element).as! : (element).url };
  formatCustomComponents(importMap, template, RavenHtml);
  // Work on raven attributes
  Iterable<String> attrmap = RavenAttribute.values.map((e) => e.name);
  beginningFunc = renderElement(beginningFunc, RavenHtml, attrmap, nonDartImports: importMap);

  // Final Line
  beginningFunc += 'return _element;';
  
  return Code(beginningFunc);
}
