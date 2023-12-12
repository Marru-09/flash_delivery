import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flash_delivery/inject_dependencies.dart';
import 'package:flash_delivery/routes/app_routes.dart';
import 'package:flash_delivery/routes/routes.dart';
import 'package:flash_delivery/widgets/profile.dart';
import 'package:flash_delivery/widgets/shop.dart';
import 'package:flash_delivery/widgets/support.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_meedu/consumer/consumer_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:home/home_view/home_screen.dart';
import 'package:repositorie/repositorie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await injectDependencies();

  runApp(
    App(),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationRepositoryImpl>(
            create: (context) =>
                AuthenticationRepositoryImpl(FirebaseAuth.instance)),
        RepositoryProvider<RetrieveImpl>(create: (context) => RetrieveImpl()),
        RepositoryProvider<SignUpRepositoryImpl>(
            create: (context) => SignUpRepositoryImpl(FirebaseAuth.instance)),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, watch, __) {
      return MaterialApp(
        title: 'Flash Delivery',
        debugShowCheckedModeBanner: false,
        routes: appRoutes,
        initialRoute: Routes.home,
      );
    });
  }
}

class MyHomeApp extends StatefulWidget {
  const MyHomeApp({super.key});

  @override
  State<MyHomeApp> createState() => _MyHomeAppState();
}

class _MyHomeAppState extends State<MyHomeApp> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ShopView(),
    SupportView(),
    ProfileView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.shopping_bag,
                  text: 'Shopping',
                ),
                GButton(
                  icon: Icons.support_agent,
                  text: 'Support',
                ),
                GButton(
                  icon: Icons.person_2_outlined,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
