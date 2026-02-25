import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://aoctclprstwwtrttqrcs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvY3RjbHByc3R3d3RydHRxcmNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE4NzA5MDgsImV4cCI6MjA4NzQ0NjkwOH0.3WIjvYMi85lUmlD9HTeB2mMAquw7Y98AXajY1RZr6hk',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  runApp(const TicTacToeApp());
}
