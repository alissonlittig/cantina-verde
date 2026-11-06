import 'package:cantina_verde/cart.dart';
import 'package:cantina_verde/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('add a dish with an add-on from the menu to the cart', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cart = Cart();
    await tester.pumpWidget(MaterialApp(home: MenuPage(cart: cart)));

    await tester.tap(find.text('Pizzas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Margherita'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borda recheada'));
    await tester.pump();
    expect(find.textContaining('R\$ 61,00'), findsWidgets);
    await tester.tap(find.textContaining('Adicionar ·'));
    await tester.pumpAndSettle();

    expect(cart.count, 1);
    expect(cart.subtotal, 6100);
    expect(find.text('Ver carrinho'), findsOneWidget);
  });

  testWidgets('checkout shows a validation error when the name is missing', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cart = Cart();
    await tester.pumpWidget(MaterialApp(home: MenuPage(cart: cart)));
    await tester.tap(find.text('Pizzas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Adicionar Margherita'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Adicionar ·'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver carrinho'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Enviar pedido pelo WhatsApp'));
    await tester.tap(find.text('Enviar pedido pelo WhatsApp'));
    await tester.pump();
    expect(find.text('Informe seu nome.'), findsOneWidget);
  });
}
