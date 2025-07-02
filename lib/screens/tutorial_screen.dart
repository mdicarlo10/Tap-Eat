import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: const Color(0xFFE0D1B9),
      pages: [
        PageViewModel(
          titleWidget: const Text(
            "Benvenuto su Tap&Eat!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE4572E),
            ),
            textAlign: TextAlign.center,
          ),
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Trova il ristorante perfetto per te\ncon Tap&Eat!",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logo.png',
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            ],
          ),
          decoration: const PageDecoration(
            bodyAlignment: Alignment.center,
            imageAlignment: Alignment.center,
          ),
        ),
        PageViewModel(
          title: "Aggiungi ai preferiti",
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.favorite, size: 100, color: Colors.red)],
              ),
              SizedBox(height: 20),
              Text(
                "Salva i tuoi ristoranti preferiti\n così puoi tornarci quando vuoi!",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          decoration: const PageDecoration(
            bodyAlignment: Alignment.center,
            imageAlignment: Alignment.center,
          ),
        ),
        PageViewModel(
          title: "Ricerche recenti",
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 100, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                "Non ti ricordi il nome del ristorante che hai appena visitato? \nNon preoccuparti, puoi trovarlo nella pagina principale!",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          decoration: const PageDecoration(
            bodyAlignment: Alignment.center,
            imageAlignment: Alignment.center,
          ),
        ),
        PageViewModel(
          title: "Cerca con la matita",
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit, size: 100, color: Colors.blueGrey),
              SizedBox(height: 20),
              Text(
                "Tocca l'icona della matita per disegnare un'area \nsulla mappa e trovare altri ristoranti!",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          decoration: const PageDecoration(
            bodyAlignment: Alignment.center,
            imageAlignment: Alignment.center,
          ),
        ),
        PageViewModel(
          titleWidget: const Text(
            "Inizia ora!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE4572E),
            ),
          ),
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 350,
                height: 350,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              const Text(
                "Premi su 'Inizia' per esplorare Tap&Eat!",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          decoration: const PageDecoration(
            bodyAlignment: Alignment.center,
            imageAlignment: Alignment.center,
          ),
        ),
      ],
      onDone: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('seenTutorial', true);
        if (!context.mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NavigationWrapper()),
        );
      },
      showSkipButton: true,
      skip: const SizedBox(
        height: 28,
        child: Text("Salta", style: TextStyle(fontSize: 14)),
      ),
      next: const SizedBox(
        height: 28,
        width: 28,
        child: Icon(Icons.arrow_forward, size: 18),
      ),
      done: const SizedBox(
        height: 28,
        child: Text(
          "Inizia",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      dotsDecorator: const DotsDecorator(
        activeSize: Size(16, 6),
        size: Size(8, 6),
        activeColor: Colors.deepOrange,
        color: Colors.black26,
        spacing: EdgeInsets.symmetric(horizontal: 2),
      ),
    );
  }
}
