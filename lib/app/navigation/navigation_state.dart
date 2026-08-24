// lib/app/navigation/navigation_state.dart
import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final String? path;
  final Map<String, String>? queryParams;
  final bool replace;
  final bool pop;
  final Object? extra;
  final int timestamp; // 🔥 Adicionado para garantir que o estado sempre mude

  const NavigationState({
    this.path,
    this.queryParams,
    this.replace = false,
    this.pop = false,
    this.extra,
    this.timestamp = 0,
  });

  const NavigationState.idle()
      : path = null,
        queryParams = null,
        replace = false,
        pop = false,
        extra = null,
        timestamp = 0;

  const NavigationState.goTo(
      this.path, {
        this.queryParams,
        this.replace = true,
        this.pop = false,
        this.extra,
        this.timestamp = 0,
      });

  const NavigationState.pushTo(
      this.path, {
        this.queryParams,
        this.replace = false,
        this.pop = false,
        this.extra,
        this.timestamp = 0,
      });

  const NavigationState.pushReplacementTo(
      this.path, {
        this.queryParams,
        this.replace = true,
        this.pop = false,
        this.extra,
        this.timestamp = 0,
      });

  const NavigationState.pop({this.timestamp = 0})
      : path = null,
        queryParams = null,
        replace = false,
        pop = true,
        extra = null;

  @override
  List<Object?> get props => [path, queryParams, replace, pop, extra, timestamp];
}
