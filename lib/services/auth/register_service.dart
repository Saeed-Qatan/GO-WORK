import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/repository/register_repository.dart';

class RegisterService {
  final RegisterRepository _repository = RegisterRepository();

  Future<void> register(RegisterDataModel data) async {
    await _repository.register(data);
  }
}
