import 'package:csv/csv.dart';
import 'package:stock_app/data/CSV/csv_parser.dart';
import 'package:stock_app/domain/model/company_listing.dart';

class CompanyListingsParser implements CsvParser<CompanyListing> {
  @override
  Future<List<CompanyListing>> parse(String csvString) async {
    List<List<dynamic>> csvValues =
        const CsvToListConverter().convert(csvString);

    print("CompanyListingsParser 1 : ${csvValues}");

    csvValues.removeAt(0);

    print("CompanyListingsParser 2 : ${csvValues}");
    return csvValues.map((e) {
      print("CompanyListingsParser 3 : ${csvValues}");
      final symbol = e[0] ?? '';
      final name = e[1] ?? '';
      final exchange = e[2] ?? '';
      return CompanyListing(
        symbol: symbol,
        name: name,
        exchange: exchange,
      );
    }).where((e) {
      print("CompanyListingsParser 4 : ${csvValues}");
      return e.symbol.isNotEmpty && e.name.isNotEmpty && e.exchange.isNotEmpty;
    }).toList();
  }
}
