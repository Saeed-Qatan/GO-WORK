import 'package:http/http.dart' as http;
import 'package:gowork/core/constants/api_constants.dart';
import '../model/auth/register_data_model.dart';

class RegisterRepository {
  final String endpoint = '${ApiConstants.baseUrl}${ApiConstants.register}';

  Future<void> register(RegisterDataModel dataModel) async {
    var request = http.MultipartRequest('POST', Uri.parse(endpoint));

    request.fields['firstName'] = dataModel.firstName;
    request.fields['midName'] = dataModel.fatherName;
    request.fields['lastName'] = dataModel.familyName;
    request.fields['email'] = dataModel.email;
    request.fields['phoneNumber'] = dataModel.phone;
    request.fields['Password'] = dataModel.password;
    request.fields['PasswordConfirmation'] = dataModel.confirmPassword;
    if (dataModel.interstedInCategoryId != null) {
      request.fields['interstedInCategoryId'] = dataModel.interstedInCategoryId
          .toString();
    }
    for (var skill in dataModel.skills) {
      request.fields['listOfSkills'] = skill;
    }

    if (dataModel.profilePhoto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'ProfilePhoto',
          dataModel.profilePhoto!.path,
        ),
      );
    }

    if (dataModel.cvFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('Resume', dataModel.cvFile!.path),
      );
    }

    var response = await request.send();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      var body = await response.stream.bytesToString();
      throw Exception('Error ${response.statusCode}: $body');
    }
  }
}
