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
  r_await(name: 'r-await'),
  r_html(name: 'r-html'),
  r_if(name: 'r-if'),
  r_else(name: 'r-else', dependsOn: PheasantAttribute.r_if),
  r_elseif(name: 'r-elseif', dependsOn: PheasantAttribute.r_if),
  r_fetch(name: 'r-fetch'),
  r_for(name: 'r-for'),
  r_obj(name: 'r-obj'),
  r_once(name: 'r-obj'),
  r_on(name: 'r-on'),
  r_route(name: 'r-route'),
  r_show(name: 'r-show'),
  r_slot(name: 'r-slot'),
  r_state(name: 'r-state'),
  r_text(name: 'r-text'),
  r_while(name: 'r-while'),
  unknown(name: 'nil')
  ;

  const PheasantAttribute({required this.name, this.dependsOn});

  @override
  final String name;

  @override
  final PheasantAttributeType? dependsOn;
}