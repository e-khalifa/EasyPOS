import 'package:flutter/material.dart';

class SalesStatisticsPage extends StatefulWidget {
  const SalesStatisticsPage({super.key});

  @override
  State<SalesStatisticsPage> createState() => _SalesStatisticsPageState();
}

class _SalesStatisticsPageState extends State<SalesStatisticsPage> {
  String? selectedPeriod = 'Today';
  var period = ['Today', 'Last Week', 'Last Month', 'Last Year', 'All Time'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sales Statistics'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            DropdownButtonFormField(
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 2, color: Colors.grey.shade300),
                ),
              ),
              isExpanded: true,
              items: period.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPeriod = newValue;
                });
              },
              value: selectedPeriod, // Set the value to the selected item
            )
          ]),
        ));
  }
}
