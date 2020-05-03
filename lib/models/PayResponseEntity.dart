class PayResponseEntity {
	final int status;
	final String token;

	PayResponseEntity(
			{this.status, this.token});

	factory PayResponseEntity.fromJson(Map<String, dynamic> json) {
		return PayResponseEntity(
			status: json['status'],
			token: json['token'],
		);
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['status'] = this.status;
		data['token'] = this.token;
		return data;
	}
}