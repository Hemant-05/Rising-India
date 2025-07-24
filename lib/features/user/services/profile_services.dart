import 'package:raising_india/features/auth/services/auth_service.dart';
import 'package:raising_india/models/user_model.dart';

class ProfileService{
  Future<AppUser?> onLoadProfile()async{
    AppUser? user;
    user = await AuthService().getCurrentUser();
    return user;
  }
}