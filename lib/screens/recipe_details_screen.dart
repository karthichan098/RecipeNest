import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/recipe.dart';
import '../providers/saved_recipes_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  final AudioPlayer _audioPlayer = AudioPlayer();

  RecipeDetailScreen(this.recipe);

  @override
  Widget build(BuildContext context) {
    final savedRecipesProvider = Provider.of<SavedRecipesProvider>(context);
    bool isSaved = savedRecipesProvider.savedRecipes.any((r) => r.id == recipe.id);

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text(recipe.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share("Check out this recipe: ${recipe.name} \n ${recipe.image} \n ${recipe.instructions}");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Recipe Image with Parallax Effect
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Image.network(
                    recipe.image,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ).animate().fade(duration: 600.ms).scale(),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () async {
                      await _audioPlayer.play(AssetSource('audio/like_sound.mp3'));
                      savedRecipesProvider.toggleSaveRecipe(recipe);
                    },
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (widget, animation) => ScaleTransition(scale: animation, child: widget),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isSaved),
                        color: isSaved ? Colors.red : Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 📜 Recipe Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🍽️ Category
                  Text(
                    "Category: ${recipe.category}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepOrange),
                  ).animate().fade(duration: 400.ms),
                  SizedBox(height: 10),

                  // 🥗 Ingredients Card with Staggered Animation
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ingredients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)).animate().fade(duration: 500.ms),
                          SizedBox(height: 10),
                          ...recipe.ingredients.map((ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 8, color: Colors.orange),
                                SizedBox(width: 8),
                                Expanded(child: Text(ingredient, style: TextStyle(fontSize: 16, color: Colors.black87)))
                                    .animate().fade(duration: 300.ms, delay: 100.ms),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // 🍳 Instructions Card with Slide & Fade Animation
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("How to Make", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)).animate().fade(duration: 500.ms),
                          SizedBox(height: 10),
                          ...recipe.instructions.split('.').where((step) => step.trim().isNotEmpty).map((step) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle, size: 20, color: Colors.deepOrange),
                                SizedBox(width: 10),
                                Expanded(child: Text(step.trim(), style: TextStyle(fontSize: 16, color: Colors.black87)))
                                    .animate().slideX(duration: 400.ms, delay: 100.ms),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // ❤️ Save Recipe Button with Bounce Effect
                  Center(
                    child: ElevatedButton.icon(
                      onPressed:() async {
                        await _audioPlayer.play(AssetSource('audio/like_sound.mp3'));
                        savedRecipesProvider.toggleSaveRecipe(recipe);
                      },
                      icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
                      label: Text(isSaved ? "Saved" : "Save Recipe"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSaved ? Colors.red : Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ).animate().scale(duration: 400.ms, delay: 300.ms),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
