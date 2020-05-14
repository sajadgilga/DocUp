
class SignUpResponseEntity {
	final bool success;

	SignUpResponseEntity(
			{this.success});

	factory SignUpResponseEntity.fromJson(Map<String, dynamic> json) {
		return SignUpResponseEntity(
			success: json['success'],
		);
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['success'] = this.success;
		return data;
	}
}

class VerifyResponseEntity {
	final String token;

	VerifyResponseEntity(
			{this.token});

	factory VerifyResponseEntity.fromJson(Map<String, dynamic> json) {
		return VerifyResponseEntity(
			token: json['token'],
		);
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['token'] = this.token;
		return data;
	}
}