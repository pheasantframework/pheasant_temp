import 'package:pheasant_temp/src/components/attributes/attr.dart';

List<PheasantAttributeType> _attributes = PheasantAttribute.values;

List<PheasantEventHandlingAttributeType> _eventAttributes = PheasantEventHandlingAttribute.values;

List<PheasantAttributeType> get attributes => _attributes;

List<PheasantEventHandlingAttributeType> get eventAttributes => _eventAttributes;

void addAttribute(PheasantAttributeType attribute) {
  _attributes.add(attribute);
}

void addEventHandlingAttribute(PheasantEventHandlingAttributeType attribute) {
  _eventAttributes.add(attribute);
}