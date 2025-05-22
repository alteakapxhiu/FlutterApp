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

  // Ky variabël përzgjedh se çfarë tipi do shfaqim në grafik (Income ose Expense)
  String _chartType = 'Income';

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
                const SizedBox(width: 16),
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

      // Pie Chart Tab me toggle për Income/Expense
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [_chartType == 'Income', _chartType == 'Expense'],
              onPressed: (int index) {
                setState(() {
                  _chartType = index == 0 ? 'Income' : 'Expense';
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: const Color.fromARGB(255, 11, 160, 171),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Të ardhurat'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Shpenzimet'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildPieChartByType(_chartType)),
          ],
        ),
      ),

      // Transaction List Tab
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
                const SizedBox(width: 16),
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
                        leading: Icon(
                          tx['type'] == 'Income'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color:
                              tx['type'] == 'Income'
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        title: Text("${tx['description']} - €${tx['amount']}"),
                        subtitle: Text(
                          '${tx['type']} (${tx['category']}) - ${tx['date'].day}/${tx['date'].month}/${tx['date'].year}',
                        ),
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

  Widget _buildPieChartByType(String type) {
    // Filtrimi i të dhënave sipas tipit (Income/Expense)
    Map<String, double> categoryData = {};

    for (var tx in _transactions) {
      if (tx['type'] == type) {
        String category = tx['category'];
        categoryData[category] = (categoryData[category] ?? 0) + tx['amount'];
      }
    }

    if (categoryData.isEmpty) {
      return Center(child: Text('Nuk ka të dhëna për $type.'));
    }

    // Ngjyrat për kategori në grafik
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      const Color.fromARGB(255, 255, 38, 96),
      Colors.red.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
    ];

    // Ndërtimi i seksioneve për grafik
    final List<PieChartSectionData> sections = [];
    int colorIndex = 0;
    categoryData.forEach((category, amount) {
      final color = colors[colorIndex % colors.length];
      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: category,
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    // Përmbledhje e të ardhurave dhe shpenzimeve sipas kategorive për gjithë transaksionet
    Map<String, double> incomeByCategory = {};
    Map<String, double> expenseByCategory = {};

    for (var tx in _transactions) {
      String category = tx['category'];
      double amount = tx['amount'];

      if (tx['type'] == 'Income') {
        incomeByCategory[category] = (incomeByCategory[category] ?? 0) + amount;
      } else {
        expenseByCategory[category] =
            (expenseByCategory[category] ?? 0) + amount;
      }
    }

    // Filtrimi i transaksioneve për historikun sipas tipit të zgjedhur
    List filteredTransactions =
        _transactions.where((tx) => tx['type'] == type).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Historiku sipas Kategorisë:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          filteredTransactions.isEmpty
              ? const Text("Nuk ka transaksione për të shfaqur.")
              : Column(
                children:
                    filteredTransactions.map((tx) {
                      return ListTile(
                        leading: Icon(
                          _getCategoryIcon(tx['category']),
                          color: Colors.blueGrey,
                        ),
                        title: Text(
                          "${tx['category']} - €${tx['amount'].toStringAsFixed(2)}",
                        ),
                        subtitle: Text("${tx['description']} (${tx['type']})"),
                        trailing: Text(
                          "${tx['date'].day}/${tx['date'].month}/${tx['date'].year}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
              ),
          const Divider(height: 30),
          const Text(
            'Përmbledhje sipas Kategorisë:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Të ardhurat:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          ...incomeByCategory.entries.map(
            (entry) => Row(
              children: [
                Icon(_getCategoryIcon(entry.key), color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  "${entry.key}: €${entry.value.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Shpenzimet:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          ...expenseByCategory.entries.map(
            (entry) => Row(
              children: [
                Icon(_getCategoryIcon(entry.key), color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  "${entry.key}: €${entry.value.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Funksioni për të marrë ikonën sipas kategorisë
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Shkolle':
        return Icons.school;
      case 'Argetim':
        return Icons.movie;
      case 'Ushqim':
        return Icons.fastfood;
      case 'Transport':
        return Icons.directions_car;
      case 'Tjera':
        return Icons.category;
      default:
        return Icons.help_outline;
    }
  }
}
