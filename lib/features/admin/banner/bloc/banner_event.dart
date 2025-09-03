part of 'banner_bloc.dart';

@immutable
sealed class BannerEvent {}

class LoadAllBannerEvent extends BannerEvent{}

class DeleteBannerEvent extends BannerEvent{
  final String id;
  DeleteBannerEvent(this.id);
}

class LoadBannerByIdEvent extends BannerEvent{
  final String id;
  LoadBannerByIdEvent(this.id);
}

class AddBannerEvent extends BannerEvent{
  final File image;
  AddBannerEvent(this.image);
}

