import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/features/admin/services/image_services.dart';
part 'image_state.dart';


class ImageSelectionCubit extends Cubit<ImageSelectionState> {
  ImageSelectionCubit() : super(ImageSelectionState.initial());

  void setImageAtIndex(int index, File imageFile) {
    final newImages = List<File?>.from(state.images);
    newImages[index] = imageFile;
    emit(state.copyWith(images: newImages));
  }

  Future<List<String>> getImageUrl(String productName,List<File?> images) async {
    ImageServices imageServices = ImageServices();
    List<String> imageUrls = [];
    imageUrls = await imageServices.uploadImages(images,productName);
    return imageUrls;
  }


  void clearImages() {
    emit(ImageSelectionState.initial());
  }
}
