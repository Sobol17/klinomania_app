import '../../domain/entities/service_detail.dart';
import '../../domain/repositories/services_repository.dart';
import '../../../home/domain/entities/cleaning_service.dart';
import '../datasources/services_remote_data_source.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  ServicesRepositoryImpl({required this.remoteDataSource});

  final ServicesRemoteDataSource remoteDataSource;

  @override
  Future<List<CleaningService>> fetchServices() async {
    final items = await remoteDataSource.fetchServices();
    return items.map((item) => item.toEntity()).toList();
  }

  @override
  Future<ServiceDetail> fetchServiceDetail(String id) async {
    final detail = await remoteDataSource.fetchServiceDetail(id);
    return detail.toEntity();
  }
}
