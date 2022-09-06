import 'package:stock_app/data/CSV/company_listings_parser.dart';
import 'package:stock_app/data/mapper/company_mapper.dart';
import 'package:stock_app/data/source/local/stock_dao.dart';
import 'package:stock_app/data/source/remote/stock_api.dart';
import 'package:stock_app/domain/model/company_listing.dart';
import 'package:stock_app/domain/repository/stock_repository.dart';
import 'package:stock_app/util/result.dart';

class StockRepositoryImpl implements StockRepository {
  final StockApi _api;
  final StockDao _dao;
  final _parser = CompanyListingsParser();

  StockRepositoryImpl(this._api, this._dao);

  @override
  Future<Result<List<CompanyListing>>> getCompanyListings(
      bool fetchFromRemote, String query) async {
    // 캐시에서 찾는다
    final localListings = await _dao.searchCompanyListing(query);
    print("StockRepositoryImpl 1 : ${localListings.length}");

    // 없다면 리모트에서 가져온다
    print('StockRepositoryImpl 0 $fetchFromRemote $query');
    final isDbEmpty = localListings.isEmpty && query.isEmpty;
    final shouldJustLoadFromCache = !isDbEmpty && !fetchFromRemote;

    // 캐시
    if (shouldJustLoadFromCache) {
      print("StockRepositoryImpl 2 : ${localListings.length}");
      print("StockRepositoryImpl 2-1 : ${localListings[0].name}");
      return Result.success(
          localListings.map((e) => e.toCompanyListing()).toList());
    }

    // 리모트
    try {
      final response = await _api.getListings();
      print("StockRepositoryImpl 3 : ${response.body}");
      final remoteListings = await _parser.parse(response.body);
      print("StockRepositoryImpl 4 : ${remoteListings.length}");

      // 캐시 비우기
      await _dao.clearCompanyListings();
      print("StockRepositoryImpl 5 : ${remoteListings.length}");

      // 캐시 추가
      await _dao.insertCompanyListings(
          remoteListings.map((e) => e.toCompanyListingEntity()).toList());
      print("StockRepositoryImpl 6 : ${remoteListings.length}");

      return Result.success(remoteListings);
    } catch (e) {
      return Result.error(Exception('데이터 로드 실패'));
    }
  }
}
