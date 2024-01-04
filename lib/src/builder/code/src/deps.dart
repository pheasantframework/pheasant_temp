import 'package:html/dom.dart';
import 'package:markdown/markdown.dart' show markdownToHtml;

import '../../code/src/tempclass.dart';
import '../../../components/attributes/attr.dart';

/// This is the much rather recursive function used in rendering the element variable.
/// 
/// In this function, the following, in order are performed:
/// 
/// 1. The attributes of the element are rendered and functionality added to the code body - [basicAttributes].
/// 
/// 2. The special pheasant attributes of the element are rendered and functionality added to the code body - [pheasantAttributes].
/// 
/// 3. The children of the element - both text nodes and elements - are rendered in recursive order (from 1) and added to the parent - [attachChildren].
/// 
/// In this function, [beginningFunc] is an alias for the code body (to be modified and returned under the same name). 
/// [pheasantHtml] is the parsed Html we are using to generate functionality to modify `beginningFunc`.
/// 
/// [attrmap] is an iterable of strings containing pheasant attributes.
/// 
/// [elementName] is the element name that is being rendered, used for code generation. It defaults to the main element name - `element`.
/// 
/// [nonDartImports] refer to imported pheasant components that are used in children rendering.
String renderElement(String beginningFunc, Element? pheasantHtml, Iterable<String> attrmap, {String elementName = 'element', Map<String, String> nonDartImports = const {}}) {
  int closebracket = 0;
  // Render attributes
  beginningFunc = basicAttributes(pheasantHtml, beginningFunc, elementName: elementName);

  final tempobj = pheasantAttributes(pheasantHtml, attrmap, beginningFunc, closebracket,  elementName: elementName);
  beginningFunc = tempobj.value;
  closebracket = tempobj.number;
  // Add children
  beginningFunc = attachChildren(pheasantHtml, beginningFunc,  elementName: elementName, nonDartImports: nonDartImports);
  
  // Add remaining closed braces to close up scope and render valid dart code
  beginningFunc += ('}\n' * closebracket);
  return beginningFunc;
}

/// This function is used to render and attach children - both text nodes and elements - to their parents and reflect the functionality for the code.
/// 
/// This function modifies [beginningFunc] through the help of [pheasantHtml] and therefore, returns the modified version of it.
/// 
/// In this function, text nodes are attached via [Element.append] to the element, and changes are reflected as shown. Any remaining interpolation (`{{}}`) is replaced by the desired variable or value.
/// 
/// Element nodes are first of all rendered by calling [childFun] to render the element and its children in the desired way. 
/// By default, [childFun] is equal to the standard rendering function [renderElement]
/// 
/// For the case of custom components, the [nonDartImports] map contains the key-value pair representing the name and import path of the custom components.
/// These custom components are simply rendered by calling their desired `render` function, and then attaching the returned [Element] to the parent.
String attachChildren(Element? pheasantHtml, String beginningFunc, {String Function(String, Element?, Iterable<String>, {String elementName}) childFun = renderElement, String elementName = 'element', Map<String, String> nonDartImports = const {}}) {
  // Ensure that children exist before running code
  if (pheasantHtml!.nodes.isNotEmpty) {
    // Iterate through all `nodes` (not just elements)
    pheasantHtml.nodes.forEach((element) {
      // Ignore part rendering for cases of `p-text`
      if (element.parent!.attributes.containsKey('p-text') && pheasantHtml.nodes.last == element) {
        
      } else if (element.nodeType == 3) {
        // Render text nodes
        if ((element.text ?? '').contains(RegExp(r'\{\{([^\}]+)\}\}'))) {
          // Remove interpolation and add desired value
          final regex = RegExp(r'\{\{([^\}]+)\}\}');
          Match match = regex.allMatches(element.text ?? '').first;
          element.text = '\${${match[1]}}';
        }
        beginningFunc += '$elementName.append(_i2.Text("""${element.text}"""));';
      } else {
        // Render elements
        String childname = "newChild${pheasantHtml.children.indexOf(element as Element)}${'_${pheasantHtml.hashCode}'}";
        // Check for custom components 
        if (element.localName == 'md') {
          // Markdown components can be easily rendered with just two lines, thanks to the markdown package.
          // Do take note that the data must be flat down (no scope indentation) - for now
          beginningFunc += "_i2.Element $childname = _i2.Element.div()..innerHtml = '''${markdownToHtml(element.innerHtml)}''';";
          beginningFunc += '$elementName.children.add($childname);';
        } else {
          if (nonDartImports.keys.contains(element.localName)) {
            beginningFunc += '''
final ${childname}component = ${element.localName}.${'${element.localName!}Component()'};
_i2.Element $childname = ${childname}component.render(${childname}component.template!);
''';
          } else {
            beginningFunc += "_i2.Element $childname = _i2.Element.tag('${(element).localName}');";
          }
          String childstrFunc = "";
          childstrFunc = childFun(childstrFunc, element, PheasantAttribute.values.map((e) => e.name), elementName: childname);
          beginningFunc += childstrFunc;
          beginningFunc += '$elementName.children.add($childname);';
        }
      }
    });
  }
  return beginningFunc;
}

