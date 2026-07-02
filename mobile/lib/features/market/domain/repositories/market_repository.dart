import 'package:farmtec/features/market/data/models/commodity_model.dart';

abstract class MarketRepository {
  Future<List<CommodityModel>> fetchCommodities();
}
