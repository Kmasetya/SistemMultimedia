import 'package:flutter/material.dart';

class Animal {
  final String id;
  final String name;
  final String nameId;
  final String imagePath;
  final Color color;
  final String sound;
  final String audioPath;

  const Animal({
    required this.id,
    required this.name,
    required this.nameId,
    required this.imagePath,
    required this.color,
    required this.sound,
    required this.audioPath,
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
    audioPath: 'audio/singa.mp3',
  ),
  Animal(
    id: 'elephant',
    name: 'Elephant',
    nameId: 'Gajah',
    imagePath: 'assets/images/elephant.png',
    color: Color(0xFF90A4AE),
    sound: 'Trumpet!',
    audioPath: 'audio/gajah.mp3',
  ),
  Animal(
    id: 'kambing',
    name: 'Goat',
    nameId: 'Kambing',
    imagePath: 'assets/images/Kambing.png',
    color: Color(0xFFBCAAA4),
    sound: 'Mbee!',
    audioPath: 'audio/kambing.mp3',
  ),
  Animal(
    id: 'merak',
    name: 'Peacock',
    nameId: 'Merak',
    imagePath: 'assets/images/Merak.png',
    color: Color(0xFF26A69A),
    sound: 'Kwak!',
    audioPath: 'audio/merak.mp3',
  ),
  Animal(
    id: 'monkey',
    name: 'Monkey',
    nameId: 'Monyet',
    imagePath: 'assets/images/monkey.png',
    color: Color(0xFFA1887F),
    sound: 'Ooh ooh!',
    audioPath: 'audio/monyet.mp3',
  ),
  Animal(
    id: 'ayam',
    name: 'Chicken',
    nameId: 'Ayam',
    imagePath: 'assets/images/Ayam.png',
    color: Color(0xFFEF5350),
    sound: 'Kukuruyuk!',
    audioPath: 'audio/ayam.mp3',
  ),
  Animal(
    id: 'katak',
    name: 'Frog',
    nameId: 'Katak',
    imagePath: 'assets/images/Katak.png',
    color: Color(0xFF66BB6A),
    sound: 'Koak koak!',
    audioPath: 'audio/katak.mp3',
  ),
  Animal(
    id: 'tiger',
    name: 'Tiger',
    nameId: 'Harimau',
    imagePath: 'assets/images/tiger.png',
    color: Color(0xFFFF8F00),
    sound: 'Ambatukam!',
    audioPath: 'audio/ambatukam.mp3',
  ),
];
