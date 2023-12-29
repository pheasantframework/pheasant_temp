import 'package:html/dom.dart';

import '../../../meta/metadata.dart';

void serveSingleComponents(Node root, String tagName) {
  List<Element> elementCategories = findAllElements(root, tagName);
  for (var element in elementCategories) {
    element.reparentChildren(element.parentNode ?? root);
  }
}

List<Element> findAllElements(Node root, String tagName) {
  List<Element> result = [];

  void searchElements(Node node) {
    if (node is Element && node.localName == tagName) {
      result.add(node);
    }

    if (node.hasChildNodes()) {
      node.nodes.forEach(searchElements);
    }
  }

  searchElements(root);

  return result;
}


@AltVersion('findAllElements', version: '0.0.3')
List<Element> findAllElementsNonRecursive(Node root, String tagName) {
  List<Element> result = [];
  List<Node> stack = [root];

  while (stack.isNotEmpty) {
    var currentNode = stack.removeLast();

    if (currentNode is Element && currentNode.localName == tagName) {
      result.add(currentNode);
    }

    if (currentNode.hasChildNodes()) {
      stack.addAll(currentNode.nodes);
    }
  }

  return result;
}