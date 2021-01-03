import 'package:string_similarity/string_similarity.dart';

class SearchResult implements Comparable {
  String itemKey;
  Map itemValue;
  double similarity;

  SearchResult(this.itemKey, this.itemValue, String searchQuery) {
    String name = itemValue['displayName'];
    similarity = name.similarityTo(searchQuery);
  }

  @override
  int compareTo(other) {
    if (other.similarity > similarity)
      return 1;
    else if (other.similarity < similarity)
      return -1;
    else
      return 0;
  }
}
