import 'package:algoliasearch/algoliasearch.dart';
import 'package:story_genie/services/models/story_model.dart';

class SearchStoriesRepositoryImpl implements SearchStoriesRepository {
  SearchStoriesRepositoryImpl(this.client);
  final SearchClient client;

  @override
  Future<List<AiStory>> searchStories(String query) async {
    final List<AiStory> storiesList = [];

    final response = await client.searchForHits(
      requests: [
        SearchForHits(indexName: 'stories', query: query, hitsPerPage: 10),
      ],
    );
    response.toList().first.hits.forEach((hit) {
      final storyData = hit as Map<String, dynamic>;
      storiesList.add(AiStory.fromJson(storyData));
    });
    return storiesList;
  }
}

abstract class SearchStoriesRepository {
  Future<List<AiStory>> searchStories(String searchTerm);
}
