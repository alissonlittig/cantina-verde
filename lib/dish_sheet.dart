import 'package:flutter/material.dart';

import 'cart.dart';
import 'models.dart';
import 'theme.dart';

Future<void> showDishSheet(BuildContext context, Dish dish, Cart cart) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: _DishForm(dish: dish, cart: cart),
      ),
    );

class _DishForm extends StatefulWidget {
  const _DishForm({required this.dish, required this.cart});
  final Dish dish;
  final Cart cart;

  @override
  State<_DishForm> createState() => _DishFormState();
}

class _DishFormState extends State<_DishForm> {
  final picked = <Extra>{};
  final note = TextEditingController();
  int qty = 1;

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  int get unit => widget.dish.cents + picked.fold(0, (s, e) => s + e.cents);

  @override
  Widget build(BuildContext context) {
    final d = widget.dish;
    final t = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          DishTile(dish: d, size: 72),
          const SizedBox(width: 14),
          Expanded(child: Text(d.name, style: t.headlineSmall)),
        ]),
        const SizedBox(height: 12),
        Text(d.description, style: t.bodyMedium!.copyWith(color: Palette.muted, height: 1.5)),
        if (d.extras.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text('Adicionais', style: t.titleSmall),
          for (final e in d.extras)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              value: picked.contains(e),
              onChanged: (v) => setState(() => v! ? picked.add(e) : picked.remove(e)),
              title: Text(e.name),
              secondary: Text(e.cents == 0 ? 'grátis' : '+ ${brl(e.cents)}', style: const TextStyle(color: Palette.muted)),
            ),
        ],
        const SizedBox(height: 14),
        TextField(
          controller: note,
          maxLength: 80,
          decoration: const InputDecoration(labelText: 'Observação (opcional)', hintText: 'Ex.: sem cebola'),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Qty(value: qty, onChanged: (v) => setState(() => qty = v), min: 1),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () {
                widget.cart.add(d, extras: picked.toList(), qty: qty, note: note.text);
                Navigator.of(context).pop();
              },
              child: FittedBox(fit: BoxFit.scaleDown, child: Text('Adicionar · ${brl(unit * qty)}')),
            ),
          ),
        ]),
      ]),
    );
  }
}

class Qty extends StatelessWidget {
  const Qty({super.key, required this.value, required this.onChanged, this.min = 0});
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(border: Border.all(color: Palette.line), borderRadius: BorderRadius.circular(99), color: Colors.white),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            tooltip: 'Diminuir',
            visualDensity: VisualDensity.compact,
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove, size: 18),
          ),
          SizedBox(width: 24, child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
          IconButton(
            tooltip: 'Aumentar',
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add, size: 18),
          ),
        ]),
      );
}
