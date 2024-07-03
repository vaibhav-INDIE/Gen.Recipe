import 'dart:io';
import 'dart:convert';
import '../pages/Recipie.dart';
import 'package:flutter/material.dart';
import '../backend/getCusine.dart';

class Cusine extends StatefulWidget {
  final List<File> images;

  const Cusine({Key? key, required this.images}) : super(key: key);

  @override
  State<Cusine> createState() => _CusineState();
}

class _CusineState extends State<Cusine> {
  List<Map<String, dynamic>> _responseData = [];

  @override
  void initState() {
    super.initState();
    _sendImagesToApi();
  }

  Future<void> _sendImagesToApi() async {
    try {
      final response = await sendImagesToApi(widget.images);
      final jsonData = json.decode(response as String);  // Cast response to String
      if (jsonData is List) {
        setState(() {
          _responseData = List<Map<String, dynamic>>.from(jsonData);
        });
      } else {
        // Handle unexpected response format
        setState(() {
          _responseData = [];
        });
        // Optionally, show an error message or handle the error appropriately
        print("unexpected type");
      }
    } catch (e) {
      // Handle exceptions
      setState(() {
        _responseData = [];
      });
      // Optionally, show an error message or handle the error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI.Rassoi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _responseData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: _responseData.length,
          itemBuilder: (context, index) {
            final recipe = _responseData[index];
            return Container(
              width: screenWidth * 0.97,
              height: screenHeight * 0.2,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.purple[50], // Light purple background color
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Add your onPressed code here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Recipe(recipe: recipe),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(10),
                  backgroundColor: Colors.transparent, // Make button transparent
                  elevation: 0, // Remove button elevation
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipe['Recipe name'] ?? 'Unknown',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.0
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      recipe['Cuisine'] ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ingredients: ${recipe['Ingredients']?.join(', ') ?? 'Unknown'}',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          height: 1.1
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timelapse_sharp,
                              size: 24,
                              color: Colors.black,
                            ),
                            SizedBox(width: 5),
                            Text(
                              recipe['Time'] ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 24,
                              color: Colors.black,
                            ),
                            SizedBox(width: 5),
                            Text(
                              recipe['Calories'] ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

