import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:story_genie/core/constants.dart';
import 'package:story_genie/presentation/bloc/firebase_analytics_cubit.dart';
import 'package:story_genie/presentation/bloc/get_stories_list_cubit.dart';

class EditorsChoiceStoriesListScreen extends StatefulWidget {
  const EditorsChoiceStoriesListScreen({super.key});

  @override
  State<EditorsChoiceStoriesListScreen> createState() =>
      _EditorsChoiceStoriesListScreenState();
}

class _EditorsChoiceStoriesListScreenState
    extends State<EditorsChoiceStoriesListScreen> {
  @override
  void initState() {
    BlocProvider.of<GetStoriesListCubit>(context).getEditorStories();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: BlocBuilder<GetStoriesListCubit, GetStoriesListState>(
        buildWhen:
            (previous, current) =>
                current is GetEditorStoriesListLoaded ||
                current is GetEditorStoriesListLoading,
        builder: (context, state) {
          if (state is GetEditorStoriesListLoaded) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.stories.length,

              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    BlocProvider.of<FirebaseAnalyticsCubit>(context).addEvent(
                      eventName: 'clicked_on_excuse_tile',
                      eventParams: {'excuse_desc': state.stories[index].title},
                    );
                    context.go('/story', extra: state.stories[index]);
                    BlocProvider.of<FirebaseAnalyticsCubit>(context).addEvent(
                      eventName: 'click_home_editor_story',
                      eventParams: {'storyId': state.stories[index].id!},
                    );
                  },
                  child: Card(
                    child: Container(
                      height: 320,
                      width: 300,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: pastelColorsList[index % 4],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 240,
                              width: 300,
                              child: Hero(
                                tag: 'feature-${state.stories[index].id}',
                                child: CachedNetworkImage(
                                  imageUrl: state.stories[index].featureImage,
                                  fit: BoxFit.cover,
                                  errorWidget:
                                      (context, url, error) =>
                                          Image.asset('assets/image/bg.png'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Hero(
                            tag: 'feature-${state.stories[index].title}',
                            child: Text(
                              state.stories[index].title,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (state is GetEditorStoriesListLoading) {
            return Column(
              children: [
                Lottie.network(
                  'https://lottie.host/30f2d62b-f016-4a75-a8ae-5f90dc0f215c/u5HxK1VhOf.json',
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
          }
          return Container();
        },
      ),
    );
  }
}
