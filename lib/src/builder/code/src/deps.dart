import 'package:html/dom.dart' show Element, Text;
import 'package:markdown/markdown.dart' show markdownToHtml;
import 'package:pheasant_assets/pheasant_assets.dart' show PheasantStyle, PheasantStyleScoped;

import '../constants/defs.dart';
import 'events.dart';
import '../constants/lists.dart' as phsattr;
import '../constants/tempclass.dart';
import '../../../components/attributes/attr.dart';

/// This is the much rather recursive function used in rendering the element variable.
/// 
/// In this function, the following, in order are performed:
/// 
/// 1. The attributes of the element are rendered and functionality added to the code body - [basicAttributes]. 
/// In addition, a scoped class name is added with the help of the [PheasantStyleScoped] class for scoping styles stated or referenced in the `style` tag in the pheasant file.
/// 
/// 2. The special pheasant attributes of the element are rendered and functionality added to the code body - [pheasantAttributes].
/// 
/// 3. The children of the element - both text nodes and elements - are rendered in recursive order (from 1) and added to the parent - [attachChildren].
/// This could also include the passing of data to the child element via `p-attach` as constructors to custom child components.
/// 
/// In this function, [beginningFunc] is an alias for the code body (to be modified and returned under the same name). 
/// [pheasantHtml] is the parsed Html we are using to generate functionality to modify `beginningFunc`.
/// 
/// [attrmap] is an iterable of strings containing pheasant attributes.
/// 
/// [elementName] is the element name that is being rendered, used for code generation. It defaults to the main element name - `element`.
/// 
/// [nonDartImports] refer to imported pheasant components that are used in children rendering.
String renderElement(
  String beginningFunc, 
  Element? pheasantHtml, 
  Iterable<String> attrmap, {
    String elementName = 'element', 
    Map<String, String> nonDartImports = const {}, 
    PheasantStyleScoped? pheasantStyleScoped
  }) {  
  beginningFunc = basicAttributes(pheasantHtml, beginningFunc, elementName: elementName, styleScoped: pheasantStyleScoped);
  int closebracket = 0;
  // Render attributes
  final tempobj = pheasantAttributes(pheasantHtml, attrmap: attrmap, beginningFunc, closebracket,  elementName: elementName);
  beginningFunc = tempobj.value;
  closebracket = tempobj.number;
  // Add children
  beginningFunc = attachChildren(pheasantHtml, beginningFunc,  elementName: elementName, nonDartImports: nonDartImports);
  
  // Add remaining closed braces to close up scope and render valid dart code
  beginningFunc += ('}\n' * closebracket);
  return beginningFunc;
}


/// Function for adding style to elements
/// 
/// This function only runs once during the lifetime of recursion, which is used for rendering the 'style' part of a pheasant file.
/// 
/// The main component here is the [pheasantStyleScoped] item, which is a scoped and rendered pheasant style object ready for deployment.
/// It is of the type [PheasantStyleScoped], an extended and scoped version of [PheasantStyle].
String styleElement(String beginningFunc, PheasantStyleScoped? pheasantStyleScoped, String elementName) {
  String styleElementName = "styleElement_${pheasantStyleScoped.hashCode}";
  beginningFunc += '''
_i2.StyleElement $styleElementName = _i2.StyleElement()
  ..text = """${pheasantStyleScoped != null ? pheasantStyleScoped.css : ''}"""
  ..setAttribute("type", "text/css");
  _i2.document.head?.children.add($styleElementName);
  ''';
  return beginningFunc;
}

