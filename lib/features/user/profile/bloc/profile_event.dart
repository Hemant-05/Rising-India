part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class OnProfileOpened extends ProfileEvent{}
