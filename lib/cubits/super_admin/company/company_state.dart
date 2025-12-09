import 'package:tilework/models/super_admin/company_model.dart';

class CompanyState {
  final List<CompanyModel> companies;
  final bool isLoading;
  final String? errorMessage;

  CompanyState({
    this.companies = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CompanyState copyWith({
    List<CompanyModel>? companies,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CompanyState(
      companies: companies ?? this.companies,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}