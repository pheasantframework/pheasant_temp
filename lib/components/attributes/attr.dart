// ignore_for_file: constant_identifier_names

/// Base class for a Raven Attribute/Directive in a '.raven' template file
abstract interface class RavenAttributeType {
  final String name;
  final RavenAttributeType? dependsOn;

  const RavenAttributeType({required this.name, this.dependsOn});
}

/// Enhanced enum class based on the base abstract [RavenAttributeType]
/// 
/// In this enum, the different kind of Attributes that can be used on a [RavenComponent] are listed out here.
/// Each attribute type has a [name] variable, and linked attributes also have a [dependsOn] variable, which links to another [RavenAttributeType].
/// This shows what a [RavenAttribute] is linked to.
/// 
/// Any other attribute not listed here is therefore placed as [RavenAttribute.unknown].
enum RavenAttribute implements RavenAttributeType {
  r_await(name: 'r-await'),
  r_html(name: 'r-html'),
  r_if(name: 'r-if'),
  r_else(name: 'r-else', dependsOn: RavenAttribute.r_if),
  r_elseif(name: 'r-elseif', dependsOn: RavenAttribute.r_if),
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

  const RavenAttribute({required this.name, this.dependsOn});

  @override
  final String name;

  @override
  final RavenAttributeType? dependsOn;
}