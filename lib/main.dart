import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/dashboard/dashboard_cubit.dart' as user_dashboard;
import 'package:tilework/cubits/job_cost/job_cost_cubit.dart';
import 'package:tilework/cubits/material_sale/material_sale_cubit.dart';
import 'package:tilework/cubits/purchase_order/purchase_order_cubit.dart';
import 'package:tilework/cubits/quotation/quotation_cubit.dart';
import 'package:tilework/cubits/reports/reports_cubit.dart';
import 'package:tilework/cubits/super_admin/category/category_cubit.dart';
import 'package:tilework/cubits/super_admin/company/company_cubit.dart';
import 'package:tilework/cubits/super_admin/dashboard/dashboard_cubit.dart' as super_admin_dashboard;
import 'package:tilework/cubits/supplier/supplier_cubit.dart';
import 'package:tilework/repositories/auth/auth_repository.dart';
import 'package:tilework/repositories/dashboard/dashboard_repository.dart';
import 'package:tilework/repositories/job_cost/job_cost_repository.dart';
import 'package:tilework/repositories/material_sale/material_sale_repository.dart';
import 'package:tilework/repositories/purchase_order/purchase_order_repository.dart';
import 'package:tilework/repositories/quotation/quotation_repository.dart';
import 'package:tilework/repositories/reports/reports_repository.dart';
import 'package:tilework/repositories/super_admin/company_repository.dart';
import 'package:tilework/repositories/super_admin/category_repository.dart';
import 'package:tilework/repositories/super_admin/dashboard_repository.dart' as super_admin_dashboard_repo;
import 'package:tilework/repositories/supplier/supplier_repository.dart';
import 'package:tilework/routes/company_routes.dart';
import 'package:tilework/services/auth/api_service.dart';
import 'package:tilework/services/dashboard/api_service.dart';
import 'package:tilework/services/job_cost/api_service.dart';
import 'package:tilework/services/material_sale/material_sale_api_service.dart';
import 'package:tilework/services/purchase_order/api_service.dart';
import 'package:tilework/services/quotation/quotation_api_service.dart';
import 'package:tilework/services/reports/api_service.dart';
import 'package:tilework/services/super_admin/company_api_service.dart';
import 'package:tilework/services/supplier/api_service.dart';

// -----------------------------------------------------------------------------
// MAIN APP
// -----------------------------------------------------------------------------

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(
            AuthRepository(ApiService()),
          ),
        ),
        BlocProvider(
          create: (context) => CompanyCubit(
            CompanyRepository(CompanyApiService()),
          ),
        ),
        BlocProvider(
          create: (context) => CategoryCubit(
            CategoryRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => user_dashboard.DashboardCubit(
            DashboardRepository(DashboardApiService()),
            context.read<AuthCubit>(),
          ),
        ),
        BlocProvider(
          create: (context) => QuotationCubit(
            QuotationRepository(QuotationApiService()),
            context.read<AuthCubit>(),
          ),
        ),
        BlocProvider(
          create: (context) => MaterialSaleCubit(
            MaterialSaleRepository(MaterialSaleApiService()),
            context.read<AuthCubit>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => SupplierRepository(SupplierApiService()),
        ),
        BlocProvider(
          create: (context) => SupplierCubit(
            context.read<SupplierRepository>(),
            context.read<AuthCubit>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => PurchaseOrderRepository(PurchaseOrderApiService()),
        ),
        BlocProvider(
          create: (context) => PurchaseOrderCubit(
            context.read<PurchaseOrderRepository>(),
            context.read<AuthCubit>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => JobCostRepository(JobCostApiService()),
        ),
        BlocProvider(
          create: (context) => JobCostCubit(
            context.read<JobCostRepository>(),
            context.read<AuthCubit>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => ReportsRepository(ReportsApiService()),
        ),
        BlocProvider(
          create: (context) => ReportsCubit(
            context.read<ReportsRepository>(),
            context.read<AuthCubit>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'TileWork',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        routerConfig: appRouter,
      ),
    );
  }
}
