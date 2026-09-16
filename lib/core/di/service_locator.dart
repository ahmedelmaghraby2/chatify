class ServiceLocator {
  final Map<Type, dynamic> _singletons = {};
  final Map<Type, dynamic Function()> _lazyFactories = {};
  final Set<Type> _lazyInitialized = {};

  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  void register<T>(T instance) {
    _singletons[T] = instance;
    _lazyFactories.remove(T);
    _lazyInitialized.remove(T);
  }

  void registerLazySingleton<T>(T Function() factory) {
    _lazyFactories[T] = factory;
    _singletons.remove(T);
    _lazyInitialized.remove(T);
  }

  T get<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    if (_lazyFactories.containsKey(T)) {
      if (!_lazyInitialized.contains(T)) {
        _singletons[T] = _lazyFactories[T]!();
        _lazyInitialized.add(T);
      }
      return _singletons[T] as T;
    }

    throw Exception(
      'No instance of type $T has been registered. '
      'Register it first using register() or registerLazySingleton().',
    );
  }

  bool isRegistered<T>() {
    return _singletons.containsKey(T) || _lazyFactories.containsKey(T);
  }

  void unregister<T>() {
    _singletons.remove(T);
    _lazyFactories.remove(T);
    _lazyInitialized.remove(T);
  }

  void reset() {
    _singletons.clear();
    _lazyFactories.clear();
    _lazyInitialized.clear();
  }
}

final sl = ServiceLocator();
