import 'package:code_builder/code_builder.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart' show markdownToHtml;

import 'custom_components.dart';
import '../analyze/analyze.dart';
import 'src/deps.dart';
import '../../components/attributes/attr.dart';

/// Function used to render the `render` function defined in the base class `RavenTemplate`.
/// 
/// This function generates the [render] function found in the pheasant component, which is generated via the [renderRenderFunc], in order to return the desired html component to be rendered in the DOM.
/// 
/// The function makes use of the [pheasantScript] variable, of type [PheasantScript], to be able to use variable, function and custom import definitions.
/// 
/// The [template] variable is also needed to generate the code.
/// 
/// The code is generated line-by-line, statement-by-statement, and then the final string is returned as a [Code] block.
Code renderRenderFunc({PheasantScript pheasantScript = const PheasantScript(), required String template}) {
  String beginningFunc = '''

''';
  // Perform String concatenation switch
  // This renders interpolation
  final regex = RegExp(r'\{\{([^\}]+)\}\}');
  Iterable<Match> matches = regex.allMatches(template);
  if (matches.isNotEmpty) {
    int index = 0;
    for (var match in matches) {
      String statement = index == 0
      ? 'String body = temp.replaceAll("${match[0]}", "\${${match[1]}}");\n'
      : 'body = temp.replaceAll("${match[0]}", "\${${match[1]}}");\n';
      beginningFunc += statement;
      index++;
    }
  } else {
    String statement = 'String body = temp;';
    beginningFunc += statement;
  }
  // Create the desired element
  final PheasantHtml = HtmlParser(template, lowercaseElementName: false).parse().body!.children.first;
  // Create the element via parsing
  beginningFunc += '''
final PheasantHtml = _i0.parse(body).body!.children.first;
''';
  // Render the data
  if (PheasantHtml.localName == 'md') {
    String switchedHtml = markdownToHtml(PheasantHtml.innerHtml);
    beginningFunc += "_i2.Element element = _i2.Element.div()..innerHtml = '''$switchedHtml''';";
  } else {
    beginningFunc += "_i2.Element element = _i2.Element.tag(PheasantHtml.localName!);";
    // Configure the custom components
    Map<String, String> importMap = { for (var element in pheasantScript.nonDartImports) (element).as! : (element).url };
    formatCustomComponents(importMap, template, PheasantHtml);
    // Work on pheasant attributes
    Iterable<String> attrmap = PheasantAttribute.values.map((e) => e.name);
    beginningFunc = renderElement(beginningFunc, PheasantHtml, attrmap, nonDartImports: importMap);
  }
  // Final Line
  beginningFunc += 'return element;';
  
  return Code(beginningFunc);
}
