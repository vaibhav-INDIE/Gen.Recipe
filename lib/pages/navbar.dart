import 'package:flutter/material.dart';
import 'home.dart';
import 'cusine.dart';

class Navbar extends StatelessWidget {
  const Navbar({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle navigation here based on the index
          switch (index) {
            case 0:
            // Navigate to Home page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            case 1:
            // Navigate to Cusine page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Cusine(images: [],)),
              );
              break;
          // Add cases for other navigation items if needed
          }
        },
      ),
    );
  }
}