/// This function is used to render and attach children - both text nodes and elements - to their parents and reflect the functionality for the code.
/// 
/// This function modifies [beginningFunc] through the help of [pheasantHtml] and therefore, returns the modified version of it.
/// 
/// In this function, text nodes are attached via [Element.append] to the element, and changes are reflected as shown. Any remaining interpolation (`{{}}`) is replaced by the desired variable or value.
/// 
/// 
/// Element nodes are first of all rendered by calling [childFun] to render the element and its children in the desired way. 
/// By default, [childFun] is equal to the standard rendering function [renderElement]
/// 
/// For the case of custom components, the [nonDartImports] map contains the key-value pair representing the name and import path of the custom components.
/// These custom components are simply rendered by calling their desired `render` function, and then attaching the returned [Element] to the parent.
/// 
/// If there is the presence of a `p-bind` attribute in the tag, then the referenced name is passed as name-value areguments to the custom component constructor. 
/// This helps to achieve data passing and binding between parent and child.
/// 
/// IF the custom component contains children, then this is passed to the `slot`s defined in the custom component.
String attachChildren(
  Element? pheasantHtml, 
  String beginningFunc, 
  {
    String Function(String, Element?, Iterable<String>, {String elementName, Map<String, String> nonDartImports}) childFun = renderElement, 
    String elementName = 'element', 
    Map<String, String> nonDartImports = const {}, 
    PheasantStyleScoped? pheasantStyleScoped, 
    Iterable<String> attrmap = const []
  }) {
  // Ensure that children exist before running code
  if (pheasantHtml!.nodes.isNotEmpty) {
    // Iterate through all `nodes` (not just elements)
    for (var element in pheasantHtml.nodes) {
      // Ignore part rendering for cases of `p-text`
      if (element.parent!.attributes.containsKey('p-text') && pheasantHtml.nodes.last == element) {
        
      } else if (element.nodeType == 3) {
        // Render text nodes
        if ((element.text ?? '').contains(RegExp(r'\{\{([^\}]+)\}\}'))) {
          // Remove interpolation and add desired value
          final regex = RegExp(r'\{\{([^\}]+)\}\}');
          Match match = regex.allMatches(element.text ?? '').first;
          element.text = '\${${match[1]}}';
        } else if ((element.text ?? '').contains(RegExp(r'\{([^\}]+)\}'))) {
          // Remove interpolation and add desired value
          final regex = RegExp(r'\{([^\}]+)\}');
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
          beginningFunc = markdownRender(beginningFunc, childname, element, pheasantStyleScoped, attrmap);
          beginningFunc += '$elementName.children.add($childname);';
        } else {
          if (nonDartImports.keys.contains(element.localName)) {
            var componentItem = '${element.localName}.${'${element.localName!}Component()'}';
            if (element.attributes.keys.where((element) => (element as String).contains('p-bind')).isNotEmpty) {
              var props = element.attributes.entries.where((element) => (element.key as String).contains('p-bind'));
              Map<String, dynamic> params = Map.fromIterables(
                props.map((e) => (e.key as String).replaceAll('p-bind:', '')),
                props.map((e) => e.value)
              );
              String paramlist = params.entries.map((e) => "${e.key}: ${e.value}").join(', ');
              componentItem = '${element.localName}.${'${element.localName!}Component($paramlist)'}';
            }
            beginningFunc += '''
final ${childname}component = $componentItem;
_i2.Element $childname = ${childname}component.render(${childname}component.template!);
''';
          } else {
            beginningFunc += "_i2.Element $childname = _i2.Element.tag('${(element).localName}');";
          }
          String childstrFunc = "";
          childstrFunc = childFun(childstrFunc, element, PheasantAttribute.values.map((e) => e.name), elementName: childname, nonDartImports: nonDartImports);
          beginningFunc += childstrFunc;
          if (nonDartImports.keys.contains(element.parent!.localName)) {
            if (element.attributes.keys.where((object) => (object as String).contains('p-slot')).isNotEmpty) {
              beginningFunc += "$elementName.querySelector('slot #${(element.attributes.keys.singleWhere((element) => (element as String).contains('p-slot')) as String).replaceFirst('p-slot:', '')}')?.children.add($childname);";
            } else {
              beginningFunc += "$elementName.querySelector('slot')?.children.add($childname);";
            }
          } else {
            beginningFunc += '$elementName.children.add($childname);';
          }
        }
      }
    }
  }
  return beginningFunc;
}

