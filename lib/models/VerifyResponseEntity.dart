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