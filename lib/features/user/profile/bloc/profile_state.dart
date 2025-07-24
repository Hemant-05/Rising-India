part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class OnProfileLoading extends ProfileState{}

final class OnProfileLoaded extends ProfileState{
  final AppUser? user;
  OnProfileLoaded({required this.user});
}

final class OnProfileLoadError extends ProfileState{
  final String message;
  OnProfileLoadError({required this.message});
}