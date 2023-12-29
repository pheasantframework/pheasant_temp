import 'package:html/dom.dart';

import '../../code/src/tempclass.dart';
import '../../../components/attributes/attr.dart';

String renderElement(String beginningFunc, Element? ravenHtml, Iterable<String> attrmap, {String elementName = '_element', Map<String, String> nonDartImports = const {}}) {
  int closebracket = 0;
  beginningFunc = basicAttributes(ravenHtml, beginningFunc, elementName: elementName);
  final tempobj = ravenAttributes(ravenHtml, attrmap, beginningFunc, closebracket,  elementName: elementName);
  beginningFunc = tempobj.value;
  closebracket = tempobj.number;
  // Add children
  beginningFunc = attachChildren(ravenHtml, beginningFunc,  elementName: elementName, nonDartImports: nonDartImports);
  
  beginningFunc += ('}\n' * closebracket);
  return beginningFunc;
}

String attachChildren(Element? ravenHtml, String beginningFunc, {String Function(String, Element?, Iterable<String>, {String elementName}) childFun = renderElement, String elementName = '_element', Map<String, String> nonDartImports = const {}}) {
  if (ravenHtml!.nodes.isNotEmpty) {
    ravenHtml.nodes.forEach((element) {
      if (element.nodeType == 3) {
        beginningFunc += '$elementName.childNodes.add(_i2.Text("""${element.text}"""));';
      } else {
        String childname = "newChild${ravenHtml.children.indexOf(element as Element)}";
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
        childstrFunc = childFun(childstrFunc, element, RavenAttribute.values.map((e) => e.name), elementName: childname);
        beginningFunc += childstrFunc;
        beginningFunc += '$elementName.children.add($childname);';
      }
    });
  }
  return beginningFunc;
}

TempRavenRenderClass ravenAttributes(Element? ravenHtml, Iterable<String> attrmap, String beginningFunc, int closebracket, {String elementName = '_element'}) {
  for (var attr in ravenHtml!.attributes.entries) {
    if (attrmap.contains(attr.key)) {
      RavenAttribute defAttr = RavenAttribute.values[attrmap.toList().indexOf(attr.key as String)];
      String value = attr.value;
      String statement = '';
      switch (defAttr) {
        case RavenAttribute.r_if:
          statement = 'if ($value) {';
          closebracket++;
          break;
        case RavenAttribute.r_while:
          statement = 'while ($value) {';
          closebracket++;
          break;
        case RavenAttribute.r_for:
          statement = 'for ($value) {';
          closebracket++;
          break;
        case RavenAttribute.r_html:
          ravenHtml.innerHtml += value; 
          statement = 'RavenHtml.innerHtml += $value';
          break;
        case RavenAttribute.r_text:
          ravenHtml.nodes.add(Text(value));
          statement = 'RavenHtml.nodes.add(Text($value))';
          break;
        case RavenAttribute.r_else:
          if ((ravenHtml.previousElementSibling?.attributes
          .entries.map((e) => e.key) ?? []).contains('r-if')) {
            statement = 'else {';
            closebracket++;
          }
          break;
        case RavenAttribute.r_elseif:
          if ((ravenHtml.previousElementSibling?.attributes
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
  return /*beginningFunc*/ TempRavenRenderClass(number: closebracket, value: beginningFunc);
}

String basicAttributes(Element? ravenHtml, String beginningFunc, {String elementName = '_element'}) {
  for (var attr in ravenHtml!.attributes.entries) {
    if (attr.key == 'class' || attr.key == 'className') {
      beginningFunc += '$elementName.classes.add(${attr.value});';
    } else if (attr.key == 'href' || attr.key == 'id') {
      beginningFunc += '$elementName.setAttribute(${attr.key as String}, "${attr.value}");';
    } else if (!RavenAttribute.values.map((e) => e.name).contains(attr.key)){
      beginningFunc += '$elementName.setAttribute(${attr.key as String}, ${attr.value});';
    }
  }
  return beginningFunc;
}
