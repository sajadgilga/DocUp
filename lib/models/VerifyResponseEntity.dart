
class VerifyResponseEntity {
	final bool success;

	VerifyResponseEntity(
			{this.success});

	factory VerifyResponseEntity.fromJson(Map<String, dynamic> json) {
		return VerifyResponseEntity(
			success: json['success'],
		);
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['success'] = this.success;
		return data;
	}
}