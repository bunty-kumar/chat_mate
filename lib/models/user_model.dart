class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? profilePic;
  bool? userStatus;

  UserModel(
      {this.uid, this.fullName, this.email, this.profilePic, this.userStatus});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'profilePic': profilePic,
      'userStatus': userStatus,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      profilePic: map['profilePic'],
      userStatus: map['userStatus'],
    );
  }
}
