import 'dart:async';
import 'dart:html';

import 'package:pheasant_meta/pheasant_meta.dart';

import '../base.dart';

// TODO: Write documentation for all these

mixin StateControl {
  void freeze();

  void unfreeze();

  void reload();
}

mixin ComponentStateControl {
  void applyState();

  void dispose();
}

abstract class State<T> with StateControl {
  T initValue;
  late T _previousValue;
  // ignore: prefer_final_fields
  late T _currentValue;

  State({required this.initValue, T? newValue}) : 
  _currentValue = newValue ?? initValue,
  _previousValue = initValue
  ;

  T get currentValue => _currentValue;

  T get previousValue => _previousValue;

  void change(T newValue);
}

class StateChange<T> {
  Event? triggerEvent;
  T? newValue;
  dynamic Function(dynamic)? stateChanger;
  StateTarget? _target;

  StateTarget? get target => _target;

  bool get targetless => _target == null;

  StateChange({
    required this.triggerEvent, 
    required this.newValue, 
    this.stateChanger,
    StateTarget? target,
  }) : _target = target;
  StateChange.empty() : triggerEvent = null, newValue = null;
}

class StateTarget {}

class StateObject<T> extends State<T> {
  bool _changeable = true;

  @override
  // ignore: overridden_fields
  late T _currentValue;

  StateObject({required super.initValue, T? newValue}) : _currentValue = newValue ?? initValue;

  @override
  void change(T newValue) {
    if (_changeable) { _previousValue = _currentValue; _currentValue = newValue; }
  }

  @override
  void freeze() => _changeable = false;

  @override
  void unfreeze() => _changeable = true;

  @override
  void reload() {
    change(initValue);
  }
}
/** I'll decide which one to use between [State] and [StateObject] later */
class ElementState<T> extends State<T> with StateControl, ComponentStateControl {
  final StreamController<StateChange<T>> _stateController = StreamController<StateChange<T>>.broadcast();

  Stream<StateChange<T>> get stateStream => _stateController.stream;

  State<T> componentState;

  T component;

  ElementState({required this.component, State<T>? state}) : componentState = state ?? StateObject<T>(initValue: component), super(initValue: component);

  @override
  void freeze() {
    componentState.freeze();
  }

  @override
  void reload() {
    componentState.reload();
  }
  
  @override
  void applyState() {
    // TODO: implement applyState
  }
  
  @override
  void unfreeze() {
    // TODO: implement unfreeze
  }
  
  @override
  void dispose() {
    // TODO: implement dispose
  }
  
  @override
  void change(T newValue) {
    // TODO: implement change
  }
}



class ChangeEmitter<T> {
  final _valueController = StreamController<T>.broadcast();

  // Stream for listening to variable value changes
  late Stream<T> emittedStream = _valueController.stream;

  void emit() {}

  void emitStream(Stream<T> stream, /*ChangeReceiver<T> receiver*/) {
    emittedStream = stream;
  }

  void dispose() {
    _valueController.close();
  }
} 

class ChangeReceiver<T> {
  final _valueController = StreamController<T>.broadcast();

  // Stream for listening to variable value changes
  Stream<T> get receivedStream => _valueController.stream;

  void receive() {}

  void receiveStream() {}

  void dispose() {
    _valueController.close();
  }
}

class ChangeWatcher<T> with StateControl, ComponentStateControl implements ChangeEmitter<T>, ChangeReceiver<T> {
  T initValue;

  State<T> initialState;

  StateChange<T>? currentStateChange;

  T get currentValue => initialState.currentValue;

  bool _freeze = false;

  ChangeWatcher({required this.initValue, State<T>? state}) : initialState = StateObject(initValue: initValue);

  @override
  void emit() {}

  @override
  void receive() {}

  Future<State<T>> get currentState async => StateObject(initValue: initValue)..change(await _valueController.stream.last);
  // StreamController to handle variable value changes
  final _valueController = StreamController<T>.broadcast();

  // Stream for listening to variable value changes
  Stream<T> get valueStream => _valueController.stream;

  // Function to watch the variable
  void watchVariable(T variable) {
    if (!_freeze) {
      // Notify listeners whenever the variable changes
    _valueController.add(variable);
    }
  }

  void ping() {}

  @override
  void freeze() {
    _valueController.stream.listen((event) {}).pause();
    _freeze = true;
  }

  @override
  void reload() {
    initialState.change(initValue);
    _valueController.add(initValue);
  }

  // Dispose method to close the stream when no longer needed
  @override
  void dispose() {
    _freeze = false;
    _valueController.close();
  }
  
  @override
  void unfreeze() {
    // TODO: implement unfreeze
  }
  
  @override
  void applyState() {
    // TODO: implement applyState
  }
  
  @override
  void emitStream(Stream<T> stream) {
    // TODO: implement emitStream
  }
  
  @override
  Stream<T> get emittedStream => throw UnimplementedError("Watcher can only have one stream");
  
  @override
  void receiveStream() {
    // TODO: implement receiveStream
  }
  
  @override
  Stream<T> get receivedStream => throw UnimplementedError("Watcher can only have one stream");
  
