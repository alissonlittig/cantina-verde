import 'package:flutter/foundation.dart';

import 'models.dart';

const kDeliveryFee = 600;
const kFreeDeliveryFrom = 8000;
const kMinOrder = 2500;
const kWhatsappNumber = '5541900000000'; // fictional demo number

class Customer {
  const Customer({
    this.name = '',
    this.fulfilment = Fulfilment.delivery,
    this.address = '',
    this.payment = Payment.pix,
    this.changeFor = '',
  });
  final String name;
  final Fulfilment fulfilment;
  final String address;
  final Payment payment;
  final String changeFor;
}

class Cart extends ChangeNotifier {
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);
  int get count => _lines.fold(0, (s, l) => s + l.qty);
  int get subtotal => _lines.fold(0, (s, l) => s + l.totalCents);
  bool get isEmpty => _lines.isEmpty;

  int deliveryFee(Fulfilment f) {
    if (f == Fulfilment.pickup || _lines.isEmpty) return 0;
    return subtotal >= kFreeDeliveryFrom ? 0 : kDeliveryFee;
  }

  int total(Fulfilment f) => subtotal + deliveryFee(f);

  void add(Dish dish, {List<Extra> extras = const [], int qty = 1, String note = ''}) {
    final line = CartLine(dish: dish, extras: extras, qty: qty, note: note.trim());
    final i = _lines.indexWhere((l) => l.key == line.key);
    if (i >= 0) {
      _lines[i].qty += qty;
    } else {
      _lines.add(line);
    }
    notifyListeners();
  }

  void change(CartLine line, int delta) {
    line.qty += delta;
    if (line.qty <= 0) _lines.remove(line);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }

  /// Returns an error message, or null when the order can be sent.
  String? validate(Customer c) {
    if (_lines.isEmpty) return 'Seu carrinho está vazio.';
    if (subtotal < kMinOrder) return 'Pedido mínimo de ${brl(kMinOrder)}.';
    if (c.name.trim().length < 2) return 'Informe seu nome.';
    if (c.fulfilment == Fulfilment.delivery && c.address.trim().length < 8) {
      return 'Informe o endereço de entrega (rua, número e bairro).';
    }
    return null;
  }

  String whatsappMessage(Customer c) {
    final b = StringBuffer()
      ..writeln('*Novo pedido — Cantina Verde*')
      ..writeln('Cliente: ${c.name.trim()}')
      ..writeln(c.fulfilment == Fulfilment.delivery
          ? 'Entrega: ${c.address.trim()}'
          : 'Retirada no balcão')
      ..writeln();
    for (final l in _lines) {
      b.writeln('${l.qty}x ${l.dish.name} — ${brl(l.totalCents)}');
      if (l.extras.isNotEmpty) {
        b.writeln('   + ${l.extras.map((e) => e.name).join(', ')}');
      }
      if (l.note.isNotEmpty) b.writeln('   Obs.: ${l.note}');
    }
    final fee = deliveryFee(c.fulfilment);
    b
      ..writeln()
      ..writeln('Subtotal: ${brl(subtotal)}');
    if (c.fulfilment == Fulfilment.delivery) {
      b.writeln('Entrega: ${fee == 0 ? 'grátis' : brl(fee)}');
    }
    b
      ..writeln('*Total: ${brl(total(c.fulfilment))}*')
      ..write('Pagamento: ${paymentLabel(c.payment)}');
    if (c.payment == Payment.cash && c.changeFor.trim().isNotEmpty) {
      b.write(' (troco para ${c.changeFor.trim()})');
    }
    return b.toString();
  }

  Uri whatsappUri(Customer c) =>
      Uri.https('wa.me', '/$kWhatsappNumber', {'text': whatsappMessage(c)});
}

String paymentLabel(Payment p) => switch (p) {
      Payment.pix => 'Pix',
      Payment.card => 'Cartão na entrega',
      Payment.cash => 'Dinheiro',
    };
