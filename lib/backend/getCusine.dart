// AIzaSyAWfoSjAEfNGuD_S-20EybVZomy4Wxw65M
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'dart:io';

Future<List<Map<String, dynamic>>> sendImagesToApi(List<File> images) async {
  print("Sending images to API...");
  const apiKey = 'YOUR_API_KEY'; // Replace with your actual API key
  final config = GenerationConfig(
    temperature: 1,
    topK: 64,
    topP: 0.95,
    maxOutputTokens: 8192,
  );

  final model = GenerativeModel(
      model: 'gemini-1.5-pro', apiKey: apiKey, generationConfig: config);

  List<DataPart> imageParts = [];
  for (var image in images) {
    final imageBytes = await image.readAsBytes();
    imageParts.add(DataPart('image/jpeg', imageBytes));
  }

  final prompt = TextPart(
      """You are a master chef specializing in crafting recipes from given ingredients. 

      **Instructions:**
      1. Analyze the provided images of ingredients.
      2. Based on these ingredients, devise **exactly five** unique dish recipes.
      3. **Strictly adhere** to the following JSON format for each recipe:


      [
        {
          "Recipe name": "[Recipe Name 1]",
          "Ingredients": [
            {"name": "[Ingredient 1]", "quantity": "[Quantity] [Unit]"},
            {"name": "[Ingredient 2]", "quantity": "[Quantity] [Unit]"},
            ...
          ],
          "Time": "[Preparation & Cooking Time]",
          "Cuisine": "[Cuisine Type]",
          "Calories": "[Approximate Calories]",
          "Utensils": "[List of Utensils]",
          "Steps Required": [
            "[Step 1]",
            "[Step 2]",
            ...
          ]
        },
        {
          "Recipe name": "[Recipe Name 2]",
          ...
        },
        // ... Three more recipes ...
      ]
      ```

      **Important:**
      - Ensure all five recipes are returned within a single JSON array.
      - Do not include any introductory text or explanations outside the JSON structure.
      - Assume ingredient quantities are sufficient unless specified in the images.
      
      **Begin!**
      """);

  try {
    final response = await model.generateContent([
      Content.multi([prompt, ...imageParts])
    ]);

    // Find the first and last occurrences of '[' and ']'
    int startIndex = response.text!.indexOf('[');
    int endIndex = response.text!.lastIndexOf(']');

    // Extract the JSON string
    String jsonString = "";
    if (startIndex != -1 &&
        endIndex != -1 &&
        endIndex > startIndex) {
      jsonString = response.text!.substring(startIndex, endIndex + 1);
    } else {
      // Handle the case where valid JSON structure is not found
      print(
          'Error: Could not find valid JSON in the response. Response: ${response.text}');
      throw FormatException('Could not find valid JSON');
    }

    final jsonData = jsonDecode(jsonString);

    if (jsonData is List<dynamic> &&
        jsonData.every((item) => item is Map<String, dynamic>)) {
      print("Recipes fetched successfully!");
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw FormatException('JSON does not match expected format');
    }
  } catch (e) {
    print('Error: $e');
    rethrow; // This will allow the UI to handle the error
  }
}