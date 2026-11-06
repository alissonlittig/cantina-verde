import 'package:cantina_verde/cart.dart';
import 'package:cantina_verde/data.dart';
import 'package:cantina_verde/models.dart';
import 'package:flutter_test/flutter_test.dart';

Dish dish(String id) => menu.firstWhere((d) => d.id == id);

void main() {
  test('brl formats cents with thousands separator', () {
    expect(brl(0), 'R\$ 0,00');
    expect(brl(605), 'R\$ 6,05');
    expect(brl(123456), 'R\$ 1.234,56');
  });

  test('add-ons change the unit price', () {
    final c = Cart();
    final m = dish('mar');
    c.add(m, extras: [m.extras[0]], qty: 2);
    expect(c.subtotal, (5200 + 900) * 2);
    expect(c.count, 2);
  });

  test('identical lines merge; different add-ons or notes stay apart', () {
    final c = Cart();
    final m = dish('mar');
    c.add(m);
    c.add(m);
    expect(c.lines.length, 1);
    expect(c.lines.first.qty, 2);
    c.add(m, extras: [m.extras.first]);
    c.add(m, note: 'sem manjericão');
    expect(c.lines.length, 3);
  });

  test('decreasing to zero removes the line', () {
    final c = Cart();
    c.add(dish('ref'));
    c.change(c.lines.first, -1);
    expect(c.isEmpty, isTrue);
  });

  test('delivery fee: charged below threshold, free above, none for pickup', () {
    final c = Cart();
    c.add(dish('mar')); // 52,00
    expect(c.deliveryFee(Fulfilment.delivery), kDeliveryFee);
    expect(c.deliveryFee(Fulfilment.pickup), 0);
    c.add(dish('qua')); // 114,00
    expect(c.deliveryFee(Fulfilment.delivery), 0);
    expect(c.total(Fulfilment.delivery), c.subtotal);
  });

  test('validation: empty cart, minimum order, name and address', () {
    final c = Cart();
    expect(c.validate(const Customer()), isNotNull);
    c.add(dish('ref'));
    expect(c.validate(const Customer(name: 'Ana')), contains('mínimo'));
    c.add(dish('mar'));
    expect(c.validate(const Customer()), contains('nome'));
    expect(c.validate(const Customer(name: 'Ana')), contains('endereço'));
    expect(c.validate(const Customer(name: 'Ana', fulfilment: Fulfilment.pickup)), isNull);
    expect(c.validate(const Customer(name: 'Ana', address: 'Rua das Flores, 10, Centro')), isNull);
  });

  test('WhatsApp message lists items, add-ons, totals and payment', () {
    final c = Cart();
    final m = dish('mar');
    c.add(m, extras: [m.extras.first], note: 'bem assada');
    const cust = Customer(name: 'Ana', address: 'Rua das Flores, 10, Centro', payment: Payment.cash, changeFor: 'R\$ 100');
    final msg = c.whatsappMessage(cust);
    expect(msg, contains('1x Margherita — R\$ 61,00'));
    expect(msg, contains('+ Borda recheada'));
    expect(msg, contains('Obs.: bem assada'));
    expect(msg, contains('Entrega: R\$ 6,00'));
    expect(msg, contains('*Total: R\$ 67,00*'));
    expect(msg, contains('Dinheiro (troco para R\$ 100)'));
  });

  test('WhatsApp link targets wa.me with an encoded text', () {
    final c = Cart()..add(dish('mar'));
    final uri = c.whatsappUri(const Customer(name: 'Ana', fulfilment: Fulfilment.pickup));
    expect(uri.host, 'wa.me');
    expect(uri.path, '/$kWhatsappNumber');
    expect(uri.queryParameters['text'], contains('Retirada no balcão'));
  });
}
