import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ukur_client/models/customer.dart';
import 'package:ukur_client/pages/detail_page.dart';
import 'package:ukur_client/services/customer_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('ukur_client_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CustomerAdapter());
    }
    await CustomerService.init();
  });

  tearDown(() async {
    if (Hive.isBoxOpen('customers')) {
      await CustomerService.box.close();
    }
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets(
      'detail page should pop back to home once after deleting customer',
      (tester) async {
    final customer = Customer(
      id: 'customer-1',
      nama: 'Budi',
      jenisPakaian: 'Atasan',
      ukuran: {'lingkar dada': 90},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await CustomerService.addCustomer(customer);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(customerId: customer.id),
                  ),
                ),
                child: const Text('Home'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(DetailPage), findsOneWidget);

    await CustomerService.deleteCustomer(customer.id);
    await tester.pumpAndSettle();

    expect(find.byType(DetailPage), findsNothing);
    expect(find.text('Home'), findsOneWidget);
  });
}
