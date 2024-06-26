import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../helpers/sql_helper.dart';

class ExchangeRateTable extends StatefulWidget {
  const ExchangeRateTable({super.key});

  @override
  State<ExchangeRateTable> createState() => _ExchangeRateTableState();
}

class _ExchangeRateTableState extends State<ExchangeRateTable> {
  var sqlHelper = GetIt.I.get<SqlHelper>();

  final List<Map<String, dynamic>> currencies = [
    {'currency': 'USD', 'exchangeRate': 48.32},
    {'currency': 'EUR', 'exchangeRate': 51.88},
    {'currency': 'GBP', 'exchangeRate': 61.34},
    {'currency': 'JPY', 'exchangeRate': 0.30},
    {'currency': 'AUD', 'exchangeRate': 32.19},
  ];

  int _currentSortColumn = 2;
  bool _isAscending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Exchange Rates')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            sortColumnIndex: _currentSortColumn,
            sortAscending: _isAscending,
            decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor,
                borderRadius: BorderRadius.circular(10)),
            headingTextStyle: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            border: TableBorder.all(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300),
            headingRowColor: MaterialStateColor.resolveWith(
                (states) => Theme.of(context).primaryColor),
            columns: [
              const DataColumn(
                  label: Text('Currency', textAlign: TextAlign.center)),
              const DataColumn(
                  label: Text('Quantity', textAlign: TextAlign.center)),
              DataColumn(
                label: const Text('EGP', textAlign: TextAlign.center),
                onSort: (columnIndex, _) {
                  setState(() {
                    _currentSortColumn = columnIndex;
                    _isAscending = !_isAscending;
                    _sortCurrencies();
                  });
                },
              ),
            ],
            rows: currencies.map((currency) {
              return DataRow(cells: [
                DataCell(
                    Text(currency['currency'], textAlign: TextAlign.center)),
                const DataCell(Text('1',
                    textAlign: TextAlign.center)), // Quantity is always 1
                DataCell(Text('${currency['exchangeRate']}',
                    textAlign: TextAlign.center)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _sortCurrencies() {
    currencies.sort((a, b) {
      final aValue = a['exchangeRate'];
      final bValue = b['exchangeRate'];
      return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }
}
