import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:story_genie/core/constants.dart';
import 'package:story_genie/core/parse_bold_text.dart';
import 'package:story_genie/core/snackbar_util.dart';
import 'package:story_genie/core/string_extensions.dart';
import 'package:story_genie/presentation/bloc/add_to_saved_stories_cubit.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/services/models/story_model.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, required this.story});
  final AiStory story;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  bool isSaved = false;

  @override
  void initState() {
    isSaved = widget.story.isSaved ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.h,
            collapsedHeight: 60,
            centerTitle: false,
            pinned: true,
            title: Hero(
              tag: 'feature-${widget.story.title}',
              child: Text(
                widget.story.title,
                style: Theme.of(
                  parentContext,
                ).textTheme.titleLarge!.copyWith(fontSize: 16.sp),
              ),
            ),
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                GoRouter.of(parentContext).pop();
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'feature-${widget.story.id}',
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [Colors.transparent, Colors.black],
                    ).createShader(
                      Rect.fromLTRB(0, 0, rect.width, rect.height),
                    );
                  },
                  blendMode: BlendMode.dstIn,
                  child: CachedNetworkImage(
                    imageUrl: widget.story.featureImage,
                    fit: BoxFit.cover,
                    errorWidget:
                        (context, url, error) =>
                            Image.asset('assets/image/bg.png'),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(parentContext).size.height,
              ),
              child: Material(
                elevation: 7,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: parseBoldText(
                            widget.story.story,
                            Theme.of(parentContext).textTheme.bodyLarge!,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          BlocConsumer<
                            AddToSavedStoriesCubit,
                            AddToSavedStoriesState
                          >(
                            listener: (context, savedStoriesState) {
                              if (savedStoriesState is SavedStoryLoaded) {
                                isSaved = true;
                                showSnackBar(
                                  context: context,
                                  message: 'Story saved successfully',
                                  showAction: false,
                                );
                              }
                              if (savedStoriesState
                                  is RemovedSavedStoryLoaded) {
                                isSaved = false;
                                showSnackBar(
                                  context: context,
                                  message: 'Story removed from saved stories',
                                  showAction: false,
                                );
                              }
                              if (savedStoriesState is AddToSavedStoriesError) {
                                showSnackBar(
                                  context: context,
                                  message: 'Unable to perform action',
                                  showAction: false,
                                );
                              }
                            },
                            builder: (context, state) {
                              return InkWell(
                                onTap: () {
                                  !isSaved
                                      ? BlocProvider.of<AddToSavedStoriesCubit>(
                                        context,
                                      ).addToSavedStories(
                                        docId: widget.story.id,
                                        isEditorStory:
                                            widget.story.userName == 'Editor',
                                      )
                                      : BlocProvider.of<AddToSavedStoriesCubit>(
                                        context,
                                      ).removeFromSavedStories(
                                        docId: widget.story.id,
                                        isEditorStory:
                                            widget.story.userName == 'Editor',
                                      );
                                  BlocProvider.of<FirebaseAnalyticsCubit>(
                                    context,
                                  ).addEvent(
                                    eventName: 'click_storydetail_save_story',
                                    eventParams: {
                                      'storyId': widget.story.id!,
                                      'isAlreadySaved':
                                          widget.story.isSaved.toString(),
                                    },
                                  );
                                },
                                child: Container(
                                  height: 50.h,
                                  width: 50.w,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.r),
                                    border: Border.all(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child:
                                      state is AddToSavedStoriesLoading
                                          ? CircularProgressIndicator(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                          )
                                          : Icon(
                                            isSaved
                                                ? Icons.bookmark_added
                                                : Icons.bookmark_add_outlined,
                                            size: 40.h,
                                          ),
                                ),
                              );
                            },
                          ),
                          InkWell(
                            onTap: () {
                              context.go(
                                '/stories-list/${widget.story.character.toLowerCase()}',
                              );
                              BlocProvider.of<FirebaseAnalyticsCubit>(
                                context,
                              ).addEvent(
                                eventName: 'click_storydetail_character_button',
                                eventParams: {
                                  'storyId': widget.story.id!,
                                  'character': widget.story.character,
                                },
                              );
                            },
                            child: Container(
                              height: 50.h,
                              width: 150.w,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: AssetImage(
                                      characters
                                          .firstWhere(
                                            (element) =>
                                                element.characterName
                                                    .toLowerCase() ==
                                                widget.story.character
                                                    .toLowerCase(),
                                          )
                                          .characterImage,
                                    ),
                                  ),
                                  Text(
                                    widget.story.character.toCapitalized,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Share.share(
                                '${widget.story.story}\nGenerated by Story Genie AI app',
                              );
                              BlocProvider.of<FirebaseAnalyticsCubit>(
                                context,
                              ).addEvent(
                                eventName: 'click_storydetail_share_button',
                                eventParams: {'storyId': widget.story.id!},
                              );
                            },
                            child: Container(
                              height: 50.h,
                              width: 50.w,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.share_rounded, size: 40.h),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
