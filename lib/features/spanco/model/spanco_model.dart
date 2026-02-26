class SpancoModel {
  bool? status;
  String? message;
  List<SpancoItemModel>? data;

  SpancoModel({this.status, this.message, this.data});

  SpancoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SpancoItemModel>[];
      json['data'].forEach((v) {
        data!.add(SpancoItemModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SpancoItemModel {
  String? id;
  String? name;
  String? company;
  String? companyIndustry;
  String? phonenumber;
  String? email;
  String? source;
  String? assigned;
  String? city;
  String? dateadded;
  String? opportunityId;

  SpancoItemModel(
      {this.id,
      this.name,
      this.company,
      this.companyIndustry,
      this.phonenumber,
      this.email,
      this.source,
      this.assigned,
      this.city,
      this.dateadded,
      this.opportunityId});

  SpancoItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    company = json['company']?.toString();
    companyIndustry = json['company_industry']?.toString();
    phonenumber = json['phonenumber']?.toString();
    email = json['email']?.toString();
    source = json['source']?.toString();
    assigned = json['assigned']?.toString();
    city = json['city']?.toString();
    dateadded = json['dateadded']?.toString();
    opportunityId = json['opportunity_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['company'] = company;
    data['company_industry'] = companyIndustry;
    data['phonenumber'] = phonenumber;
    data['email'] = email;
    data['source'] = source;
    data['assigned'] = assigned;
    data['city'] = city;
    data['dateadded'] = dateadded;
    data['opportunity_id'] = opportunityId;
    return data;
  }
}
