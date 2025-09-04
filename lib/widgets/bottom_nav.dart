import 'package:flutter/material.dart';

Widget bottomNav(int selectedIndex, Function(int) onTap) {
  return BottomNavigationBar(
    currentIndex: selectedIndex,
    onTap: onTap,
    selectedItemColor: const Color(0xFF11B5B0),
    unselectedItemColor: Colors.grey,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
      BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Recetas"),
      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Historia"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
    ],
  );
}
