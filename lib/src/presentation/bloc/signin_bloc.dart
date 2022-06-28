import 'package:desafio_mobile/src/presentation/bloc/signin_event.dart';
import 'package:desafio_mobile/src/presentation/bloc/signin_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/auth_user_usecase.dart';
import '../../shared/data_struct/auth.dart';

class SigninBloc extends Bloc<SigninEvent, SigninState> {
  final IAuthUserUsecase authUserUsecase;

  SigninBloc(this.authUserUsecase) : super(SigninInitialState()) {
    on<SubmitAuthForm>(_onSubmitAuthForm);
  }

  void _onSubmitAuthForm(
    SubmitAuthForm event,
    Emitter<SigninState> emitter,
  ) async {
    emit(SigninLoadingState());
    AuthUser data = AuthUser(email: event.username, password: event.password);

    final result = await authUserUsecase(data);

    result.fold(
      (l) => emit(SigninStateAuthFailure(l)),
      (r) => emit(SigninStateAuthFinished(r)),
    );
  }
}
