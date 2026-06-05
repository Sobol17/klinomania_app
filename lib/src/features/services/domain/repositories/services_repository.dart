import '../../../home/domain/entities/cleaning_service.dart';
import '../entities/service_detail.dart';

abstract class ServicesRepository {
  Future<List<CleaningService>> fetchServices();

  Future<ServiceDetail> fetchServiceDetail(String id);
}
