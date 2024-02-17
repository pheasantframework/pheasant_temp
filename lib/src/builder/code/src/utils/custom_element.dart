import 'package:html/dom.dart' show Element;

String customComponentRendering(Element element, String beginningFunc, String childname) {
  var componentItem =
      '${element.localName}.${'${element.localName!}Component()'}';
  if (element.attributes.keys
      .where((element) => (element as String).contains('p-bind'))
      .isNotEmpty) {
    var props = element.attributes.entries.where(
        (element) => (element.key as String).contains('p-bind'));
    Map<String, dynamic> params = Map.fromIterables(
        props.map((e) => (e.key as String).replaceAll('p-bind:', '')),
        props.map((e) => e.value));
    String paramlist =
        params.entries.map((e) => "${e.key}: ${e.value}").join(', ');
    componentItem =
        '${element.localName}.${'${element.localName!}Component($paramlist)'}';
  }
  beginningFunc += '''
  final ${childname}component = $componentItem;
  _i2.Element $childname = ${childname}component.render(${childname}component.template!);
  ''';
  return beginningFunc;
}
