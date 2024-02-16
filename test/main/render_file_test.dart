import 'package:pheasant_assets/pheasant_assets.dart';
import 'package:pheasant_temp/pheasant_temp.dart';
import 'package:test/test.dart';

void main() {
  group('small case', () {
    String script = '''
import 'components/Component.phs' as Component;

int myInt = 5;
''';
    String template = '''
<div>
  <h1>Hello, and Welcome to the first Pheasant Test</h1>
  <h2>CASE I</h2>
  <div p-for="int i = 0; i < 2; ++i">
    <p>Test Subject</p>
    <a preventDefault>Test Link</a>
  </div>
  <h2>CASE II</h2>
  <md class="test">
# CASE TWO
This is the second component of this group, written in `markdown`.

Markdown is a language very similar to html, and it even allows html to be written in it. 

It also allows for code to be written in it
```dart
void main() {
  print("Hello World")
}
```
  </md>
</div>
''';
  String style = '''
  .test {
    color: gold;
  }
''';

  PheasantStyle testStyle = PheasantStyle(data: style);
  test('prerequisite functions', () {
    assert(testStyle.src == null);

    PheasantScript testScript = PheasantScript(varDef: extractVariable(script), funDef: extractFunction(script), impDef: extractImports(script));
    expect(testScript.fields.length, equals(1));
    expect(testScript.imports.length, equals(1));
    expect(testScript.methods, isEmpty);
  });

  String output = renderFunc(script: script, template: template, pheasantStyle: testStyle, sass: false);

  test('main function 1', () {
    expect(output, contains("import 'dart:html'"));
    expect(output, contains(expected));
  });
  });
}