abstract class EducationVideoEvent {}

class FetchEducationVideos extends EducationVideoEvent {}

class RefreshEducationVideos extends EducationVideoEvent {}

class FilterEducationVideos extends EducationVideoEvent {
  final String filterCriteria;

  FilterEducationVideos(this.filterCriteria);
}

class SelectEducationVideo extends EducationVideoEvent {
  final String videoId;

  SelectEducationVideo(this.videoId);
}

class ClearSelectedEducationVideo extends EducationVideoEvent {}
