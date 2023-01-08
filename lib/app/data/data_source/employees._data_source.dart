import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/data/model/employee.dart';
import 'package:pos_system/main.dart';
import 'package:pos_system/objectbox.g.dart';

import 'objectbox_database.dart';

final employeeDataSourceProvider = Provider<EmployeeDataSource>((ref) {
  return EmployeeDataSourceImpl(objectBox);
});

abstract class EmployeeDataSource {
  void create(Employee employee);
  Stream<List<Employee>> getAllEmployees();
  Employee? getEmployee(int id);
  Employee? getFirstEmployee();
  void removeEmployee(int id);
  void updateEmployee(Employee employeeUpdate);
}

class EmployeeDataSourceImpl implements EmployeeDataSource {
  final ObjectBoxDatabase db;

  EmployeeDataSourceImpl(this.db);
  @override
  void create(Employee employee) {
    db.employeeBox.put(employee);
  }

  @override
  void removeEmployee(int id) {
    db.employeeBox.remove(id);
  }

  @override
  Stream<List<Employee>> getAllEmployees() {
    final qBuilder = db.employeeBox.query();
    return qBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  void updateEmployee(Employee employeeUpdate) {
    final oldEmployeeData = getEmployee(employeeUpdate.id);
    if (oldEmployeeData == null) return;
    final updatedEmployee = oldEmployeeData.copyWith(
        firstName: employeeUpdate.firstName,
        lastName: employeeUpdate.lastName,
        username: employeeUpdate.username);
    db.employeeBox.put(updatedEmployee, mode: PutMode.update);
  }

  @override
  Employee? getEmployee(int id) {
    final employee = db.employeeBox.get(id);
    return employee;
  }

  @override
  Employee? getFirstEmployee() {
    final employee = db.employeeBox.query().build();
    return employee.findFirst();
  }
}
