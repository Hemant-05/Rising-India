import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/features/admin/services/image_services.dart';
import 'package:uuid/uuid.dart';

part 'banner_event.dart';
part 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BannerBloc() : super(BannerInitial()) {
    on<BannerEvent>((event, emit) {
    });

    on<LoadAllBannerEvent>((event, emit) async {
      emit(BannerLoading());
      try{
        List list = [];
        var data = await _firestore.collection('banner').get();
        for (var element in data.docs) {
          list.add(element.data());
        }
        emit(BannerLoaded(list));
      }catch(e){
        emit(ErrorBanner(e.toString()));
      }
    });

    on<DeleteBannerEvent>((event, emit) async {
      emit(BannerLoading());
      try{
        await _firestore.collection('banner').doc(event.id).delete();
        emit(BannerDeleted());
      }catch(e){
        emit(ErrorBanner(e.toString()));
      }
    });

    on<LoadBannerByIdEvent>((event, emit) async {
      emit(BannerLoading());
      try{
        var data = await _firestore.collection('banner').doc(event.id).get();
        emit(BannerLoaded([data.data()]));
      }catch(e){
        emit(ErrorBanner(e.toString()));
      }
    });

    on<AddBannerEvent>((event, emit) async {
      emit(BannerLoading());
      try{
        String bannerId = Uuid().v4();
        File image = event.image;
        ImageServices services = ImageServices();
        String imageUrl = await services.uploadBannerImage(image);
        await _firestore.collection('banner').doc(bannerId).set({
          'id': bannerId,
          'image': imageUrl,
        });
        emit(BannerAdded());
      }catch(e){
        emit(ErrorBanner(e.toString()));
      }
    });
  }
}
