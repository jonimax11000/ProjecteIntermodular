class Video {
  final int id;
  final String titol;
  final String videoURL;
  final String thumbnailURL;
  final String duracio;
  /*final int categoryId;
  final int ageId;
  final int seriesId;*/

  Video(
      {required this.id,
      required this.titol,
      required this.videoURL,
      required this.thumbnailURL,
      required this.duracio
      /*required this.categoryId,
    required this.ageId,
    required this.seriesId,*/
      });
}
