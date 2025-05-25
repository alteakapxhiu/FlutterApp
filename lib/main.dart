import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import './splash_screen.dart';
import './main.dart';

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
          seedColor: const Color.fromARGB(255, 255, 255, 255),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
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
  final TextEditingController _budgetController = TextEditingController();

  String _selectedType = 'Income';
  String _selectedCategory = 'Kategoria';

  final List<Map<String, dynamic>> _transactions = [];

  // Variabla për buxhetin e kursimit
  double _savingBudget = 0.0;

  // Përzgjedh tipin për grafik
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

  void _setSavingBudget() {
    final double? budget = double.tryParse(_budgetController.text);
    if (budget != null && budget >= 0) {
      setState(() {
        _savingBudget = budget;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Buxheti i kursimit u vendos në €${budget.toStringAsFixed(2)}',
          ),
        ),
      );
      _budgetController.clear();
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
    List<Widget> pages = [
      // Home Tab
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(child: Image.asset('images/savings.png', height: 80)),
            const SizedBox(height: 16),

            // Bilanci me ngjyrë të kuqe nëse shpenzimet kalojnë buxhetin
            Center(
              child: Text(
                "Bilanci: €${balance.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color:
                      totalExpenses > _savingBudget && _savingBudget > 0
                          ? Colors.red
                          : Colors.black,
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
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        totalExpenses > _savingBudget && _savingBudget > 0
                            ? Colors.red
                            : Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Shtimi i inputit dhe butonit për vendosjen e buxhetit të kursimit
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Vendos Buxhetin e Kursimit (€)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _setSavingBudget,
              child: const Text('Ruaj Buxhetin'),
            ),

            const Divider(height: 30),

            // Shtimi i transaksioneve
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
              fillColor: const Color.fromARGB(255, 19, 125, 5),
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

            Center(child: Image.asset('images/piggy_bank.png', height: 80)),

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
                          "${tx['category']} - ${tx['date'].toString().substring(0, 10)}",
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
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 4, 89, 8),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Grafiku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transaksionet',
          ),
        ],
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
      const Color.fromARGB(255, 2, 86, 27),
      Colors.green.shade400,
      const Color.fromARGB(255, 255, 38, 96),
      const Color.fromARGB(255, 170, 239, 80),
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
