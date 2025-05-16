import 'package:flutter/material.dart';
import 'package:tap_eat/database/restaurant_db.dart';
import 'package:tap_eat/models/restaurant.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController searchController = TextEditingController();
  String filtro = 'Tutti';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF2),
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Logo
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Tap&Eat.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nome app
            const Center(
              child: Text(
                'Tap & Eat',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF252422),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Search Bar
            TextField(
              controller: searchController,
              style: const TextStyle(color: Color(0xFF252422)),
              decoration: InputDecoration(
                hintText: "Dove vuoi mangiare?",
                hintStyle: const TextStyle(color: Color(0xFF403D39)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF403D39)),
                filled: true,
                fillColor: const Color(0xFFCCC5B9).withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFEB5E28),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterChip(
                  label: const Text("Tutti"),
                  selected: filtro == 'Tutti',
                  onSelected: (_) {
                    setState(() {
                      filtro = 'Tutti';
                    });
                  },
                  backgroundColor: const Color(0xFFCCC5B9).withOpacity(0.3),
                  selectedColor: const Color(0xFFEB5E28),
                  labelStyle: TextStyle(
                    color:
                        filtro == 'Tutti'
                            ? const Color(0xFFFFFCF2)
                            : const Color(0xFF252422),
                    fontWeight:
                        filtro == 'Tutti' ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                FilterChip(
                  label: const Text("Italiani"),
                  selected: filtro == 'Italiani',
                  onSelected: (_) {
                    setState(() {
                      filtro = 'Italiani';
                    });
                  },
                  backgroundColor: const Color(0xFFCCC5B9).withOpacity(0.3),
                  selectedColor: const Color(0xFFEB5E28),
                  labelStyle: TextStyle(
                    color:
                        filtro == 'Italiani'
                            ? const Color(0xFFFFFCF2)
                            : const Color(0xFF252422),
                    fontWeight:
                        filtro == 'Italiani'
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                FilterChip(
                  label: const Text("Sushi"),
                  selected: filtro == 'Sushi',
                  onSelected: (_) {
                    setState(() {
                      filtro = 'Sushi';
                    });
                  },
                  backgroundColor: const Color(0xFFCCC5B9).withOpacity(0.3),
                  selectedColor: const Color(0xFFEB5E28),
                  labelStyle: TextStyle(
                    color:
                        filtro == 'Sushi'
                            ? const Color(0xFFFFFCF2)
                            : const Color(0xFF252422),
                    fontWeight:
                        filtro == 'Sushi' ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                FilterChip(
                  label: const Text("Americani"),
                  selected: filtro == 'Americani',
                  onSelected: (_) {
                    setState(() {
                      filtro = 'Americani';
                    });
                  },
                  backgroundColor: const Color(0xFFCCC5B9).withOpacity(0.3),
                  selectedColor: const Color(0xFFEB5E28),
                  labelStyle: TextStyle(
                    color:
                        filtro == 'Americani'
                            ? const Color(0xFFFFFCF2)
                            : const Color(0xFF252422),
                    fontWeight:
                        filtro == 'Americani'
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Recent Searches Title
            const Text(
              "Ricerche precedenti",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF252422),
              ),
            ),

            const SizedBox(height: 15),

            // Recent Searches Grid
            SizedBox(
              height: 220,
              child: FutureBuilder<List<Restaurant>>(
                future: RestaurantDatabase.instance.getHistory(limit: 4),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFEB5E28),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      "Errore: ${snapshot.error}",
                      style: const TextStyle(color: Color(0xFFEB5E28)),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nessuna ricerca recente",
                        style: TextStyle(color: Color(0xFF403D39)),
                      ),
                    );
                  }

                  final restaurants = snapshot.data!;
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return RestaurantCard(restaurant: restaurant);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFFFCF2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFCCC5B9).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF252422),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Distante ${restaurant.distance}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF403D39)),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFEB5E28), size: 18),
                const SizedBox(width: 4),
                Text(
                  restaurant.rating?.toString() ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF252422),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
