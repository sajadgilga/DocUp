import 'package:Neuronio/blocs/FileBloc.dart';
import 'package:Neuronio/models/Panel.dart';
import 'package:Neuronio/models/Picture.dart';
import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class ScreeningRepository {
  ApiProvider _provider = ApiProvider();

  Future<Screening> getClinicScreeningPlan(int clinicId) async {
    final response =
    await _provider.get('api/screening/$clinicId/');
    return Screening.fromJson(response);
  }
}
