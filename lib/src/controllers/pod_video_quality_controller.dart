part of 'pod_getx_video_controller.dart';

class _PodVideoQualityController extends _PodVideoController {
  ///
  int? playingVideoQuality;

  ///vimeo all quality urls
  List<VideoQalityUrls> videoQalityUrls = [];
  late String _videoQualityUrl;

  ///invokes callback from external controller
  VoidCallback? onVimeoVideoQualityChanged;

  ///*vimeo player configs
  ///
  ///get all  `quality urls`




  void sortQualityVideoUrls(
    List<VideoQalityUrls>? urls,
  ) {
    final _urls = urls;

    ///has issues with 240p
   // _urls?.removeWhere((element) => element.quality == 240);

    ///has issues with 144p in web
    if (kIsWeb) {
      _urls?.removeWhere((element) => element.quality == 144);
    }

    ///sort
    _urls?.sort((a, b) => a.quality.compareTo(b.quality));

    ///
    videoQalityUrls = _urls ?? [];
  }

  ///get vimeo quality `ex: 1080p` url
  VideoQalityUrls getQualityUrl(int quality) {
    return videoQalityUrls.firstWhere(
      (element) => element.quality == quality,
      orElse: () => videoQalityUrls.first,
    );
  }

  Future<String> getUrlFromVideoQualityUrls({
    required List<int> qualityList,
    required List<VideoQalityUrls> videoUrls,
  }) async {
    sortQualityVideoUrls(videoUrls);
    if (videoQalityUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }

    final fallback = videoQalityUrls[0];
    VideoQalityUrls? urlWithQuality;
    for (final quality in qualityList) {
      urlWithQuality = videoQalityUrls.firstWhere(
        (url) => url.quality == quality,
        orElse: () => fallback,
      );

      if (urlWithQuality != fallback) {
        break;
      }
    }

    urlWithQuality ??= fallback;
    _videoQualityUrl = urlWithQuality.url;
    playingVideoQuality = urlWithQuality.quality;
    return _videoQualityUrl;
  }

  

  Future<void> changeVideoQuality(int? quality) async {
    if (videoQalityUrls.isEmpty) {
      throw Exception('videoQuality cannot be empty');
    }
    if (playingVideoQuality != quality) {
      _videoQualityUrl = videoQalityUrls
          .where((element) => element.quality == quality)
          .first
          .url;
      podLog(_videoQualityUrl);
      playingVideoQuality = quality;
      _videoCtr?.removeListener(videoListner);
      podVideoStateChanger(PodVideoState.paused);
      podVideoStateChanger(PodVideoState.loading);
      playingVideoUrl = _videoQualityUrl;
      _videoCtr = VideoPlayerController.network(_videoQualityUrl);
      await _videoCtr?.initialize();
      _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      _videoCtr?.addListener(videoListner);
      await _videoCtr?.seekTo(_videoPosition);
      setVideoPlayBack(_currentPaybackSpeed);
      podVideoStateChanger(PodVideoState.playing);
      onVimeoVideoQualityChanged?.call();
      update();
      update(['update-all']);
    }
  }
}
