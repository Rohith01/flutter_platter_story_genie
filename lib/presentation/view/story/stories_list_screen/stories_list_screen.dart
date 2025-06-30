import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:story_genie/core/constants.dart';
import 'package:story_genie/core/string_extensions.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/presentation/bloc/get_stories_list_cubit.dart';
import 'package:story_genie/presentation/view/widgets/rounded_button_widget.dart';
import 'package:story_genie/services/models/story_character.dart';
import 'package:story_genie/services/models/story_model.dart';

class StoriesListScreen extends StatefulWidget {
  const StoriesListScreen({super.key, required this.character});
  final String character;

  @override
  State<StoriesListScreen> createState() => _StoriesListScreenState();
}

class _StoriesListScreenState extends State<StoriesListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<AiStory> stories = [];
  late bool isLastPage;
  late bool isFirstPage;

  AiStory? lastDoc;

  @override
  void initState() {
    isLastPage = false;
    isFirstPage = true;

    if (widget.character == 'my-stories') {
      characters.add(
        StoryCharacter(
          characterName: 'my-stories',
          characterImage: 'assets/image/my_stories.png',
        ),
      );
      BlocProvider.of<GetStoriesListCubit>(context).getMyStories(lastDoc);
    } else if (widget.character == 'saved-stories') {
      characters.add(
        StoryCharacter(
          characterName: 'saved-stories',
          characterImage: 'assets/image/saved.png',
        ),
      );
      BlocProvider.of<GetStoriesListCubit>(context).getSavedStories(lastDoc);
    } else {
      if (widget.character == 'all') {
        characters.add(
          StoryCharacter(
            characterName: 'all',
            characterImage: 'assets/image/avatar.jpg',
          ),
        );
      }
      BlocProvider.of<GetStoriesListCubit>(
        context,
      ).getStories(widget.character, lastDoc);
    }
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLastPage) {
      isFirstPage = false;
      BlocProvider.of<GetStoriesListCubit>(
        context,
      ).getStories(widget.character, lastDoc);
    }
  }

  @override
  void dispose() {
    if (characters.length > 7) {
      characters.removeLast();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              height: 210.h,
              padding: EdgeInsets.only(left: 20.w, top: 20.h, right: 20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
                color: Theme.of(context).colorScheme.primary,
                image: const DecorationImage(
                  image: AssetImage('assets/image/cover.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withAlpha(100),
                    blurRadius: 5.0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          GoRouter.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Hero(
                    tag: widget.character,
                    child: Image.asset(
                      characters
                          .firstWhere(
                            (element) =>
                                element.characterName.toLowerCase() ==
                                widget.character.toLowerCase(),
                          )
                          .characterImage,
                      height: 100.h,
                    ),
                  ),
                  Center(
                    child: Text(
                      (widget.character == 'my-stories')
                          ? 'My Stories'
                          : (widget.character == 'saved-stories')
                          ? 'Saved Stories'
                          : widget.character.toCapitalized,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                child: BlocConsumer<GetStoriesListCubit, GetStoriesListState>(
                  listener: (context, state) {
                    if (state is GetStoriesListLoaded) {
                      stories.addAll(state.stories);
                      if (stories.isNotEmpty) {
                        lastDoc = stories.last;
                      }
                      isLastPage = state.isLastPage;
                    }
                  },
                  builder: (context, state) {
                    if (state is GetStoriesListLoading && isFirstPage) {
                      return Column(
                        children: [
                          Lottie.network(
                            'https://lottie.host/3fa5105b-7bc7-46ae-b0ad-e5e0fdbb1429/S54upxfnli.json',
                            errorBuilder: (context, error, stackTrace) {
                              return const CircularProgressIndicator();
                            },
                          ),
                          Text(
                            'Loading stories...',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      );
                    } else if (state is GetStoriesListError) {
                      return Column(
                        children: [
                          Text(
                            'Unable fetch stories',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      );
                    }

                    if (stories.isEmpty) {
                      return SizedBox(
                        height: 300.h,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'There are no stories here',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            SizedBox(height: 20.h),
                            RoundedButton(
                              isLoading: false,
                              title: 'Generate Story',
                              width: 200.w,
                              titleTextStyle: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.copyWith(color: kPrimary),
                              onTap: () {
                                context.go('/generate-story');
                                BlocProvider.of<FirebaseAnalyticsCubit>(
                                  context,
                                ).addEvent(
                                  eventName:
                                      'click_storylist_generate_story_button',
                                  eventParams: {
                                    'stories_list': widget.character,
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stories.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            context.push('/story', extra: stories[index]);
                            BlocProvider.of<FirebaseAnalyticsCubit>(
                              context,
                            ).addEvent(
                              eventName: 'click_storylist_story_tile',
                              eventParams: {
                                'storyid': stories[index].id!,
                                'stories_list': widget.character,
                              },
                            );
                          },
                          child: Container(
                            height: 90.h,
                            width: 300.w,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 15,
                            ),

                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: pastelColorsList[index % 4],
                            ),
                            child: SizedBox(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const Spacer(),
                                  Text(
                                    stories[index].title,
                                    maxLines: 2,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Click to read the story',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(color: colorsList[index % 4]),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
