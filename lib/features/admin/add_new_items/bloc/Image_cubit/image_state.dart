part of 'image_cubit.dart';

class ImageSelectionState {
  final List<File?> images;
  ImageSelectionState({required this.images});

  factory ImageSelectionState.initial() {
    return ImageSelectionState(images: [null, null]);
  }

  ImageSelectionState copyWith({List<File?>? images}) {
    return ImageSelectionState(images: images ?? this.images);
  }
}



