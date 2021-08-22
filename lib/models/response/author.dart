class AuthorDetail {
  var address;
  var authorId;
  var description;
  var designation;
  var education;
  var emailId;
  var image;
  var mobileNo;
  var name;
  var status;

  AuthorDetail(
      {this.address,
      this.authorId,
      this.description,
      this.designation,
      this.education,
      this.emailId,
      this.image,
      this.mobileNo,
      this.name,
      this.status});

  factory AuthorDetail.fromJson(Map<String, dynamic> json) {
    return AuthorDetail(
      address: json['address'] ?? "",
      authorId: json['author_id'],
      description: json['description'] ?? "",
      designation: json['designation'],
      education: json['education'],
      emailId: json['email_id'] != null ? json['email_id'] : null,
      image: json['image'],
      mobileNo: json['mobile_no'] != null ? json['mobile_no'] : null,
      name: json['name'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['author_id'] = this.authorId;
    data['description'] = this.description;
    data['designation'] = this.designation;
    data['education'] = this.education;
    data['image'] = this.image;
    data['name'] = this.name;
    data['status'] = this.status;
    if (this.emailId != null) {
      data['email_id'] = this.emailId;
    }
    if (this.mobileNo != null) {
      data['mobile_no'] = this.mobileNo;
    }
    return data;
  }
}
