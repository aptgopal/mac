import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/hotels/manage_hotels_screen.dart';
import 'screens/rooms/manage_rooms_screen.dart';
import 'screens/bookings/manage_bookings_screen.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF003580);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()..scaffoldKey = rootScaffoldMessengerKey),
      ],
      child: MaterialApp(
        title: 'Lodge Booking — Admin',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.light,
            primary: seed,
            secondary: const Color(0xFF0099FF),
            surface: const Color(0xFFF8F9FA),
            error: const Color(0xFFD32F2F),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme().copyWith(
            headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 28),
            headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 24),
            titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20),
            titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
            bodyLarge: GoogleFonts.inter(fontSize: 16),
            bodyMedium: GoogleFonts.inter(fontSize: 14),
            labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: seed,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: seed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: seed,
              side: const BorderSide(color: seed),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: seed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
            labelStyle: GoogleFonts.inter(color: Colors.grey.shade700),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            backgroundColor: Colors.white,
            selectedItemColor: seed,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          dividerTheme: DividerThemeData(
            color: Colors.grey.shade200,
            thickness: 1,
            space: 1,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/hotels': (context) => ManageHotelsScreen(),
          '/rooms': (context) => ManageRoomsScreen(),
          '/bookings': (context) => ManageBookingsScreen(),
        },
      ),
    );
  }
}
