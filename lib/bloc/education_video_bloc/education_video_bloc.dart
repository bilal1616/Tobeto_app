import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tobeto_app/bloc/education_video_bloc/education_video_event.dart';
import 'package:tobeto_app/bloc/education_video_bloc/education_video_state.dart';
import 'package:tobeto_app/repository/education_video_repository.dart';

class EducationVideoBloc
    extends Bloc<EducationVideoEvent, EducationVideoState> {
  final EducationVideoRepository repository;

  EducationVideoBloc({required this.repository})
      : super(EducationVideoInitial());

  Stream<EducationVideoState> mapEventToState(
    EducationVideoEvent event,
  ) async* {
    if (event is FetchEducationVideos) {
      yield* _mapFetchEducationVideosToState(event);
    }
  }

  Stream<EducationVideoState> _mapFetchEducationVideosToState(
      FetchEducationVideos event) async* {
    yield EducationVideoLoading();
    try {
      final videos = await repository.getEducationVideos();
      yield EducationVideoLoaded(videos);
    } catch (e) {
      yield EducationVideoError(e.toString());
    }
  }
}
