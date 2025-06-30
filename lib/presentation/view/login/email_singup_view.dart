import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:story_genie/core/snackbar_util.dart';
import 'package:story_genie/core/validator.dart';
import 'package:story_genie/presentation/bloc/auth_bloc.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/presentation/bloc/form_validator_cubit.dart';
import 'package:story_genie/presentation/bloc/manage_user_profile_cubit.dart';
import 'package:story_genie/presentation/view/widgets/logo_heading_widget.dart';
import 'package:story_genie/presentation/view/widgets/no_internet_popup.dart';
import 'package:story_genie/presentation/view/widgets/rounded_button_widget.dart';

class EmailSignUpView extends StatefulWidget with Validator {
  const EmailSignUpView({super.key});

  @override
  State<EmailSignUpView> createState() => _EmailSignUpViewState();
}

class _EmailSignUpViewState extends State<EmailSignUpView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  late TextEditingController _passswordController;
  late TextEditingController _confirmpassswordController;
  double kidsAge = 4;

  final _loginFormKey = GlobalKey<FormState>();
  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passswordController = TextEditingController();
    _confirmpassswordController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthSignUpWithEmailAndPasswordSuccess) {
                  context.go('login/email-login');
                  showSnackBar(
                    context: context,
                    message: 'Verification email sent! Please verify and Login',
                    showAction: false,
                  );
                  BlocProvider.of<FirebaseAnalyticsCubit>(
                    context,
                  ).addEvent(eventName: 'recieved_email_singup_email');
                } else if (state is PhoneAuthError) {
                  //Show error message if any error occurs while verifying phone number and otp code
                  showSnackBar(
                    context: context,
                    message: state.error,
                    showAction: false,
                  );
                  BlocProvider.of<FirebaseAnalyticsCubit>(context).addEvent(
                    eventName: 'recieved_email_signup_error',
                    eventParams: {'error_message': state.error},
                  );
                } else if (state is AuthNoInternetError) {
                  if (context.canPop()) {
                    context.pop();
                  }
                  showNoInternetPopup(context: context);
                }
              },
              builder: (context, state) {
                return BlocSelector<
                  FormValidatorCubit,
                  FormValidatorState,
                  AutovalidateMode
                >(
                  bloc: FormValidatorCubit(),
                  selector: (state) => state.autovalidateMode,
                  builder: (context, AutovalidateMode autovalidateMode) {
                    return Form(
                      key: _loginFormKey,
                      autovalidateMode: autovalidateMode,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20.h,
                          horizontal: 20.w,
                        ),
                        child: Column(
                          children: [
                            const LogoHeader(),
                            TextFormField(
                              controller: _nameController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                label: Text('Name'),
                                hintText: 'Tony Stark',
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              validator: widget.validateEmail,
                              onChanged: FormValidatorCubit().updateEmail,
                              controller: _emailController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                label: Text('Email'),
                                hintText: 'ironman@gmail.com',
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            BlocConsumer<
                              ManageUserProfileCubit,
                              ManageUserProfileState
                            >(
                              listener: (context, state) {
                                if (state is AgeSliderUpdated) {
                                  kidsAge = state.age;
                                }
                              },
                              builder: (context, state) {
                                return Column(
                                  children: [
                                    Text('Kids age: ${kidsAge.toInt()}'),
                                    Slider(
                                      min: 1,
                                      max: 14,
                                      activeColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      value: kidsAge,
                                      onChanged: (value) {
                                        BlocProvider.of<ManageUserProfileCubit>(
                                          context,
                                        ).updateAgeSlider(value);
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              validator: widget.validatePassword,
                              onChanged: FormValidatorCubit().updatePassword,
                              controller: _passswordController,
                              obscureText: true,
                              style: Theme.of(context).textTheme.bodyLarge,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                label: Text('Password'),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              validator:
                                  (value) => widget.validateConfirmPassword(
                                    value,
                                    _passswordController.text,
                                  ),
                              onChanged:
                                  FormValidatorCubit().updateConfirmPassword,
                              controller: _confirmpassswordController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              obscureText: true,
                              keyboardType: TextInputType.text,

                              decoration: const InputDecoration(
                                label: Text('Confirm Password'),
                              ),
                              textInputAction: TextInputAction.done,
                            ),
                            SizedBox(height: 40.h),
                            RoundedButton(
                              title: 'Create Account',
                              titleTextStyle: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                if (_loginFormKey.currentState!.validate()) {
                                  BlocProvider.of<AuthBloc>(context).add(
                                    SignUpWithEmailAndPasswordEvent(
                                      email: _emailController.text,
                                      password: _passswordController.text,
                                      displayName: _nameController.text,
                                      age: kidsAge.toInt().toString(),
                                    ),
                                  );
                                  BlocProvider.of<FirebaseAnalyticsCubit>(
                                    context,
                                  ).addEvent(
                                    eventName: 'click_email_signup_button',
                                  );
                                } else {
                                  FormValidatorCubit().updateAutovalidateMode(
                                    AutovalidateMode.always,
                                  );
                                }
                              },
                              isLoading: state is AuthLoading,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Container(),
          ],
        ),
      ),
    );
  }
}
