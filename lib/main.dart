import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Inspired UI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MapPage(), // Set MapPage as the home page here
    );
  }
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  TextEditingController _destinationController = TextEditingController();

  // Function to handle search
  void _onSearchPressed() {
    String destination = _destinationController.text;
    print('Searching for: $destination');
    // You can add more functionality here, e.g., use an API to find places
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Navigation App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title text
            Text(
              'Kerko destinacionin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),

            // Search bar (TextField) with styling
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: 'Where do you want to go?',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Search Button with styling
            ElevatedButton(
              onPressed: _onSearchPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Search', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
