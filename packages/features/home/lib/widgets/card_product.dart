import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:home/widgets/iconFavorite.dart';

class CardProduct extends StatelessWidget {
  final Product product;
  const CardProduct(this.product);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 243, 243, 243),
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(210, 244, 244, 244),
              offset: Offset(
                5.0,
                5.0,
              ),
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(0.0, 0.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: EdgeInsets.all(5),
              height: 115,
              width: 120,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TextBackgroudCategory(
                  category: product.cantidad.toString(),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  width: 195,
                  child: Text(
                    product.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Color.fromARGB(210, 113, 113, 113)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 190,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.valor}",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(118, 141, 0, 0)),
                      ),
                      IconFavorite()
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // private method
}

class _TextBackgroudCategory extends StatelessWidget {
  final String category;
  const _TextBackgroudCategory({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFFFFC5E4), borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 25),
        child: Text(
          category,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
