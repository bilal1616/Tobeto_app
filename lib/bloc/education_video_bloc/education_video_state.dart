import 'package:tobeto_app/widget/home_widget/education_video.dart';

abstract class EducationVideoState {}

class EducationVideoInitial extends EducationVideoState {}

class EducationVideoLoading extends EducationVideoState {}

class EducationVideoLoaded extends EducationVideoState {
  final List<EducationVideo> videos;

  EducationVideoLoaded(this.videos);
}

class EducationVideoError extends EducationVideoState {
  final String message;

  EducationVideoError(this.message);
}
