import 'package:equatable/equatable.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';

class JobCostState extends Equatable {
  final List<JobCostDocument> jobCosts;
  final bool isLoading;
  final String? errorMessage;
  final JobCostDocument? selectedJobCost;

  const JobCostState({
    this.jobCosts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedJobCost,
  });

  JobCostState copyWith({
    List<JobCostDocument>? jobCosts,
    bool? isLoading,
    String? errorMessage,
    JobCostDocument? selectedJobCost,
  }) {
    return JobCostState(
      jobCosts: jobCosts ?? this.jobCosts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedJobCost: selectedJobCost ?? this.selectedJobCost,
    );
  }

  @override
  List<Object?> get props => [
    jobCosts,
    isLoading,
    errorMessage,
    selectedJobCost,
  ];
}
