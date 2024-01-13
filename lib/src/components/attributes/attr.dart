// ignore_for_file: constant_identifier_names

/// Base class for a Pheasant Attribute/Directive in a '.phs' template file
/// 
/// The class encapsulates the base info of all attributes: 
abstract interface class PheasantAttributeType {
  final String name;
  final PheasantAttributeType? dependsOn;

  const PheasantAttributeType({required this.name, this.dependsOn});
}

/// Enhanced enum class based on the base abstract [PheasantAttributeType]
/// 
/// In this enum, the different kind of Attributes that can be used on a [PheasantComponent] are listed out here.
/// Each attribute type has a [name] variable, and linked attributes also have a [dependsOn] variable, which links to another [PheasantAttributeType].
/// This shows what a [PheasantAttribute] is linked to.
/// 
/// Any other attribute not listed here is therefore placed as [PheasantAttribute.unknown].
enum PheasantAttribute implements PheasantAttributeType {
  p_await(name: 'p-await'),
  p_html(name: 'p-html'),
  p_if(name: 'p-if'),
  p_else(name: 'p-else', dependsOn: PheasantAttribute.p_if),
  p_elseif(name: 'p-elseif', dependsOn: PheasantAttribute.p_if),
  p_fetch(name: 'p-fetch'),
  p_for(name: 'p-for'),
  p_obj(name: 'p-obj'),
  p_once(name: 'p-obj'),
  p_on(name: 'p-on'),
  p_route(name: 'p-route'),
  p_show(name: 'p-show'),
  p_slot(name: 'p-slot'),
  p_state(name: 'p-state'),
  p_text(name: 'p-text'),
  p_while(name: 'p-while'),
  unknown(name: 'nil')
  ;

  const PheasantAttribute({required this.name, this.dependsOn});

  @override
  final String name;

  @override
  final PheasantAttributeType? dependsOn;
}