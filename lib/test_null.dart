import 'dart:convert';

class StatusModel {
  bool? _status;
  String? _message;
  StatusModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message']?.toString();
  }
  String? get message => _message;
}

void main() {
  String responseBody = '{"status":false,"message":"No data found!"}';
  StatusModel model = StatusModel.fromJson(jsonDecode(responseBody));
  print(model.message!.toUpperCase());
}
