import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:story_genie/core/constants.dart';
import 'package:story_genie/core/snackbar_util.dart';
import 'package:story_genie/core/validator.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/presentation/bloc/generate_story_cubit.dart';
import 'package:story_genie/presentation/bloc/manage_credits_cubit.dart';
import 'package:story_genie/presentation/bloc/manage_user_profile_cubit.dart';
import 'package:story_genie/presentation/view/widgets/creative_credits_widget.dart';
import 'package:story_genie/presentation/view/widgets/no_internet_popup.dart';
import 'package:story_genie/presentation/view/widgets/rounded_button_widget.dart';
import 'package:story_genie/services/models/story_model.dart';

class GenerateStoryFormView extends StatefulWidget with Validator {
  const GenerateStoryFormView({super.key});

  @override
  State<GenerateStoryFormView> createState() => _GenerateStoryFormViewState();
}

class _GenerateStoryFormViewState extends State<GenerateStoryFormView> {
  late TextEditingController _additionalElementsController;

  String? selectedCharacter;
  String selectedLanguage = 'English';
  String creativeCredits = '0';
  AiStory? story;

  @override
  void initState() {
    _additionalElementsController = TextEditingController();
    BlocProvider.of<ManageCreditsCubit>(context).getCreditDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageCreditsCubit, ManageCreditsState>(
      listener: (context, state) {
        if (state is GetCreditDetailsLoaded) {
          creativeCredits = state.credits;
        }
        if (state is DeductCreditsLoaded) {
          BlocProvider.of<ManageUserProfileCubit>(context).getUserProfile();
          context.go('/story', extra: story);
        }
        if (state is ManageCreditsError) {
          showSnackBar(
            context: context,
            message: 'Unable to generate story, Please try later',
            showAction: false,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Generate Story'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                GoRouter.of(context).pop();
              },
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: CreativeCreditsWidget(credits: creativeCredits),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            child: BlocConsumer<GenerateStoryCubit, GenerateStoryState>(
              listener: (context, state) {
                if (state is GenerateStoryLoaded) {
                  story = state.story;
                  BlocProvider.of<ManageCreditsCubit>(
                    context,
                  ).deductCredits(creativeCredits);
                }
                if (state is SelectCharacterLoaded) {
                  selectedCharacter = state.character;
                }
                if (state is GenerateStoryNoInternetError) {
                  showNoInternetPopup(context: context);
                }
                if (state is SelectLanguageLoaded) {
                  selectedLanguage = state.language;
                }
                if (state is GenerateStoryError) {
                  showSnackBar(
                    context: context,
                    message: 'Unable to generate story now, Please try later',
                    showAction: false,
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    SizedBox(
                      height: 200.h,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: characters.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              BlocProvider.of<GenerateStoryCubit>(
                                context,
                              ).selectCharacter(
                                characters[index].characterName,
                              );
                            },
                            child: Container(
                              height: 150.h,
                              width: 150.w,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color:
                                      selectedCharacter ==
                                              characters[index].characterName
                                          ? kSecondary
                                          : Colors.transparent,
                                  width: 5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Hero(
                                tag: characters[index].characterName,
                                child: Image.asset(
                                  characters[index].characterImage,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    TextFormField(
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      controller: _additionalElementsController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      keyboardType: TextInputType.emailAddress,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        label: Text('Additional Info'),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 20.h),
                    DropdownButton<String>(
                      value: selectedLanguage,
                      items:
                          <String>[
                            'English',
                            'Hindi',
                            'Tamil',
                            'Telugu',
                            'Bengali',
                            'Kannada',
                            'Malayalam',
                            'Mandarin Chinese',
                            'Spanish',
                            'French',
                            'German',
                            'Japanese',
                            'Vietnamese',
                            'Portuguese',
                            'Indonesian',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        BlocProvider.of<GenerateStoryCubit>(
                          context,
                        ).selectLanguage(newValue ?? selectedLanguage);
                      },
                      hint: Text(
                        'Choose Language',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                    RoundedButton(
                      isLoading: state is GenerateStoryLoading,
                      title: 'Generate Story',
                      width: 200.w,
                      titleTextStyle: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(color: kPrimary),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        if (selectedCharacter != null) {
                          if (int.parse(creativeCredits) > 0) {
                            BlocProvider.of<GenerateStoryCubit>(
                              context,
                            ).generateStory(
                              promptDetails: {
                                'character': selectedCharacter ?? 'Animal',
                                'additionalInfo':
                                    _additionalElementsController.text,
                                'language': selectedLanguage,
                              },
                            );
                          } else {
                            showSnackBar(
                              context: context,
                              message:
                                  'You dont have enough credits to generate new story',
                              showAction: false,
                            );
                          }
                          BlocProvider.of<FirebaseAnalyticsCubit>(
                            context,
                          ).addEvent(
                            eventName: 'click_generatestory_generate_button',
                            eventParams: {
                              'character': selectedCharacter ?? 'Animal',
                              'additionalInfo':
                                  _additionalElementsController.text,
                              'language': selectedLanguage,
                              'enoughCredits':
                                  '${int.parse(creativeCredits) > 0}',
                            },
                          );
                        } else {
                          showSnackBar(
                            context: context,
                            message: 'Please select a character to continue',
                            showAction: false,
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