/// Function used for writing code to make and assert pheasant custom attributes in a component (bringing your Dart to your HTML)
/// 
/// This function asseses the [Element] named [pheasantHtml] and then iterates through the attributes in the element. 
/// 
/// In order to render custom attributes defined by the pheasant framework, such as `p-for`, `p-if` and others, we make use of the [attrmap] in order to find the attribute definition and add the appropriate line of code.
/// 
/// The code returns a [TempPheasantRenderClass], which is a temporary class containing the new beginningFunc String `value` and the new closebracket integer `number`.
/// 
/// `closebracket` here represents the number of close braces to add for scoped code (due to cases such as `if`, `for` and `while` loops).
TempPheasantRenderClass pheasantAttributes(Element? pheasantHtml, Iterable<String> attrmap, String beginningFunc, int closebracket, {String elementName = 'element'}) {
  for (var attr in pheasantHtml!.attributes.entries) {
    if (attrmap.contains(attr.key)) {
      PheasantAttribute defAttr = PheasantAttribute.values[attrmap.toList().indexOf(attr.key as String)];
      String value = attr.value;
      String statement = '';
      switch (defAttr) {
        case PheasantAttribute.r_if:
          statement = 'if ($value) {';
          closebracket++;
          break;
        case PheasantAttribute.r_while:
          statement = 'while ($value) {';
          closebracket++;
          break;
        case PheasantAttribute.r_for:
          statement = 'for ($value) {';
          closebracket++;
          break;
        case PheasantAttribute.r_html:
          pheasantHtml.innerHtml += value; 
          statement = '$elementName.innerHtml = $elementName.innerHtml == null ? "$value" : $elementName.innerHtml! + "$value";';
          break;
        case PheasantAttribute.r_text:
          pheasantHtml.nodes.add(Text(value));
          statement = '$elementName.append(_i2.Text("\${$value}"));';
          break;
        case PheasantAttribute.r_else:
          if ((pheasantHtml.previousElementSibling?.attributes
          .entries.map((e) => e.key) ?? []).contains('p-if')) {
            statement = 'else {';
            closebracket++;
          }
          break;
        case PheasantAttribute.r_elseif:
          if ((pheasantHtml.previousElementSibling?.attributes
          .entries.map((e) => e.key) ?? []).contains('p-if')) {
            statement = 'else if ($value) {';
            closebracket++;
          }
          break;
        default:
      }
      beginningFunc += '$statement\n';
      continue;
    }
  }
  return /*beginningFunc*/ TempPheasantRenderClass(number: closebracket, value: beginningFunc);
}


/// Function used for writing code to make and assert normal attributes in a component.
/// 
/// This function asseses the [Element] named [pheasantHtml] and then iterates through the attributes in the element. 
/// It then adds the appropriate line of code to render it.
String basicAttributes(Element? pheasantHtml, String beginningFunc, {String elementName = 'element'}) {
  for (var attr in pheasantHtml!.attributes.entries) {
    if (attr.key == 'class' || attr.key == 'className') {
      beginningFunc += '$elementName.classes.add(${attr.value});';
    } else if (attr.key == 'href' || attr.key == 'id') {
      beginningFunc += '$elementName.setAttribute("${attr.key as String}", "${attr.value}");';
    } else if (!PheasantAttribute.values.map((e) => e.name).contains(attr.key)){
      beginningFunc += '$elementName.setAttribute("${attr.key as String}", ${attr.value});';
    }
  }
  return beginningFunc;
}