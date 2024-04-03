import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tobeto_app/bloc/auth_bloc/authentication_event.dart';
import 'package:tobeto_app/bloc/auth_bloc/authentication_state.dart';


class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationUninitialized()) {
    on<AppStarted>((event, emit) async {
      // İlk durum veya Firebase ile authentication kontrolü yapabilirsiniz
      emit(AuthenticationAuthenticated()); // ya da AuthenticationUnauthenticated()
    });
  }
}
