import 'package:flutter/material.dart';

class IconFavorite extends StatefulWidget {
  const IconFavorite({super.key});

  @override
  State<IconFavorite> createState() => _IconFavoriteState();
}

class _IconFavoriteState extends State<IconFavorite> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: const Icon(
        Icons.favorite_border,
        size: 22,
        color: const Color.fromARGB(255, 1, 32, 2),
      ),
      onTap: () {},
    );
  }
}
