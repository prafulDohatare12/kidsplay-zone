import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsplazone/main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text("👤 Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            const Text("Welcome, Kid!", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.brightness_6),
              label: const Text("Toggle Dark/Light Mode"),
              onPressed: () => themeCubit.toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}
