import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/services/auth/register_service.dart';

class RegisterRepository {
  final RegisterService _service = RegisterService();

  Future<void> register(RegisterDataModel data) async {
    await _service.register(data);
  }
}
