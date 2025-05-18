import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulatori i Buxhetit Personal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const BudgetHomePage(),
    );
  }
}

class BudgetHomePage extends StatefulWidget {
  const BudgetHomePage({super.key});

  @override
  _BudgetHomePageState createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedType = 'Income';
  String _selectedCategory = 'Kategoria';

  List<Map<String, dynamic>> _transactions = [];

  double get totalIncome => _transactions
      .where((item) => item['type'] == 'Income')
      .fold(0.0, (sum, item) => sum + item['amount']);

  double get totalExpenses => _transactions
      .where((item) => item['type'] == 'Expense')
      .fold(0.0, (sum, item) => sum + item['amount']);

  double get balance => totalIncome - totalExpenses;

  void _addTransaction() {
    final double? amount = double.tryParse(_amountController.text);
    if (amount != null && _descriptionController.text.isNotEmpty) {
      setState(() {
        _transactions.add({
          'amount': amount,
          'description': _descriptionController.text,
          'type': _selectedType,
          'category': _selectedCategory,
          'date': DateTime.now(),
        });
        _amountController.clear();
        _descriptionController.clear();
      });
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Map<int, Map<String, double>> _groupTransactionsByMonth() {
    Map<int, Map<String, double>> data = {};
    for (var tx in _transactions) {
      DateTime date = tx['date'];
      int month = date.month;
      if (!data.containsKey(month)) {
        data[month] = {'Income': 0.0, 'Expense': 0.0};
      }
      data[month]![tx['type']] = data[month]![tx['type']]! + tx['amount'];
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      // Home Tab
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Image.asset('images/1.png'),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "Bilanci: €${balance.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Të ardhurat: €${totalIncome.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16), // Space between the texts
                Text(
                  "Shpenzimet: €${totalExpenses.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Divider(height: 30),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Shuma'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Përshkrimi'),
            ),
            const SizedBox(height: 10),

            // DropDown per llojin dhe kategorine ne te njejtin rresht
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedType,
                    items:
                        ['Income', 'Expense'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value == 'Income' ? 'Të ardhura' : 'Shpenzim',
                            ),
                          );
                        }).toList(),
                    onChanged:
                        (value) => setState(() => _selectedType = value!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    items:
                        [
                          'Kategoria',
                          'Shkolle',
                          'Argetim',
                          'Ushqim',
                          'Transport',
                          'Tjera',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged:
                        (value) => setState(() => _selectedCategory = value!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTransaction,
              child: const Text('Shto Transaksion'),
            ),
          ],
        ),
      ),

      // Business Tab - Pie Chart
      Padding(padding: const EdgeInsets.all(16.0), child: _buildPieChart()),

      // School Tab - Lista e transaksioneve
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Të ardhurat: €${totalIncome.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16), // Space between the texts
                Text(
                  "Shpenzimet: €${totalExpenses.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Lista e Transaksioneve:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children:
                    _transactions.map((tx) {
                      return ListTile(
                        title: Text("${tx['description']} - €${tx['amount']}"),
                        subtitle: Text('${tx['type']} (${tx['category']})'),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulatori i Buxhetit Personal')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Analiza',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transaksione',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 11, 160, 171),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPieChart() {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in _transactions) {
      if (tx['type'] == 'Income') {
        totalIncome += tx['amount'];
      } else {
        totalExpense += tx['amount'];
      }
    }

    if (totalIncome == 0 && totalExpense == 0) {
      return const Center(child: Text('Nuk ka të dhëna për grafik.'));
    }

    final List<PieChartSectionData> sections = [
      if (totalIncome > 0)
        PieChartSectionData(
          color: const Color.fromARGB(255, 5, 124, 145),
          value: totalIncome,
          title: 'Fitim\n€${totalIncome.toStringAsFixed(2)}',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (totalExpense > 0)
        PieChartSectionData(
          color: const Color.fromARGB(255, 82, 249, 252),
          value: totalExpense,
          title: 'Shpenzim\n€${totalExpense.toStringAsFixed(2)}',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  double _getMaxY(Map<int, Map<String, double>> data) {
    double maxY = 0;
    data.forEach((month, values) {
      double sum =
          values['Income']! > values['Expense']!
              ? values['Income']!
              : values['Expense']!;
      if (sum > maxY) maxY = sum;
    });
    return maxY + 10;
  }
}
