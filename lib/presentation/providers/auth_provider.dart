// lib/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kounselme/data/remote/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());