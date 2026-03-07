part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

// O único estado que a Home precisa gerenciar é a aba selecionada.
class HomeTabChanged extends HomeState {
  final int selectedIndex;

  const HomeTabChanged(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
