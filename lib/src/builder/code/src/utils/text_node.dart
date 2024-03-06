// Copyright (c) 2024 The Pheasant Group. All Rights Reserved.
// Please see the AUTHORS files for more information.
// Intellectual property of third-party.
// 
// This file, as well as use of the code in it, is governed by an MIT License
// that can be found in the LICENSE file.
// You may not use this file except in compliance with the License.
  
import 'package:html/dom.dart' show Node;

String textNodeRendering(
    Node element, String beginningFunc, String elementName) {
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
  return beginningFunc;
}
