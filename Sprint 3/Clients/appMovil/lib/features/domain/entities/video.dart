class Video {
  final int id;
  final String title;
  final String description;
  final String duration;
  final String thumbnail;
  /*final int categoryId;
  final int ageId;
  final int seriesId;*/

  Video(
      {required this.id,
      required this.title,
      required this.description,
      required this.duration,
      required this.thumbnail
      /*required this.categoryId,
    required this.ageId,
    required this.seriesId,*/
      });
}
