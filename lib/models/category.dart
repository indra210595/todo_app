import 'package:flutter/material.dart';

class Category{
  String id;
  String name;
  Color color;

  Category({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'color': color.value.toRadixString(16).padLeft(8, '0'),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map){
    return Category(
      id: map['id'],
      name: map['name'],
      color: Color(int.parse(map['color'], radix: 16)),
    );
  }
}