// To parse this JSON data, do
//
//     final userProfile = userProfileFromJson(jsonString);

import 'dart:convert';

UserProfile userProfileFromJson(String str) =>
    UserProfile.fromJson(json.decode(str));

String userProfileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
  UserProfile({this.name, this.phone, this.email, this.kidsAge, this.credits});

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'],
    phone: json['phone'],
    email: json['email'],
    kidsAge: json['kidsAge'],
    credits: json['credits'],
  );

  String? name;
  String? phone;
  String? email;
  String? kidsAge;
  String? credits;

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'kidsAge': kidsAge,
    'credits': credits,
  };
}
