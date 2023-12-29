import 'package:html/dom.dart';

import '../../code/src/tempclass.dart';
import '../../../components/attributes/attr.dart';

String renderElement(String beginningFunc, Element? pheasantHtml, Iterable<String> attrmap, {String elementName = '_element', Map<String, String> nonDartImports = const {}}) {
  int closebracket = 0;
  beginningFunc = basicAttributes(pheasantHtml, beginningFunc, elementName: elementName);
  final tempobj = pheasantAttributes(pheasantHtml, attrmap, beginningFunc, closebracket,  elementName: elementName);
  beginningFunc = tempobj.value;
  closebracket = tempobj.number;
  // Add children
  beginningFunc = attachChildren(pheasantHtml, beginningFunc,  elementName: elementName, nonDartImports: nonDartImports);
  
  beginningFunc += ('}\n' * closebracket);
  return beginningFunc;
}

String attachChildren(Element? pheasantHtml, String beginningFunc, {String Function(String, Element?, Iterable<String>, {String elementName}) childFun = renderElement, String elementName = '_element', Map<String, String> nonDartImports = const {}}) {
  if (pheasantHtml!.nodes.isNotEmpty) {
    pheasantHtml.nodes.forEach((element) {
      if (element.nodeType == 3) {
        beginningFunc += '$elementName.childNodes.add(_i2.Text("""${element.text}"""));';
      } else {
        String childname = "newChild${pheasantHtml.children.indexOf(element as Element)}";
        // Check for custom components 
        if (nonDartImports.keys.contains(element.localName)) {
          beginningFunc += '''
final ${childname}component = ${element.localName}.${'${element.localName!}Component()'};
_i2.Element $childname = ${childname}component.render(${childname}component.template);
''';
        } else {
          beginningFunc += '_i2.Element $childname = _i2.Element.tag(${(element).localName});';
        }
        String childstrFunc = "";
        childstrFunc = childFun(childstrFunc, element, PheasantAttribute.values.map((e) => e.name), elementName: childname);
        beginningFunc += childstrFunc;
        beginningFunc += '$elementName.children.add($childname);';
      }
    });
  }
  return beginningFunc;
}

TempPheasantRenderClass pheasantAttributes(Element? pheasantHtml, Iterable<String> attrmap, String beginningFunc, int closebracket, {String elementName = '_element'}) {
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
          statement = 'PheasantHtml.innerHtml += $value';
          break;
        case PheasantAttribute.r_text:
          pheasantHtml.nodes.add(Text(value));
          statement = 'PheasantHtml.nodes.add(Text($value))';
          break;
        case PheasantAttribute.r_else:
          if ((pheasantHtml.previousElementSibling?.attributes
          .entries.map((e) => e.key) ?? []).contains('r-if')) {
            statement = 'else {';
            closebracket++;
          }
          break;
        case PheasantAttribute.r_elseif:
          if ((pheasantHtml.previousElementSibling?.attributes
          .entries.map((e) => e.key) ?? []).contains('r-if')) {
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

String basicAttributes(Element? pheasantHtml, String beginningFunc, {String elementName = '_element'}) {
  for (var attr in pheasantHtml!.attributes.entries) {
    if (attr.key == 'class' || attr.key == 'className') {
      beginningFunc += '$elementName.classes.add(${attr.value});';
    } else if (attr.key == 'href' || attr.key == 'id') {
      beginningFunc += '$elementName.setAttribute(${attr.key as String}, "${attr.value}");';
    } else if (!PheasantAttribute.values.map((e) => e.name).contains(attr.key)){
      beginningFunc += '$elementName.setAttribute(${attr.key as String}, ${attr.value});';
    }
  }
  return beginningFunc;
}
