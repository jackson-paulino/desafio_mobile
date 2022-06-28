import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/data/repositories/auth_repository.dart';
import 'src/domain/usecases/auth_user_usecase.dart';
import 'src/external/datasources/auth_datasource.dart';
import 'src/presentation/bloc/signin_bloc.dart';

class Shell extends StatelessWidget {
  final Widget child;
  const Shell({Key? key, required this.child}) : super(key: key);

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  List<RepositoryProvider> get listRepositoryProvider => [
        RepositoryProvider<FirebaseAnalyticsObserver>(
          create: (context) => _observer,
        ),
        RepositoryProvider<FirebaseAnalytics>(
          create: (context) => _analytics,
        ),
        RepositoryProvider<FirebaseAuth>(
          create: (context) => _firebaseAuth,
        ),
        RepositoryProvider<AuthDatasource>(
          create: (context) {
            final firebaseAuth = context.read<FirebaseAuth>();
            final analytics = context.read<FirebaseAnalytics>();
            return AuthDatasource(firebaseAuth, analytics);
          },
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) {
            final authDatasource = context.read<AuthDatasource>();
            return AuthRepository(authDatasource);
          },
        ),
        RepositoryProvider<AuthUserUsecase>(
          create: (context) {
            final authRepository = context.read<AuthRepository>();
            return AuthUserUsecase(authRepository);
          },
        )
      ];

  List<BlocProvider> get listBlocProvider => [
        BlocProvider<SigninBloc>(
          create: (context) {
            final authUserUsecase = context.read<AuthUserUsecase>();
            return SigninBloc(authUserUsecase);
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: listRepositoryProvider,
      child: MultiBlocProvider(
        providers: listBlocProvider,
        child: child,
      ),
    );
  }
}