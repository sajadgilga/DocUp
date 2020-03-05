
class LoginResponseEntity {
	final bool success;

	LoginResponseEntity(
			{this.success});

	factory LoginResponseEntity.fromJson(Map<String, dynamic> json) {
		return LoginResponseEntity(
			success: json['success'],
		);
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['success'] = this.success;
		return data;
	}
}