@Timeout(Duration(seconds: 1))

import 'package:pheasant_temp/pheasant_temp.dart';
import 'package:test/test.dart';


void main() {
  group('speed test', () {
    List<String> results = List<String>.filled(5, '');

    test('speed run', () {
      final Stopwatch stopwatch = Stopwatch()..start();

      results[0] = renderMain();
      print('Result 1: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      results[1] = renderMain(appName: "HomeComponent");
      print('Result 2: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      results[2] = renderMain(appName: "ThisIsAnExtremelyLongClassNameThatServesNoPracticalPurposeButIsUsedHereForDemonstrationPurposesComponent");
      print('Result 3: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      results[3] = renderMain(appName: "HomeComponent", mainEntry: "Home.phs");
      print('Result 4: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      results[4] = renderMain(appName: "ThisIsAnExtremelyLongClassNameThatServesNoPracticalPurposeButIsUsedHereForDemonstrationPurposesComponent", mainEntry: "ThisIsAnExtremelyLongClassNameThatServesNoPracticalPurposeButIsUsedHereForDemonstrationPurposes.phs");
      print('Result 5: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.stop();
    });
  });
}