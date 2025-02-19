import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    BasicHero(),
    CustomTransitionHero(),
    BasicRadialHero(),
    CircularClipHero(),
    BackgroundExpansionHero(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hero Animation"),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.rectangle),
            label: 'Basic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rectangle),
            label: 'Custom',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: 'Basic Radial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: 'Circular Clip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: 'Background Expansion',
          ),
        ],
      ),
    );
  }
}

class BasicHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Basic Hero Animation")),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BasicHeroDetails()),
            );
          },
          child: Hero(
            tag: 'basic-hero-tag',
            child: Image.asset('images/a.jpeg', width: 100),
          ),
        ),
      ),
    );
  }
}

class BasicHeroDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Basic Hero Animation Details")),
      body: Center(
        child: Hero(
          tag: 'basic-hero-tag',
          child: Image.asset('images/a.jpeg', width: 300),
        ),
      ),
    );
  }
}

class CustomTransitionHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Custom Transition Hero")),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return CustomTransitionHeroDetails();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOut;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            );
          },
          child: Hero(
            tag: 'custom-transition-hero-tag',
            child: Image.asset('images/b.jpeg', width: 100),
          ),
        ),
      ),
    );
  }
}

class CustomTransitionHeroDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Custom Transition Hero Details")),
      body: Center(
        child: Hero(
          tag: 'custom-transition-hero-tag',
          child: Image.asset('images/b.jpeg', width: 300),
        ),
      ),
    );
  }
}

class BasicRadialHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Basic Radial Hero")),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return BasicRadialHeroDetails();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var radius = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
                  return RadialExpansion(
                    radius: radius,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Hero(
            tag: 'basic-radial-hero',
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}

class BasicRadialHeroDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Basic Radial Hero Details")),
      body: Center(
        child: Hero(
          tag: 'basic-radial-hero',
          child: Container(
            width: 300,
            height: 300,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}

class RadialExpansion extends StatelessWidget {
  final Animation<double> radius;
  final Widget child;

  RadialExpansion({required this.radius, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: radius,
      builder: (context, child) {
        return ClipOval(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: radius.value * 300,
              height: radius.value * 300,
              child: this.child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class CircularClipHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Circular Clip Hero")),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return CircularClipHeroDetails();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var radius = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
                  return ClipOval(
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: radius.value,
                          child: child,
                        );
                      },
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          child: Hero(
            tag: 'circular-clip-hero',
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}

class CircularClipHeroDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Circular Clip Hero Details")),
      body: Center(
        child: Hero(
          tag: 'circular-clip-hero',
          child: Container(
            width: 300,
            height: 300,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}

class BackgroundExpansionHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Background Expansion Hero")),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return BackgroundExpansionHeroDetails();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var radius = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: radius.value,
                          child: child,
                        );
                      },
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          child: Hero(
            tag: 'background-expansion-radial-hero',
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}

class BackgroundExpansionHeroDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Background Expansion Hero Details")),
      body: Center(
        child: Hero(
          tag: 'background-expansion-radial-hero',
          child: Container(
            width: 300,
            height: 300,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}