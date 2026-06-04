import 'package:flutter/material.dart';

class Animal {
  final String id;
  final String name;
  final String nameId;
  final String imagePath;
  final Color color;
  final String sound;

  const Animal({
    required this.id,
    required this.name,
    required this.nameId,
    required this.imagePath,
    required this.color,
    required this.sound,
  });
}

const List<Animal> allAnimals = [
  Animal(
    id: 'lion',
    name: 'Lion',
    nameId: 'Singa',
    imagePath: 'assets/images/lion.png',
    color: Color(0xFFFFA726),
    sound: 'Roar!',
  ),
  Animal(
    id: 'elephant',
    name: 'Elephant',
    nameId: 'Gajah',
    imagePath: 'assets/images/elephant.png',
    color: Color(0xFF90A4AE),
    sound: 'Trumpet!',
  ),
  Animal(
    id: 'giraffe',
    name: 'Giraffe',
    nameId: 'Jerapah',
    imagePath: 'assets/images/giraffe.png',
    color: Color(0xFFFFD54F),
    sound: 'Hmm!',
  ),
  Animal(
    id: 'panda',
    name: 'Panda',
    nameId: 'Panda',
    imagePath: 'assets/images/panda.png',
    color: Color(0xFF78909C),
    sound: 'Squeak!',
  ),
  Animal(
    id: 'monkey',
    name: 'Monkey',
    nameId: 'Monyet',
    imagePath: 'assets/images/monkey.png',
    color: Color(0xFFA1887F),
    sound: 'Ooh ooh!',
  ),
  Animal(
    id: 'fox',
    name: 'Fox',
    nameId: 'Rubah',
    imagePath: 'assets/images/fox.png',
    color: Color(0xFFFF7043),
    sound: 'Yap!',
  ),
  Animal(
    id: 'rabbit',
    name: 'Rabbit',
    nameId: 'Kelinci',
    imagePath: 'assets/images/rabbit.png',
    color: Color(0xFFCE93D8),
    sound: 'Squeak!',
  ),
  Animal(
    id: 'tiger',
    name: 'Tiger',
    nameId: 'Harimau',
    imagePath: 'assets/images/tiger.png',
    color: Color(0xFFFF8F00),
    sound: 'Roar!',
  ),
];
