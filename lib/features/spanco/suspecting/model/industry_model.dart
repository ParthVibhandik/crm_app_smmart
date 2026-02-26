class IndustryModel {
  bool? status;
  String? message;
  List<IndustryItem>? data;

  IndustryModel({this.status, this.message, this.data});

  IndustryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <IndustryItem>[];
      json['data'].forEach((v) {
        data!.add(IndustryItem.fromJson(v));
      });
    }
  }
}

class IndustryItem {
  String? id;
  String? name;

  IndustryItem({this.id, this.name});

  IndustryItem.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
  }
}
