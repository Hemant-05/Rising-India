part of 'banner_bloc.dart';

@immutable
sealed class BannerState {}

final class BannerInitial extends BannerState {}

final class BannerLoading extends BannerState {}

final class BannerLoaded extends BannerState {
  final List list;
  BannerLoaded(this.list);
}

final class BannerAdded extends BannerState {}

final class BannerDeleted extends BannerState {}

final class ErrorBanner extends BannerState {
  final String error;
  ErrorBanner(this.error);
}