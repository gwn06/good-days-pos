import 'package:pos_system/app/data/model/employee.dart';
import 'package:pos_system/app/data/model/product.dart';
import 'package:pos_system/app/data/model/sales_history.dart';
import 'package:pos_system/objectbox.g.dart';

const kpath = 'products_db';

class ObjectBoxDatabase {
  late final Store store;
  late final Box<ProductInfo> productBox;
  late final Box<Employee> employeeBox;
  late final Box<SalesHistory> salesHistoryBox;

  ObjectBoxDatabase._create(this.store) {
    productBox = store.box<ProductInfo>();
    employeeBox = store.box<Employee>();
    salesHistoryBox = store.box<SalesHistory>();
  }

  static Future<ObjectBoxDatabase> create() async {
    final store = await openStore(directory: kpath);
    return ObjectBoxDatabase._create(store);
  }
}
