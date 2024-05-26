import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class FlickVideoSpeedControlSliderWidget extends StatefulWidget {
  final FlickManager flickManager;

  const FlickVideoSpeedControlSliderWidget(
      {super.key, required this.flickManager});

  @override
  _FlickVideoSpeedControlSliderWidgetState createState() =>
      _FlickVideoSpeedControlSliderWidgetState();
}

class _FlickVideoSpeedControlSliderWidgetState
    extends State<FlickVideoSpeedControlSliderWidget> {
  double _sliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return SfSlider(
      min: 0.0,
      max: 2.0,
      value: widget.flickManager.flickVideoManager?.videoPlayerValue
              ?.playbackSpeed ??
          1.0,
      interval: 0.5,
      showTicks: true,
      showLabels: true,
      enableTooltip: true,
      minorTicksPerInterval: 0,
      // Adjust this for more minor ticks between intervals
      onChanged: (dynamic newValue) {
        widget.flickManager.flickControlManager?.setPlaybackSpeed(newValue);
        setState(() {
          _sliderValue = newValue;
        });
      },
    );
  }
}