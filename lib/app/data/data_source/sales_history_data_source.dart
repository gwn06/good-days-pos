import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:objectbox/internal.dart';
import 'package:pos_system/app/core/values/constants.dart';
import 'package:pos_system/app/data/enums/sales_date_range.dart';
import 'package:pos_system/app/data/model/sales_history.dart';
import 'package:pos_system/main.dart';
import 'package:pos_system/objectbox.g.dart';

import 'objectbox_database.dart';
import 'package:intl/intl.dart';

enum FilterSalesBy {
  allSales,
  todaysSale,
  selectedDate,
}

final salesHistoryProvider = Provider<SalesHistoryDataSource>((ref) {
  return SalesHistoryDataSourceImpl(objectBox);
});

abstract class SalesHistoryDataSource {
  Stream<List<SalesHistory>> getAllSales(
      {required QueryProperty<SalesHistory, dynamic> sortField,
      bool ascending});
  Stream<List<SalesHistory>> getTodaysSales(
      {required QueryProperty<SalesHistory, dynamic> sortField,
      bool ascending});
  Stream<List<SalesHistory>> getSelectedSalesDate(
      {required QueryProperty<SalesHistory, dynamic> sortField,
      required DateTime date,
      bool ascending});
  Stream<List<SalesHistory>> getSalesFilteredBy({
    required FilterSalesBy filter,
    DateTime? date,
    QueryProperty<SalesHistory, dynamic>? sortField,
    bool ascending = true,
  });
  Stream<Map<String, List<SalesHistory>>> getSalesByDate(
      {required DateTime begin,
      required DateTime end,
      required DateFormat dateFormat});
  Stream<Map<String, List<SalesHistory>>> getSalesByDateRange(
      {required SalesDate salesDate, DateTime? date});
  void removeSaleHistory(int id);
  void removeAllSaleHistory();
  void addToSalesHistory(SalesHistory sales);
  void updateSalesHistory(SalesHistory sales);
}

class SalesHistoryDataSourceImpl extends SalesHistoryDataSource {
  final ObjectBoxDatabase db;

  SalesHistoryDataSourceImpl(this.db);
  @override
  void addToSalesHistory(SalesHistory sales) {
    db.salesHistoryBox.put(sales);
  }

