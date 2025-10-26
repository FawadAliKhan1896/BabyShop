class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.image,
  });
}

List<Product> demoProducts = [
  Product(
    id: "1",
    name: "Rolex Submariner",
    brand: "Rolex",
    price: 12500,
    image: "assets/images/download (1).jpg",
  ),
  Product(
    id: "2",
    name: "Omega Speedmaster",
    brand: "Omega",
    price: 8000,
    image: "assets/images/download (2).jpg",
  ),
  Product(
    id: "3",
    name: "Tag Heuer Carrera",
    brand: "Tag Heuer",
    price: 4500,
    image: "assets/images/download.jpg",
  ),
   Product(
    id: "4",
    name: "Tag Heuer Carrera",
    brand: "Tag Heuer",
    price: 4500,
    image: "assets/images/download.jpg",
  ),
   Product(
    id: "5",
    name: "Tag Heuer Carrera",
    brand: "Tag Heuer",
    price: 4500,
    image: "assets/images/download.jpg",
  ),
   Product(
    id: "",
    name: "Tag Heuer Carrera",
    brand: "Tag Heuer",
    price: 4500,
    image: "assets/images/download.jpg",
  ),
];
