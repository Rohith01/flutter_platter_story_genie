import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:story_genie/core/snackbar_util.dart';
import 'package:story_genie/core/validator.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/presentation/bloc/form_validator_cubit.dart';
import 'package:story_genie/presentation/bloc/manage_user_profile_cubit.dart';
import 'package:story_genie/presentation/view/widgets/rounded_button_widget.dart';

class EditProfileScreen extends StatefulWidget with Validator {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  double kidsAge = 4;
  final _editProfileFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    _nameController = TextEditingController();
    BlocProvider.of<ManageUserProfileCubit>(context).getUserProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Update Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocConsumer<ManageUserProfileCubit, ManageUserProfileState>(
          listener: (context, state) {
            if (state is GetUserProfileLoaded) {
              ScaffoldMessenger.of(context).clearSnackBars();
              _nameController.text = state.userProfile.name ?? '';
              kidsAge = double.parse(state.userProfile.kidsAge ?? '4');
            }
            if (state is AgeSliderUpdated) {
              kidsAge = state.age;
            }
            if (state is UpdateUserProfileLoaded) {
              showSnackBar(
                context: context,
                message: 'Profile updated successfully!',
                showAction: false,
              );
            }
          },
          builder: (context, state) {
            return Form(
              key: _editProfileFormKey,
              child: Column(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/image/avatar.jpg'),
                    radius: 50,
                  ),
                  const SizedBox(height: 60),
                  TextFormField(
                    validator: widget.validateName,
                    controller: _nameController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      label: Text('Name'),
                      hintText: 'Tony Stark',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 40),
                  Text('Kids age: ${kidsAge.toInt()}'),
                  Slider(
                    min: 1,
                    max: 14,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: kidsAge,
                    onChanged: (value) {
                      BlocProvider.of<ManageUserProfileCubit>(
                        context,
                      ).updateAgeSlider(value);
                    },
                  ),
                  const SizedBox(height: 40),
                  RoundedButton(
                    title: 'Update Profile',
                    titleTextStyle: Theme.of(context).textTheme.bodyLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      if (_editProfileFormKey.currentState!.validate()) {
                        BlocProvider.of<ManageUserProfileCubit>(
                          context,
                        ).updateUserProfile({
                          'kidsAge': kidsAge.toInt().toString(),
                          'name': _nameController.text,
                        });
                        BlocProvider.of<FirebaseAnalyticsCubit>(
                          context,
                        ).addEvent(eventName: 'click_email_signup_button');
                      } else {
                        FormValidatorCubit().updateAutovalidateMode(
                          AutovalidateMode.always,
                        );
                      }
                    },
                    isLoading: state is ManageUserProfileLoading,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
