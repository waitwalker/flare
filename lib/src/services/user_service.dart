import 'package:flare/src/repositories/user_repository.dart';

class UserService {
  final UserRepository _userRepository = UserRepository();

  Future<dynamic> getUserInfo(int id) async {
    return _userRepository.findUserByID(id);
  }
}