  @override
  set emittedStream(Stream<T> _emittedStream) {
    throw UnimplementedError("Watcher can only have one stream");
  }
}

class TemplateState extends ElementState<PheasantTemplate> {
  TemplateState({
    required super.component,
    PheasantTemplate? initState,
    this.disposeState
  }) : initState = initState ?? component,
  emitter = ChangeEmitter(),
  receiver = ChangeReceiver()
  ;

  bool _frozen = false;

  bool get onPause => _frozen;

  PheasantTemplate initState;
  PheasantTemplate? disposeState;

  ChangeEmitter emitter;
  ChangeReceiver receiver;

  void emit(Event event, {PheasantTemplate? templateState}) {}

  void receive<T>(StateChange stateChange, T refVariable) {}

  @override
  void dispose() {
    if (disposeState != null) component = disposeState!;
    super.dispose();
  }
}

/// Object to represent the application's state
/// 
/// IDEAS:
/// - `state.emit(Event e, )` - emit state change due to fired event
/// - `state.stateChange` - the current state change
/// - `state.reload()` - reload state back to init state
/// - `state.freeze()` - hold state on pause
/// - `state.receive(Event e, StateChange change, )` - receive a state change due to a fired event
/// - `state.watch(Element element, )` - watch an element for changes in state
/// - `state.changes()` - get stream of changes since app was created.
/// - `state.dispose()` - dispose changes
/// - `state.register(ChangeWatcher<T> item, State currentState, T variable)` - registers a watcher to watch for changes in a variable
/// - `state.applyChanges()` - apply state changes incase for the application (usually during reload or something like that)
/// 
/// ```dart
/// // Functions have changed
/// void renderElement(PheasantTemplate app) {
///   AppState state = AppState(app);
///   Element elementApp = pheasantTemplate.render(pheasantTemplate.template!, appState: state);
///   
///   state.changes.listen((value) {
///     Element elementApp = pheasantTemplate.render(pheasantTemplate.template!, appState: state);
///     querySelector('#output')?.children.first = elementApp;
///   })
/// 
///   querySelector('#output')?.children.add(elementApp);
///   
///   
/// }
/// void createApp(PheasantTemplate pheasantTemplate, /* {AppState? state} - still thinking about it*/) {
///   renderElement(pheasantTemplate.render(pheasantTemplate.template!));
/// }
/// 
/// ```
/// 
/// Allow backwards compatibility for static sites (sites not containing changes)
/// 
/// FUTURE: Implement focused changes on variables
class AppState extends TemplateState {
  @override
  // ignore: overridden_fields
  State<PheasantTemplate> componentState;

  StateChange<PheasantTemplate> _stateChange;

  State<PheasantTemplate> get currentState => componentState;
  
  List<ChangeWatcher> watchers = [];

  AppState({
    required PheasantTemplate component,
    this.watchers = const [],
    PheasantTemplate? initState,
    PheasantTemplate? disposeState
  }) : 
  componentState = StateObject(initValue: component),
  _stateChange = StateChange.empty(),
  super(initState: initState, component: component, disposeState: disposeState)
  ;

  StateChange<PheasantTemplate> get stateChange => _stateChange;

  // Stream for listening to state changes
  @override
  Stream<StateChange<PheasantTemplate>> get stateStream => _stateController.stream;

  void streamChange(PheasantTemplate? templateChange, StateChange<PheasantTemplate> newChange) {
    if (!_frozen) {
      if (templateChange != null) componentState.change(templateChange);
      _stateChange = newChange;
      _stateController.add(newChange);
    }
  }

  @override
  void emit(Event event, {PheasantTemplate? templateState}) {
    if (!_frozen) {
      StateChange<PheasantTemplate> change = StateChange(triggerEvent: event, newValue: templateState); // Set state change
      emitter.emit(); // Unimplemented yet
      super.emit(event, templateState: templateState);
      streamChange(templateState, change);
    }
  }

  void registerWatcher<T>(State<T> variableState, T variable, {ChangeWatcher<T>? watcher}) {
    watchers.add(watcher ?? ChangeWatcher<T>(initValue: variable, state: variableState));
  }

  void removeWatcher<T>(ChangeWatcher watcher, {T? reference}) {
    watchers.removeWhere((element) => element == watcher);
  }

  @override
  void receive<T>(StateChange stateChange, T refVariable) => throw PheasantUnimplementedError("Not yet implemented yet");

  @override
  void freeze() {
    componentState.freeze();
    for (var element in watchers) {
      element.freeze();
    }
    _frozen = true;
  }

  @override
  void unfreeze() {
    componentState.unfreeze();
    for (var element in watchers) {
      element.unfreeze();
    }
    _frozen = false;
  }

  @override
  void reload() {
    for (var element in watchers) {
      element.reload();
    }
    _stateChange = StateChange.empty();
    componentState.reload();
  }

  
}

@From('0.1.3')
extension ExtraFunctionality on TemplateState {
  void watch() {}

  void applyState() {}
}

@From('0.2.0')
extension TimedState on ComponentStateControl {
  /// Will treat this later on
  void hold(Duration timeDuration) {}  

  void temporaryState() {}
}


/// other annotations: `@binding`, `@observe`, 
// @state
// var num = 9;