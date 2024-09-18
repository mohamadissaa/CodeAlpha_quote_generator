import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share/share.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Quote Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _quote = "Click the button to generate a random quote!";
  String _author = "";
  List<String> _favorites = []; // List to store favorite quotes

  // Function to fetch random quote from ZenQuotes API
  Future<void> _getRandomQuote() async {
    try {
      final response =
          await http.get(Uri.parse('https://zenquotes.io/api/random'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _quote = data[0]['q']; // Get the quote text
          _author = data[0]['a']; // Get the quote author
        });
      } else {
        setState(() {
          _quote = "Failed to load quote.";
          _author = "";
        });
      }
    } catch (e) {
      setState(() {
        _quote = "Error occurred: $e";
        _author = "";
      });
    }
  }

  // Function to add quote to favorites
  void _addToFavorites() {
    setState(() {
      _favorites.add('$_quote - $_author');
    });
  }

  void _removeFromFavorites(String quote) {
    setState(() {
      _favorites.remove(quote);
    });
  }

  // Function to share the quote
  void _shareQuote() {
    Share.share('$_quote - $_author');
  }

  // Function to show favorite quotes in a dialog
void _showFavorites() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Favorite Quotes'),
            content: SizedBox(
              height: 200,
              width: 300,
              child: ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_favorites[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _removeFromFavorites(_favorites[index]);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1518837695005-2083093ee35b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwzNjUyOXwwfDF8c2VhcmNofDJ8fG1vdW50YWluc3xlbnwwfHx8fDE2ODc5MzYwMjU&ixlib=rb-1.2.1&q=80&w=1080',
              fit: BoxFit.cover,
            ),
          ),

          // Quote content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Quote container with custom styling
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _quote,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '- $_author',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Consistent button design
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStyledButton(
                        label: 'New Quote',
                        onPressed: _getRandomQuote,
                      ),
                      _buildStyledButton(
                        label: 'Share',
                        onPressed: _shareQuote,
                        icon: const Icon(
                          Icons.share,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildStyledButton(
                    label: 'Add to Favorites',
                    onPressed: _addToFavorites,
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildStyledButton(
                    label: 'View Favorites',
                    onPressed: _showFavorites,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom function for a consistent button design
  ElevatedButton _buildStyledButton({
    required String label,
    required VoidCallback onPressed,
    Icon? icon,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: const Color.fromARGB(
            255, 229, 230, 240), // Same color for all buttons
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      icon: icon ??
          const Icon(
            Icons.star_border,
            color: Colors.amber,
          ),
      label: Text(label),
    );
  }
}
