import 'package:flutter/material.dart';

class Course {
  final String id;
  final String title;
  List<String> contents = [];
  final IconData icon;
  List<String> unit_ids = [];
  List<bool> units_completed_status = [];

  Course(
    this.id,
    this.title,
    this.contents,
    this.icon,
    this.unit_ids,
    this.units_completed_status,
  );
}
