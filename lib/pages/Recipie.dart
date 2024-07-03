import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Recipe extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const Recipe({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeState createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  int servings = 1;
  static const apiKey =
      'YOUR_API_KEY'; // Replace with your actual API key
  Map<String, dynamic>? _responseData = {};
  bool _isLoading = false;

  final model = GenerativeModel(
    model: 'gemini-1.5-pro',
    apiKey: apiKey,
    generationConfig: GenerationConfig(
      temperature: 1,
      topK: 64,
      topP: 0.95,
      maxOutputTokens: 8192,
    ),
  );

  final model2 = GenerativeModel(
    model: 'gemini-1.5-pro',
    apiKey: apiKey,
    generationConfig: GenerationConfig(
      temperature: 1,
      topK: 64,
      topP: 0.95,
      maxOutputTokens: 8192,
    ),
  );

  @override
  void initState() {
    super.initState();
    _getRecipe();
  }

  Future<void> _getRecipe() async {
    setState(() {
      _isLoading = true;
    });

    final content = [
      Content.text(
        "Give me the recipe for ${widget.recipe['Recipe name']} for $servings people using these ingredients: ${widget.recipe['Ingredients']?.join(', ')}. Respond in this format only, with the following structure: \n"
            "{\n"
            "  \"Ingredients\": [\n"
            "    {\n"
            "      \"name\": \"Ingredient Name\",\n"
            "      \"quantity\": \"Quantity (e.g., 1 cup, 2 tbsp)\"\n"
            "    },\n"
            "    ... \n"
            "  ],\n"
            "  \"Steps\": [\n"
            "    \"Step 1\",\n"
            "    \"Step 2\",\n"
            "    ... \n"
            "  ]\n"
            "}",
      ),
    ];

    try {
      final response = await model.generateContent(content);
      final jsonData = response.text!;
      setState(() {
        _responseData = json.decode(jsonData) as Map<String, dynamic>;
      });
    } catch (e) {
      setState(() {
        _responseData = null;
      });
      print('Error parsing JSON response: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _incrementServings() {
    setState(() {
      servings++;
      _getRecipe();
    });
  }

  void _decrementServings() {
    setState(() {
      if (servings > 1) {
        servings--;
        _getRecipe();
      }
    });
  }

  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage(String message) async {
    setState(() {
      _messages.add({'sender': 'user', 'text': message});
      _controller.clear();
    });
    _scrollDown();

    String? botResponse = await _getBotResponse(message);
    setState(() {
      _messages.add({'sender': 'bot', 'text': botResponse.toString()});
    });
    _scrollDown();
  }

  Future<String?> _getBotResponse(String message) async {
    message =
    "I am a cook and I am preparing ${widget.recipe['Recipe name']}. I have a question: $message";
    var content = [Content.text(message)];
    var chatResponse = await model2.generateContent(content);
    return chatResponse.text!;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gen.Recipe",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildRecipeCard(),
            SizedBox(height: 10),
            _buildTabs(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard() {
    return Container(
      margin: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.purple[50],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.recipe['Recipe name'] ?? 'Unknown',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10),
          Text(
            widget.recipe['Cuisine'] ?? 'Unknown',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timelapse_sharp,
                      size: 20, color: Colors.grey[700]),
                  SizedBox(width: 5),
                  Text(
                    widget.recipe['Time'] ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.local_fire_department,
                      size: 20, color: Colors.grey[700]),
                  SizedBox(width: 5),
                  Text(
                    widget.recipe['Calories'] ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return DefaultTabController(
      length: 3,
      child: Expanded(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                color: Colors.purple[50],
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicator: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  color: Colors.purple[100],
                ),
                tabs: [
                  Tab(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "INGREDIENTS",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "BRIEFLY",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "CHAT",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                children: [
                  _buildIngredientsTab(),
                  _buildBrieflyTab(),
                  _buildChatTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return Column(
      children: [
        _buildServingsController(),
        SizedBox(height: 10),
        _buildIngredientsList(),
      ],
    );
  }

  Widget _buildServingsController() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: Colors.purple[50],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.people_outline_sharp,
                size: 25,
              ),
              Text(
                "Servings",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _decrementServings,
                    icon: Icon(Icons.remove),
                    color: Colors.black,
                  ),
                  Text(
                    '$servings',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _incrementServings,
                    icon: Icon(Icons.add),
                    color: Colors.black,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: Colors.purple[50],
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingredients:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _responseData?['Ingredients']?.length ?? 0,
                itemBuilder: (context, index) {
                  final ingredient = _responseData!['Ingredients'][index];
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Text(
                              "${ingredient['name']}",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: Text(
                              "${ingredient['quantity']}",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrieflyTab() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.only(left: 15, right: 15),
      child: SingleChildScrollView(
        child: Container(
          padding:
          EdgeInsets.only(left: 25, top: 15, bottom: 15, right: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color: Colors.purple[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Steps:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              ...widget.recipe['Steps Required']?.map((step) => Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style:
                        TextStyle(fontSize: 14, color: Colors.grey[700])),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )) ??
                  [],
              SizedBox(height: 10),
              Text(
                'Utensils:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              ...widget.recipe['Utensils']?.map((utensil) => Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style:
                        TextStyle(fontSize: 14, color: Colors.grey[700])),
                    Expanded(
                      child: Text(
                        utensil,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )) ??
                  [],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['sender'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message['sender'] == 'user'
                          ? Colors.blueAccent
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        color: message['sender'] == 'user'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _sendMessage(text.trim());
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _sendMessage(_controller.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}