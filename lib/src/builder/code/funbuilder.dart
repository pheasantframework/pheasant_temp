import 'package:code_builder/code_builder.dart' show Code;
import 'package:html/parser.dart' show HtmlParser;
import 'package:markdown/markdown.dart' show markdownToHtml;
import 'package:pheasant_assets/pheasant_assets.dart' show PheasantStyle, scopeComponents;

import '../../exceptions/exceptions.dart';
import 'components/custom_components.dart';
import '../analyze/analyze.dart' show PheasantScript;
import 'src/deps.dart' show renderElement, styleElement;
import '../../components/attributes/attr.dart' show PheasantAttribute;

/// Function used to render the `render` function defined in the base class `RavenTemplate`.
/// 
/// This function generates the [render] function found in the pheasant component, which is generated via the [renderRenderFunc], in order to return the desired html component to be rendered in the DOM.
/// 
/// The function makes use of the [pheasantScript] variable, of type [PheasantScript], to be able to use variable, function and custom import definitions.
/// 
/// The [template] variable is also needed to generate the code.
/// 
/// The code is generated line-by-line, statement-by-statement, and then the final string is returned as a [Code] block.
Code renderRenderFunc({
  PheasantScript pheasantScript = const PheasantScript(), 
  required String template, 
  PheasantStyle pheasantStyle = const PheasantStyle(),
  final String appDirPath = 'lib',
  bool sass = false
}) {
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
  final pheasant = HtmlParser(template, lowercaseElementName: false);
  final pheasantHtml = pheasant.parse().children.first;
  if (pheasant.errors.isNotEmpty && pheasant.errors.map((e) => e.message)
      .where((element) {
        return (!element.contains('solidus not allowed on element') && !element.contains('Expected DOCTYPE'));
      }).isNotEmpty) {
    print('''Issues Parsing Template Data: ${
      pheasant.errors.map((e) => e.message)
      .where((element) {
        return (!element.contains('solidus not allowed on element') && !element.contains('Expected DOCTYPE'));
      })
    }''');
  }
  // Create the element via parsing
  beginningFunc += '''
final PheasantHtml = _i1.parse(body).body!.children.first;
''';
  // Render the data
  if (pheasantHtml.localName == 'md') {
    String switchedHtml = "";
    try {
      switchedHtml = markdownToHtml(pheasantHtml.innerHtml);
    } catch (e, s) {
      throw PheasantTemplateException('Error while parsing markdown: $e \nStack Trace: $s');
    }
    beginningFunc += "_i2.Element element = _i2.Element.div()..innerHtml = '''$switchedHtml''';";
    Iterable<String> attrmap = PheasantAttribute.values.map((e) => e.name);
    beginningFunc = renderElement(
      beginningFunc, 
      pheasantHtml, 
      attrmap, 
      pheasantStyleScoped: scopeComponents(pheasantStyle, appPath: appDirPath)
    );
    beginningFunc = styleElement(beginningFunc, scopeComponents(pheasantStyle, appPath: appDirPath), 'element');
  } else {

    beginningFunc += "_i2.Element element = _i2.Element.tag(PheasantHtml.localName!);";
    // Configure the custom components
    Map<String, String> importMap = { for (var element in pheasantScript.nonDartImports) (element).as! : (element).url };
    formatCustomComponents(importMap, template, pheasantHtml);
    // Work on pheasant attributes
    Iterable<String> attrmap = PheasantAttribute.values.map((e) => e.name);
    var scopedStyle = scopeComponents(pheasantStyle, appPath: appDirPath, sassEnabled: sass);
    beginningFunc = styleElement(beginningFunc, scopedStyle, 'element');

    beginningFunc = renderElement(
      beginningFunc, 
      pheasantHtml, 
      attrmap, 
      nonDartImports: importMap, 
      pheasantStyleScoped: scopedStyle
    );
  }
  // Final Line
  beginningFunc += 'return element;';
  
  return Code(beginningFunc);
}
