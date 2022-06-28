import 'package:desafio_mobile/src/presentation/widgets/custom_form_text_field_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../shared/data_struct/authentication_user_state.dart';
import '../bloc/signin_bloc.dart';
import '../bloc/signin_event.dart';
import '../bloc/signin_state.dart';
import 'custom_form.dart';
import 'custom_button.dart';
import 'custom_form_text_field_email.dart';

class SigninForm extends StatefulWidget {
  final String? email;
  final String? password;

  const SigninForm({
    Key? key,
    this.email,
    this.password,
  }) : super(key: key);

  @override
  State<SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  bool isvalid = false;
  @override
  Widget build(BuildContext context) {
    var bloc = Modular.get<SigninBloc>();
    return BlocBuilder<SigninBloc, SigninState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is SigninStateAuthFinished) {
          return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
        } else {
          return CustomForm(
            autovalidateMode: AutovalidateMode.disabled,
            builder: (
              BuildContext context,
              Map<String, dynamic> Function() getValidatedFormState,
            ) =>
                Column(
              children: [
                CustomFormTextFieldEmail(
                  name: 'email',
                  label: 'E-mail',
                  hint: 'E-mail',
                  initialValue: widget.email,
                  onChanged: (_) {
                    setState(
                      () {
                        isvalid = getValidatedFormState()['isValid'];
                      },
                    );
                  },
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Digite seu e-mail',
                    )
                  ],
                ),
                const SizedBox(height: 15),
                CustomFormTextFieldPassword(
                  name: 'password',
                  label: 'Senha',
                  hint: 'Senha',
                  onChanged: (_) {
                    setState(
                      () {
                        isvalid = getValidatedFormState()['isValid'];
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                if (state is SigninLoadingState)
                  const CircularProgressIndicator()
                else
                  CustomButton(
                    text: const Text(
                      'Entrar',
                      style: TextStyle(
                        color: Color(0XFFEBF7FF),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    colorCode: 0xFF2047E0,
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    borderRadius: 16,
                    onPressed: () async {
                      AuthenticationUserForm signinForm = AuthenticationUserForm.fromFormFields(
                        getValidatedFormState(),
                      );
                      if (isvalid) {
                        bloc.add(
                          SubmitAuthForm(
                            username: signinForm.username!,
                            password: signinForm.password!,
                          ),
                        );
                      }
                    },
                  ),
                const SizedBox(height: 15),
                if (state is SigninStateAuthFailure)
                  Text(
                    state.authException.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  )
              ],
            ),
          );
        }
      },
    );
  }
}