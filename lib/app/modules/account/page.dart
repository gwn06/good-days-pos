import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/app/core/values/font.dart';
import 'package:pos_system/app/core/values/strings.dart';
import 'package:pos_system/app/data/data_source/employees._data_source.dart';
import 'package:pos_system/app/data/model/employee.dart';
import 'package:pos_system/app/core/values/extensions.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  late final EmployeeDataSource _employeeDataSource;
  late Stream<List<Employee>> _employees;
  var _formData = EmployeeFormData.empty();
  @override
  void initState() {
    _employeeDataSource = ref.read(employeeDataSourceProvider);
    _employees = _employeeDataSource.getAllEmployees();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text(AppStrings.employees)),
      content: Row(children: [
        Expanded(
            flex: 2,
            child: Column(
              children: [
                StreamBuilder(
                    stream: _employees,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final employees = snapshot.data as List<Employee>;
                        final source = EmployeeData(
                            employees: employees,
                            employeeBottomSheet: _showEmployeeBottomSheet);
                        return FractionallySizedBox(
                          widthFactor: 0.7,
                          child: material.PaginatedDataTable(
                              rowsPerPage: 8,
                              columns: const [
                                material.DataColumn(
                                    label: Text(
                                  'ID',
                                  style: TextStyle(
                                      fontWeight: FontWeightManager.semiBold),
                                )),
                                material.DataColumn(
                                    label: Text(
                                  'NAME',
                                  style: TextStyle(
                                      fontWeight: FontWeightManager.semiBold),
                                )),
                                material.DataColumn(
                                    label: Text(
                                  'USERNAME',
                                  style: TextStyle(
                                      fontWeight: FontWeightManager.semiBold),
                                )),
                              ],
                              source: source),
                        );
                      } else {
                        return const ProgressBar();
                      }
                    }),
              ],
            )),
        Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: _buildNewEmployeeForm(
                  formKey: _formKey,
                  callback: _submitForm,
                  title: 'New Employee'),
            ))
      ]),
    );
  }

  Form _buildNewEmployeeForm(
      {required GlobalKey<FormState> formKey,
      Employee? employee,
      bool hasButton = true,
      bool formFieldsEnabled = true,
      required void Function() callback,
      required String title}) {
    return Form(
        key: formKey,
        child: Column(
          children: [
            _buildHeader(title: title),
            const SizedBox(height: 10),
            TextFormBox(
              initialValue: employee?.firstName,
              enabled: formFieldsEnabled,
              header: 'First Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter first name';
                }
                return null;
              },
              onSaved: (value) {
                _formData = _formData.copyWith(firstName: value?.toTitleCase());
              },
            ),
            TextFormBox(
              header: 'Last Name',
              enabled: formFieldsEnabled,
              initialValue: employee?.lastName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter last name';
                }
                return null;
              },
              onSaved: (value) {
                _formData = _formData.copyWith(lastName: value?.toTitleCase());
              },
            ),
            TextFormBox(
              header: 'Username',
              initialValue: employee?.username,
              enabled: formFieldsEnabled,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter username';
                }
                return null;
              },
              onSaved: (value) {
                _formData = _formData.copyWith(username: value?.toTitleCase());
              },
            ),
            if (hasButton)
              FilledButton(
                  onPressed: _submitForm, child: const Text('Create Account'))
          ],
        ));
  }

  Text _buildHeader({required String title}) {
    return Text(
      title,
      style: const TextStyle(
          fontWeight: FontWeightManager.bold, fontSize: FontSize.s22),
    );
  }

  void _showRemoveEmployeeDialog(Employee employee) {
    final username = employee.username;
    showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text('Remove Employee'),
            content: Row(
              children: [
                const Text('Are you sure you want to remove user '),
                Text(
                  '$username?',
                  style: const TextStyle(fontWeight: FontWeightManager.bold),
                ),
              ],
            ),
            actions: [
              Button(
                child: const Text('NO'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FilledButton(
                child: const Text('YES'),
                onPressed: () {
                  _employeeDataSource.removeEmployee(employee.id);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void _showEmployeeBottomSheet(Employee employee) {
    final formKey = GlobalKey<FormState>();
    bool formFieldsEnabled = false;
    showBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: ((context, setSheetState) => BottomSheet(
                    initialChildSize: 0.7,
                    header: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 8),
                            width: 170,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Button(
                                    child: Text(
                                      'DELETE',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      _showRemoveEmployeeDialog(employee);
                                    }),
                                FilledButton(
                                    child: formFieldsEnabled
                                        ? const Text('SAVE')
                                        : const Text('EDIT'),
                                    onPressed: () {
                                      setSheetState(() {
                                        formFieldsEnabled = !formFieldsEnabled;

                                        if (!formFieldsEnabled) {
                                          final currentState =
                                              formKey.currentState;
                                          if (currentState!.validate()) {
                                            currentState.save();
                                            final oldData = _employeeDataSource
                                                .getEmployee(employee.id);

                                            if (oldData == null) return;
                                            final newData = oldData.copyWith(
                                                firstName: _formData.firstName,
                                                lastName: _formData.lastName,
                                                username: _formData.username);
                                            _employeeDataSource
                                                .updateEmployee(newData);
                                            _formData =
                                                EmployeeFormData.empty();
                                          }
                                        }
                                      });
                                    }),
                                IconButton(
                                    icon: const Icon(
                                        FluentIcons.calculator_multiply),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    })
                              ],
                            ),
                          ),
                          const SizedBox(width: 10)
                        ]),
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.4,
                        child: _buildNewEmployeeForm(
                            formKey: formKey,
                            title: '',
                            hasButton: false,
                            formFieldsEnabled: formFieldsEnabled,
                            callback: () {},
                            employee: employee),
                      ),
                    ])),
          );
        });
  }

  void _submitForm() {
    final currentState = _formKey.currentState;
    if (currentState!.validate()) {
      currentState.save();
      final employee = Employee(
          firstName: _formData.firstName,
          lastName: _formData.lastName,
          username: _formData.username);
      _employeeDataSource.create(employee);
      currentState.reset();
      _formData = EmployeeFormData.empty();
    }
  }
}

class EmployeeData extends material.DataTableSource {
  final List<Employee> employees;
  final void Function(Employee employee) employeeBottomSheet;

  EmployeeData({
    required this.employees,
    required this.employeeBottomSheet,
  });
  @override
  material.DataRow? getRow(int index) {
    final employee = employees[index];
    return material.DataRow.byIndex(index: index, cells: [
      material.DataCell(Text(employee.id.toString()), onTap: () {
        employeeBottomSheet(employee);
      }),
      material.DataCell(Text('${employee.firstName} ${employee.lastName}'),
          onTap: () {
        employeeBottomSheet(employee);
      }),
      material.DataCell(Text(employee.username), onTap: () {
        employeeBottomSheet(employee);
      })
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => employees.length;

  @override
  int get selectedRowCount => 0;
}
