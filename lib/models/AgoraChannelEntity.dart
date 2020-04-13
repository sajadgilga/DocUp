class AgoraChannel {
  String channelName;

  AgoraChannel({this.channelName});

  AgoraChannel.fromJson(Map<String, dynamic> json) {
    channelName = json['channel_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['channel_name'] = this.channelName;
    return data;
  }
}