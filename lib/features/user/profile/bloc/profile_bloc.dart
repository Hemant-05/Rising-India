import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:raising_india/features/user/services/profile_services.dart';
import 'package:raising_india/models/user_model.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService _service = ProfileService();
  ProfileBloc() : super(ProfileInitial()) {
    on<OnProfileOpened> ((event,emit) async {
      emit(OnProfileLoading());
      try{
        AppUser? user = await _service.onLoadProfile();
        if(user != null){
          emit(OnProfileLoaded(user: user));
        }
      }catch (e) {
        emit(OnProfileLoadError(message: e.toString()));
      }
    });
  }
}
