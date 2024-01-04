// ignore_for_file: constant_identifier_names

/// Base class for a Pheasant Attribute/Directive in a '.phs' template file
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
  r_await(name: 'p-await'),
  r_html(name: 'p-html'),
  r_if(name: 'p-if'),
  r_else(name: 'p-else', dependsOn: PheasantAttribute.r_if),
  r_elseif(name: 'p-elseif', dependsOn: PheasantAttribute.r_if),
  r_fetch(name: 'p-fetch'),
  r_for(name: 'p-for'),
  r_obj(name: 'p-obj'),
  r_once(name: 'p-obj'),
  r_on(name: 'p-on'),
  r_route(name: 'p-route'),
  r_show(name: 'p-show'),
  r_slot(name: 'p-slot'),
  r_state(name: 'p-state'),
  r_text(name: 'p-text'),
  r_while(name: 'p-while'),
  unknown(name: 'nil')
  ;

  const PheasantAttribute({required this.name, this.dependsOn});

  @override
  final String name;

  @override
  final PheasantAttributeType? dependsOn;
}