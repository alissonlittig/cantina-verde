import 'package:flutter/material.dart';

import 'cart.dart';
import 'checkout.dart';
import 'data.dart';
import 'dish_sheet.dart';
import 'models.dart';
import 'theme.dart';

void main() => runApp(const CantinaApp());

class CantinaApp extends StatelessWidget {
  const CantinaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Cantina Verde',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const MenuPage(),
      );
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, this.cart});
  final Cart? cart;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late final Cart cart = widget.cart ?? Cart();
  String category = categories.first;

  void _openCart() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        constraints: const BoxConstraints(maxWidth: 560),
        builder: (_) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: CheckoutPanel(cart: cart, onDone: () => Navigator.of(context).maybePop()),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;
    final dishes = menu.where((d) => d.category == category).toList();
    final list = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Hero(wide: wide)),
        SliverPersistentHeader(pinned: true, delegate: _Chips(category, (c) => setState(() => category = c))),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(wide ? 0 : 16, 8, wide ? 0 : 16, wide ? 40 : 110),
          sliver: SliverList.separated(
            itemCount: dishes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => DishCard(dish: dishes[i], cart: cart),
          ),
        ),
      ],
    );

    return Scaffold(
      body: wide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Padding(padding: const EdgeInsets.only(right: 32), child: list)),
                  SizedBox(
                    width: 400,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 32, 0, 32),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Palette.card,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Palette.line),
                          boxShadow: Palette.shadow,
                        ),
                        child: CheckoutPanel(cart: cart),
                      ),
                    ),
                  ),
                ]),
              ),
            )
          : list,
      bottomNavigationBar: wide
          ? null
          : ListenableBuilder(
              listenable: cart,
              builder: (_, __) => cart.isEmpty
                  ? const SizedBox.shrink()
                  : SafeArea(
                      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: FilledButton(
                        onPressed: _openCart,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(58),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: Row(children: [
                          Badge.count(count: cart.count, backgroundColor: Palette.gold, textColor: Palette.green, child: const Icon(Icons.shopping_bag_outlined)),
                          const SizedBox(width: 16),
                          const Expanded(child: Text('Ver carrinho', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                          Text(brl(cart.subtotal), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ]),
                      ),
                    ),
            ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.fromLTRB(wide ? 0 : 12, wide ? 32 : 12, wide ? 0 : 12, 8),
      padding: EdgeInsets.all(wide ? 36 : 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Palette.green, Palette.greenDeep]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('COZINHA ITALIANA · CURITIBA', style: t.labelSmall!.copyWith(color: Palette.gold, letterSpacing: 1.6, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text('Cantina Verde', style: t.displaySmall!.copyWith(color: Colors.white)),
        const SizedBox(height: 8),
        Text('Massas frescas e pizzas de longa fermentação. Monte o pedido e envie direto para o nosso WhatsApp.',
            style: t.bodyMedium!.copyWith(color: const Color(0xFFDCE6DD), height: 1.5)),
        const SizedBox(height: 18),
        const Wrap(spacing: 8, runSpacing: 8, children: [
          _Info(Icons.schedule, 'Aberto até 23h'),
          _Info(Icons.delivery_dining, '35–45 min'),
          _Info(Icons.local_offer_outlined, 'Grátis acima de R\$ 80'),
        ]),
      ]),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: Palette.gold),
          const SizedBox(width: 6),
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500))),
        ]),
      );
}

class _Chips extends SliverPersistentHeaderDelegate {
  _Chips(this.selected, this.onSelect);
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrink, bool overlaps) => Container(
        color: Palette.bg,
        alignment: Alignment.center,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = categories[i];
            final on = c == selected;
            return Center(
              child: ChoiceChip(
                label: Text(c),
                avatar: Icon(categoryIcon(c), size: 18, color: on ? Palette.green : Palette.muted),
                selected: on,
                showCheckmark: false,
                onSelected: (_) => onSelect(c),
              ),
            );
          },
        ),
      );

  @override
  bool shouldRebuild(_Chips old) => old.selected != selected;
}

class DishCard extends StatelessWidget {
  const DishCard({super.key, required this.dish, required this.cart});
  final Dish dish;
  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: Palette.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showDishSheet(context, dish, cart),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Palette.line)),
          child: Row(children: [
            DishTile(dish: dish, size: 92),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (dish.tag != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(dish.tag!.toUpperCase(), style: t.labelSmall!.copyWith(color: Palette.tomato, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
                  ),
                Text(dish.name, style: t.titleMedium),
                const SizedBox(height: 4),
                Text(dish.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodySmall!.copyWith(color: Palette.muted, height: 1.4)),
                const SizedBox(height: 8),
                Text(brl(dish.cents), style: t.titleSmall!.copyWith(color: Palette.green, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Adicionar ${dish.name}',
              onPressed: () => showDishSheet(context, dish, cart),
              icon: const Icon(Icons.add),
            ),
          ]),
        ),
      ),
    );
  }
}
