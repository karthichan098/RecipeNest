import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../providers/saved_recipes_provider.dart';
import 'recipe_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  List<Recipe> recipes = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  int _selectedIndex = 0; // To track active tab

  void fetchRecipes() async {
    if (searchController.text.isNotEmpty) {
      setState(() => isLoading = true);
      try {
        final result = await apiService.fetchRecipes(searchController.text);
        setState(() => recipes = result);
      } catch (e) {
        debugPrint("Error fetching recipes: $e");
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? "🍽️ Recipe Finder" : "❤️ Saved Recipes",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: _selectedIndex == 0 ? _searchRecipesTab() : _savedRecipesTab(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Saved"),
        ],
      ),
    );
  }

  /// 🔍 **Search Recipes Tab**
  Widget _searchRecipesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildSearchBar(),
        ),
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.deepOrange))
              : recipes.isNotEmpty
              ? ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return recipeCard(recipes[index]);
            },
          )
              : _emptyMessage("No recipes found! 🍜\nTry searching for a delicious meal"),
        ),
      ],
    );
  }

  /// ❤️ **Saved Recipes Tab**
  Widget _savedRecipesTab() {
    final savedRecipesProvider = Provider.of<SavedRecipesProvider>(context);
    final savedRecipes = savedRecipesProvider.savedRecipes;

    return savedRecipes.isNotEmpty
        ? ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: savedRecipes.length,
      itemBuilder: (context, index) {
        return recipeCard(savedRecipes[index]);
      },
    )
        : _emptyMessage("No saved recipes yet! ❤️\nSave your favorites to find them here.");
  }

  /// 📌 **Recipe Card (Optimized)**
  Widget recipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe)),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📷 **Recipe Image**
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
              child: Image.network(
                recipe.image,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            /// 🍽️ **Recipe Details**
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Prevents extra space
                  children: [
                    Text(
                      recipe.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text("Category: ${recipe.category}", style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔎 **Search Bar Widget**
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade300.withAlpha((0.5 * 255).toInt()),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        cursorColor: Colors.deepOrange,
        style: TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: "🔍 Search delicious recipes...",
          hintStyle: TextStyle(color: Colors.black54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    searchController.clear();
                    setState(() => recipes.clear());
                  },
                ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.deepOrange),
                onPressed: fetchRecipes,
              ),
            ],
          ),
        ),
        onSubmitted: (value) => fetchRecipes(),
      ),
    );
  }

  /// 🥲 **Empty Message Widget**
  Widget _emptyMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
      ),
    );
  }
}
