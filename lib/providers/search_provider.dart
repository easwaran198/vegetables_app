import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateProvider to hold the current search query string
final searchQueryProvider = StateProvider<String>((ref) => '');