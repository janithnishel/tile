import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/repositories/auth_repository.dart';
import 'package:tilework/routes/company_routes.dart';
import 'package:tilework/services/api_service.dart';

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