  @override
  Stream<List<SalesHistory>> getAllSales(
      {required QueryProperty<SalesHistory, dynamic> sortField,
      bool ascending = true}) {
    final qBuilder = db.salesHistoryBox.query()
      ..order(sortField, flags: ascending ? 0 : Order.descending);
    return qBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  Stream<List<SalesHistory>> getTodaysSales(
      {required QueryProperty<SalesHistory, dynamic> sortField,
      bool ascending = true}) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay
        .add(const Duration(hours: k23Hours, minutes: k59Minutes))
        .millisecondsSinceEpoch;
    final qBuilder = db.salesHistoryBox.query(
        SalesHistory_.date.between(startOfDay.millisecondsSinceEpoch, endOfDay))
      ..order(sortField, flags: ascending ? 0 : Order.descending);
    return qBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  Stream<List<SalesHistory>> getSelectedSalesDate(
      {required QueryProperty<SalesHistory, dynamic> sortField,
      bool ascending = true,
      required DateTime date}) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay
        .add(const Duration(hours: k23Hours, minutes: k59Minutes))
        .millisecondsSinceEpoch;
    final qBuilder = db.salesHistoryBox.query(
        SalesHistory_.date.between(startOfDay.millisecondsSinceEpoch, endOfDay))
      ..order(sortField, flags: ascending ? 0 : Order.descending);
    return qBuilder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  void removeSaleHistory(int id) {
    db.salesHistoryBox.remove(id);
    // db.salesHistoryBox.removeAll();
  }

  @override
  void removeAllSaleHistory() {
    db.salesHistoryBox.removeAll();
  }

  @override
  void updateSalesHistory(SalesHistory sales) {
    db.salesHistoryBox.put(sales, mode: PutMode.update);
  }

  @override
  Stream<List<SalesHistory>> getSalesFilteredBy({
    required FilterSalesBy filter,
    QueryProperty<SalesHistory, dynamic>? sortField,
    DateTime? date,
    bool ascending = true,
  }) {
    sortField ??= SalesHistory_.date;
    switch (filter) {
      case FilterSalesBy.allSales:
        return getAllSales(sortField: sortField, ascending: ascending);
      case FilterSalesBy.todaysSale:
        return getTodaysSales(sortField: sortField, ascending: ascending);
      case FilterSalesBy.selectedDate:
        return getSelectedSalesDate(sortField: sortField, date: date!);
    }
  }

  @override
  Stream<Map<String, List<SalesHistory>>> getSalesByDate(
      {required DateTime begin,
      required DateTime end,
      required DateFormat dateFormat}) {
    final Map<String, List<SalesHistory>> dailySales = {};

    final qBuilder = db.salesHistoryBox.query(SalesHistory_.date
        .between(begin.millisecondsSinceEpoch, end.millisecondsSinceEpoch))
      ..order(SalesHistory_.date, flags: 0);

    return qBuilder.watch(triggerImmediately: true).map((query) {
      final salesHistory = query.find();
      for (final sale in salesHistory) {
        final nameOfDay = dateFormat.format(sale.date);
        dailySales.update(nameOfDay, (list) {
          list.add(sale);
          return list;
        }, ifAbsent: () => [sale]);
      }

      return dailySales;
    });
  }

  @override
  Stream<Map<String, List<SalesHistory>>> getSalesByDateRange(
      {required SalesDate salesDate, DateTime? date}) {
    final now = DateTime.now();
    final dayName = DateFormat(DateFormat.WEEKDAY);
    final monthName = DateFormat(DateFormat.ABBR_MONTH);
    final yearName = DateFormat(DateFormat.YEAR);
    switch (salesDate) {
      case SalesDate.in7Days:
        final today = DateTime(now.year, now.month, now.day)
            .add(const Duration(hours: 23, minutes: 59));
        final lastSixDays = today.subtract(const Duration(days: kSeven));
        return getSalesByDate(
            begin: lastSixDays, end: today, dateFormat: dayName);
      case SalesDate.in12Months:
        int lastday = DateTime(now.year, now.month + 1, 0).day;
        final end = DateTime(now.year, now.month, lastday);
        final last11Months = DateTime(now.year, now.month - k11, now.day);
        return getSalesByDate(
            begin: last11Months, end: end, dateFormat: monthName);
      case SalesDate.in5Years:
        final today = DateTime(now.year, now.month, now.day)
            .add(const Duration(hours: 23, minutes: 59));
        final last5Years = DateTime(now.year - k5, now.month, now.day);
        return getSalesByDate(
            begin: last5Years, end: today, dateFormat: yearName);
      case SalesDate.byMonth:
        final selectedDateStart = DateTime(date!.year, date.month, 1);
        final lastDayOfMonth = DateTime(date.year, date.month + 1, 0).day;
        final selectedDateEnd =
            DateTime(date.year, date.month, lastDayOfMonth, 23, 59, 59);
        return getSalesByDate(
            begin: selectedDateStart,
            end: selectedDateEnd,
            dateFormat: monthName);
      case SalesDate.byYear:
        final firstMonthOfSelectedYear = DateTime(date!.year, 1, 1);
        final lastDayOfMonth = DateTime(date.year, 13, 0).day;
        final lastMonthOfSelectedYear =
            DateTime(date.year, 12, lastDayOfMonth, 23, 59, 59);
        return getSalesByDate(
            begin: firstMonthOfSelectedYear,
            end: lastMonthOfSelectedYear,
            dateFormat: yearName);
    }
  }
}
