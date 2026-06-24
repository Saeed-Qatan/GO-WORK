import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/repository/register_repository.dart';

class RegisterService {
  final RegisterRepository _repo = RegisterRepository();

  Future<void> register(RegisterDataModel data) {
    return _repo.register(data);
  }
}
