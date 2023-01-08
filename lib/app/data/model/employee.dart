import 'package:objectbox/objectbox.dart';

@Entity()
class Employee {
  int id;
  final String firstName;
  final String lastName;
  final String username;

  Employee(
      {this.id = 0,
      required this.firstName,
      required this.lastName,
      required this.username});

  Employee copyWith({
    String? firstName,
    String? lastName,
    String? username,
  }) {
    return Employee(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
    );
  }
}

class EmployeeFormData {
  final String firstName;
  final String lastName;
  final String username;

  EmployeeFormData(
      {required this.firstName,
      required this.lastName,
      required this.username});

  EmployeeFormData.empty(
      {this.firstName = '', this.lastName = '', this.username = ''});

  EmployeeFormData copyWith({
    String? firstName,
    String? lastName,
    String? username,
  }) {
    return EmployeeFormData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
    );
  }
}
