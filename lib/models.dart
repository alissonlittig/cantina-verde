/// Prices are integer cents to avoid floating point drift.
class Extra {
  const Extra(this.id, this.name, this.cents);
  final String id;
  final String name;
  final int cents;
}

class Dish {
  const Dish({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.cents,
    required this.tone,
    this.extras = const [],
    this.tag,
  });
  final String id;
  final String category;
  final String name;
  final String description;
  final int cents;
  final int tone; // index into the tile palette
  final List<Extra> extras;
  final String? tag;
}

class CartLine {
  CartLine({required this.dish, required this.extras, required this.qty, this.note = ''});
  final Dish dish;
  final List<Extra> extras;
  int qty;
  final String note;

  int get unitCents => dish.cents + extras.fold(0, (s, e) => s + e.cents);
  int get totalCents => unitCents * qty;

  /// Lines with the same dish, add-ons and note are merged.
  String get key {
    final ids = extras.map((e) => e.id).toList()..sort();
    return '${dish.id}|${ids.join(',')}|${note.trim().toLowerCase()}';
  }
}

enum Fulfilment { delivery, pickup }

enum Payment { pix, card, cash }

String brl(int cents) {
  final neg = cents < 0;
  final c = cents.abs();
  final whole = (c ~/ 100).toString();
  final buf = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buf.write('.');
    buf.write(whole[i]);
  }
  return '${neg ? '-' : ''}R\$ $buf,${(c % 100).toString().padLeft(2, '0')}';
}
