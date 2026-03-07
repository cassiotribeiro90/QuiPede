import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  // O estado inicial agora é a aba 0.
  HomeCubit() : super(const HomeTabChanged(0));

  void changeTab(int index) {
    emit(HomeTabChanged(index));
  }
}
