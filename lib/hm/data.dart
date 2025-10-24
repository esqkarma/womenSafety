import 'package:shecare/hm/models/cart_item.dart';
import 'package:shecare/hm/models/plant.dart';
import 'package:shecare/hm/models/recently_viewed.dart';

List<Plant> recommended = [
  Plant(
    plantType: 'Emergency Call',
    plantName: '',
    plantPrice: 80.0,
    stars: 4.0,
    metrics: PlantMetrics('8.2"', '52%', '4.2"'),
    image: 'assets/emerg.png',
  ),
  Plant(
    plantType: 'Dangerous Spot',
    plantName: 'Dangerous Spot',
    plantPrice: 480.0,
    stars: 3.5,
    metrics: PlantMetrics('8.2"', '52%', '4.2"'),
    image: 'assets/add dangerous spot.png',
  ),
  Plant(
    plantType: 'View All Dangerous Spot',
    plantName: 'View All Dangerous Spot',
    plantPrice: 600.0,
    stars: 3.0,
    metrics: PlantMetrics('8.2"', '52%', '4.2"'),
    image: 'assets/view all dangerous spot.jpg',
  ),
  Plant(
    plantType: 'View My Dangerous Spot',
    plantName: 'View My Dangerous Spot',
    plantPrice: 4000.0,
    stars: 4.0,
    metrics: PlantMetrics('8.2"', '52%', '4.2"'),
    image: 'assets/view my dangerous spot.jpg',
  ),
  Plant(
    plantType: 'Send Visuals',
    plantName: 'Send Visuals',
    plantPrice: 2000.0,
    stars: 3.5,
    metrics: PlantMetrics('8.2"', '52%', '4.2"'),
    image: 'images/Juniper_Bonsai.png',
  ),
];

List<ViewHistory> viewed = [
  ViewHistory('Calathea', 'It\'s spines don\'t grow.', 'images/calathea.jpg'),
  ViewHistory('Cactus', 'It has spines.', 'images/cactus.jpg'),
  ViewHistory('Stephine', 'It\'s spines do grow.', 'images/stephine_2.jpg'),
];

List<CartItem> cartItems = [
  CartItem(
    Plant(
      plantType: 'Indoor',
      plantName: 'Calathea',
      plantPrice: 100,
      image: 'images/calathea.jpg',
      stars: 3.5,
      metrics: PlantMetrics('', '', ''),
    ),
    2,
  ),
  CartItem(
    Plant(
      plantType: 'Indoor',
      plantName: 'Cactus',
      plantPrice: 100,
      image: 'images/cactus.jpg',
      stars: 3.5,
      metrics: PlantMetrics('', '', ''),
    ),
    2,
  ),
  CartItem(
    Plant(
      plantType: 'Indoor',
      plantName: 'Calathea',
      plantPrice: 100,
      image: 'images/calathea.jpg',
      stars: 3.5,
      metrics: PlantMetrics('', '', ''),
    ),
    2,
  ),
  CartItem(
    Plant(
      plantType: 'Indoor',
      plantName: 'Calathea',
      plantPrice: 100,
      image: 'images/calathea.jpg',
      stars: 3.5,
      metrics: PlantMetrics('', '', ''),
    ),
    2,
  ),
];
