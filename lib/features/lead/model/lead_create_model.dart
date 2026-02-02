class LeadCreateModel {
  final String source;
  final String status;
  final String name;
  final String? assigned;
  final String? tags;
  final String? value;
  final String? title;
  final String? designation;
  final String? email;
  final String? website;
  final String? phoneNumber;
  final String? alternatePhoneNumber;
  final String? company;
  final String? companyIndustry;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zip;
  final String? defaultLanguage;
  final String? description;
  final String? isPublic;
  final String? campaign;
  final String? interestedIn;

  LeadCreateModel({
    required this.source,
    required this.status,
    required this.name,
    this.assigned,
    this.tags,
    this.value,
    this.title,
    this.designation,
    this.email,
    this.website,
    this.phoneNumber,
    this.alternatePhoneNumber,
    this.company,
    this.companyIndustry,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zip,
    this.defaultLanguage,
    this.description,
    this.isPublic,
    this.campaign,
    this.interestedIn,
  });
}
