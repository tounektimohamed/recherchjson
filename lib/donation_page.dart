import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _donationController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _allData = [];
  bool _noResultsFound = false;
  String _thankYouMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialize searchResults with empty list
    _searchResults = [];
    _loadJsonData(); // Load data but don't update search results yet
  }

  Future<void> _loadJsonData() async {
    try {
      final String response = await rootBundle.loadString('assets/data.json');
      final data = json.decode(response) as List<dynamic>;
      setState(() {
        _allData = data;
      });
    } catch (e) {
      print('Error loading JSON data: $e');
    }
  }

  void _handleSearch() {
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      setState(() {
        _searchResults = [];
        _noResultsFound = false;
      });
    } else {
      final results = _allData.where((item) {
        final name = item['name'] as String;
        return name.toLowerCase().contains(searchText);
      }).toList();

      setState(() {
        _searchResults = results;
        _noResultsFound = results.isEmpty;
      });
    }
  }

  void _handleDonation(String donorId) {
    final donationAmount = double.tryParse(_donationController.text) ?? 0.0;
    if (donationAmount > 0 && donorId.isNotEmpty) {
      setState(() {
        _thankYouMessage =
            'Merci pour votre don de \$${donationAmount.toStringAsFixed(2)}!';
        // Update the donation amount in the selected donor data
        final index =
            _allData.indexWhere((item) => item['id'] == int.parse(donorId));
        if (index != -1) {
          _allData[index]['donation'] = donationAmount;
        }
        // Reset donation input
        _donationController.clear();
        Navigator.of(context).pop();
      });
    }
  }

  void _showDonationDialog(String donorId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Faire un don'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _donationController,
                decoration: InputDecoration(
                  labelText: 'Montant du don',
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _handleDonation(donorId);
              },
              child: Text('Confirmer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 100),
            Text(
              "Partagez L'amour,\nOffrez Un Don\nAujourd'hui",
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'Futura-Bold',
                fontWeight: FontWeight.w500,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            Text(
              "Découvrez où votre contribution\npeut vraiment faire la différence",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(1),
                borderRadius: BorderRadius.circular(80),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  suffixIcon: Transform.scale(
                    scale: 0.7,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(88, 48, 48, 1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.grid_view, color: Colors.white),
                    ),
                  ),
                  hintText: 'Recherche',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(141, 141, 141, 1),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (value) => _handleSearch(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(255, 196, 0, 1.0),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                shadowColor: Colors.black.withOpacity(0.5),
                elevation: 5,
              ),
              onPressed: _handleSearch,
              child: Text(
                'Rechercher',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(88, 48, 48, 1),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: _noResultsFound && _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun résultat trouvé.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return ListTile(
                          title: Text(item['name']),
                          subtitle: Text(item['description']),
                          trailing: IconButton(
                            icon: Icon(Icons.payment),
                            onPressed: () {
                              _showDonationDialog(item['id'].toString());
                            },
                          ),
                        );
                      },
                    ),
            ),
            if (_thankYouMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    _thankYouMessage,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
