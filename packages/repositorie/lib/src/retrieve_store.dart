import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';
import 'package:resource/resource.dart';

class RetrieveImpl implements FireStorage {
  @override
  Future<List<Product>?> retrieve() async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection("productos");

      QuerySnapshot products = await collectionReference.get();

      if (products.docs.isNotEmpty) {
        List<Product> productList = products.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Product(
            name: data['name'] ?? '',
            valor: data['valor'] ?? 0,
            cantidad: data['cantidad'] ?? 0,
          );
        }).toList();

        return productList;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