/// Function used for rendering markdown code.
/// 
/// This function is specially attributed to rendering markdown code, as markdown is compiled to HTML in the framework. 
/// 
/// In all markdown code, there are no direct children (only markdown). So most of the rendering comes from attribute rendering. 
String markdownRender(String beginningFunc, String childname, Element element, PheasantStyleScoped? pheasantStyleScoped, Iterable<String> attrmap) {
  beginningFunc += "_i2.Element $childname = _i2.Element.div();";
  int closebracket = 0;
  // Render attributes
  beginningFunc = basicAttributes(element, beginningFunc, elementName: childname, styleScoped: pheasantStyleScoped);

  final tempobj = pheasantAttributes(element, attrmap: attrmap, beginningFunc, closebracket,  elementName: childname);
  beginningFunc = tempobj.value;
  closebracket = tempobj.number;
  beginningFunc += "$childname.innerHtml = '''${markdownToHtml(element.innerHtml)}''';";

  beginningFunc += ('}\n' * closebracket);
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
PheasantTC pheasantAttributes(Element? pheasantHtml, String beginningFunc, int closebracket, {String elementName = 'element', Iterable<String>? attrmap, Iterable<String>? eventAttrMap}) {
  Iterable<String> attributeMap = attrmap ?? PheasantAttribute.values.map((e) => e.name);
  Iterable<String> eventAttributeMap = eventAttrMap ?? PheasantEventHandlingAttribute.values.map((e) => e.name);
  for (var attr in pheasantHtml!.attributes.entries) {
    if (attributeMap.contains(attr.key)) {
      PheasantAttribute defAttr = PheasantAttribute.values[attributeMap.toList().indexOf(attr.key as String)];
      String value = attr.value;
      String statement = '';
      PheasantTC compound = pheasantBasicAttributes(pheasantHtml, defAttr, statement, value, closebracket, elementName: elementName);
      closebracket = compound.number;
      statement = compound.value;
      beginningFunc += '$statement\n';
      continue;
    } else if (eventAttributeMap.contains(attr.key)) {
      PheasantEventHandlingAttribute defAttr = PheasantEventHandlingAttribute.values[eventAttributeMap.toList().indexOf(attr.key as String)];
      String value = attr.value;
      String statement = '';
      PheasantTC compound = pheasantEventHandlingAttributes(pheasantHtml, defAttr, statement, value, closebracket, elementName: elementName);
      closebracket = compound.number;
      statement = compound.value;
      beginningFunc += '$statement\n';
    }
  }
  return TempPheasantRenderClass(number: closebracket, value: beginningFunc);
}

/// Function for handling pheasant atttributes dealing with event handling.
PheasantTC pheasantEventHandlingAttributes(
  Element pheasantHtml, 
  PheasantEventHandlingAttributeType defAttr, 
  String statement, 
  String value, 
  int closebracket, {
  String elementName = 'element',
}) {
  String stateStatement = defaultStateAttributes.keys.contains(value) ? defaultStateAttributes[value]! : "state?.emit(event, templateState: this);";
  String eventStatement = defAttr.name.replaceAll('p-', '').split(':').map((e) {
    if (e != 'on') {
      String statement = e;
      e = statement.replaceFirst(statement[0], statement[0].toUpperCase());
    }
    return e;
  }).join();
  bool preventDefault = false;
  preventDefault = preventDefaultCheck(pheasantHtml, defAttr.name);
  statement = '''$elementName.$eventStatement.listen((event) {
    ${!defaultStateAttributes.keys.contains(value) ? "if (!(state?.onPause ?? false)) { " : "" }
    ${preventDefault ? 'event.preventDefault();' : ""}
    ${!defaultStateAttributes.keys.contains(value) ? "$value;" : ""}
    $stateStatement
    ${!defaultStateAttributes.keys.contains(value) ? "}" : ""}
  });''';
  if ((pheasantHtml.attributes.keys.contains('nostate'))) {
    statement = '''$elementName.$eventStatement.listen((event) {
      ${preventDefault ? 'event.preventDefault();' : ""}
      ${!defaultStateAttributes.keys.contains(value) ? "$value;" : ""}
    });''';
  }
  return TempPheasantRenderClass(number: closebracket, value: statement);
}

/// Function for switching and handling basic pheasant attributes.
PheasantTC pheasantBasicAttributes(
  Element pheasantHtml, 
  PheasantAttributeType defAttr, 
  String statement, 
  String value, 
  int closebracket, {
  String elementName = 'element'
}) {
  switch (defAttr) {
    case PheasantAttribute.p_if:
      statement = 'if ($value) {';
      closebracket++;
      break;
    case PheasantAttribute.p_while:
      statement = 'while ($value) {';
      closebracket++;
      break;
    case PheasantAttribute.p_for:
      statement = 'for ($value) {';
      closebracket++;
      break;
    case PheasantAttribute.p_html:
      pheasantHtml.innerHtml += value; 
      statement = '$elementName.innerHtml = $elementName.innerHtml == null ? "$value" : $elementName.innerHtml! + "$value";';
      break;
    case PheasantAttribute.p_text:
      pheasantHtml.nodes.add(Text(value));
      statement = '$elementName.append(_i2.Text("\${$value}"));';
      break;
    case PheasantAttribute.p_else:
      if ((pheasantHtml.previousElementSibling?.attributes
      .entries.map((e) => e.key) ?? []).contains('p-if')) {
        statement = 'else {';
        closebracket++;
      }
      break;
    case PheasantAttribute.p_elseif:
      if ((pheasantHtml.previousElementSibling?.attributes
      .entries.map((e) => e.key) ?? []).contains('p-if')) {
        statement = 'else if ($value) {';
        closebracket++;
      }
      break;
    default:
  }
  return TempPheasantRenderClass(number: closebracket, value: statement);
}

/// Function used for writing code to make and assert normal attributes in a component.
/// 
/// This function asseses the [Element] named [pheasantHtml] and then iterates through the attributes in the element. 
/// It then adds the appropriate line of code to render it.
/// 
/// It also specially renderes certain attributes like `p-attach` for instance.
String basicAttributes(Element? pheasantHtml, String beginningFunc, {String elementName = 'element', PheasantStyleScoped? styleScoped}) {
  for (var attr in pheasantHtml!.attributes.entries) {
    if (phsattr.className.contains(attr.key)) {
      beginningFunc += '$elementName.classes.add("${attr.value}");';
    } else if (phsattr.nonStringAttr.contains(attr.key)) {
      beginningFunc += '$elementName.setAttribute("${attr.key as String}", "${attr.value}");';
    } else if (phsattr.nonrenderableAttrs((attr.key as String).toLowerCase())) {

    } else if (
      !phsattr.pheasantAttr.contains(attr.key)
      && !phsattr.containsDepAttrs(attr.key as String)
    ) {
      if (!(attr.key as String).contains('p-attach')) {
        beginningFunc += '$elementName.setAttribute("${attr.key as String}", "${attr.value}");';
      } else {
        beginningFunc += '$elementName.setAttribute("${(attr.key as String).replaceAll('p-attach:', '')}", "\${${attr.value}}");';
      }
    } else {
      beginningFunc += '$elementName.setAttribute("${attr.key as String}", "${attr.value}");';
    }
    if (pheasantHtml.localName == 'input' && (attr.key as String).contains('@')) {
      String data = '''$elementName.onInput.listen((event) {''';
      if (preventDefaultCheck(pheasantHtml, 'onInput')) {
        data += '''event.preventDefault();''';
      } 
      data += ''' ${(attr.key as String).replaceFirst('@', '')} = ($elementName as _i2.InputElement).value ?? '';
      });''';
      beginningFunc += data;
    }
    
  }
  if (styleScoped != null && styleScoped.scoped) {
    beginningFunc += '$elementName.classes.add("${styleScoped.id}");';
  }
  return beginningFunc;
}
