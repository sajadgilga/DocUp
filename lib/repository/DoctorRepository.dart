import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/models/DoctorResponseEntity.dart';
import 'package:docup/models/TicketResponseEntity.dart';
import 'package:docup/networking/ApiProvider.dart';

class DoctorRepository {
  ApiProvider _provider = ApiProvider();

  Future<DoctorEntity> getDoctor(int doctorId) async {
    final response =
        await _provider.get("api/doctors/" + doctorId.toString() + "/");
    return DoctorEntity.fromJson(response);
  }

  Future<TicketEntity> sendTicket(int doctorId) async {
    final response = await _provider.post("api/send-ticket/",
        body: {"doctor": doctorId, "patient_message": "سلام"});
    return TicketEntity.fromJson(response);
  }
}
