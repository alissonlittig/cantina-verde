import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cart.dart';
import 'dish_sheet.dart';
import 'models.dart';
import 'theme.dart';

class CheckoutPanel extends StatefulWidget {
  const CheckoutPanel({super.key, required this.cart, this.onDone});
  final Cart cart;
  final VoidCallback? onDone;

  @override
  State<CheckoutPanel> createState() => _CheckoutPanelState();
}

class _CheckoutPanelState extends State<CheckoutPanel> {
  final name = TextEditingController();
  final address = TextEditingController();
  final change = TextEditingController();
  Fulfilment fulfilment = Fulfilment.delivery;
  Payment payment = Payment.pix;
  String? error;
  bool showPreview = false;

  @override
  void dispose() {
    name.dispose();
    address.dispose();
    change.dispose();
    super.dispose();
  }

  Customer get customer => Customer(
        name: name.text,
        fulfilment: fulfilment,
        address: address.text,
        payment: payment,
        changeFor: change.text,
      );

  Future<void> _send() async {
    final err = widget.cart.validate(customer);
    setState(() => error = err);
    if (err != null) return;
    await launchUrl(widget.cart.whatsappUri(customer), webOnlyWindowName: '_blank');
  }

  Future<void> _copy() async {
    final err = widget.cart.validate(customer);
    setState(() => error = err);
    if (err != null) return;
    await Clipboard.setData(ClipboardData(text: widget.cart.whatsappMessage(customer)));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mensagem copiada.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: widget.cart,
      builder: (context, _) {
        final cart = widget.cart;
        if (cart.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(children: [
              const Icon(Icons.shopping_bag_outlined, size: 40, color: Palette.muted),
              const SizedBox(height: 12),
              Text('Seu carrinho está vazio', style: t.titleMedium),
              const SizedBox(height: 4),
              Text('Escolha um prato no cardápio para começar.', textAlign: TextAlign.center, style: t.bodySmall!.copyWith(color: Palette.muted)),
            ]),
          );
        }
        final fee = cart.deliveryFee(fulfilment);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Seu pedido', style: t.titleLarge)),
            TextButton(onPressed: cart.clear, child: const Text('Limpar')),
          ]),
          for (final l in cart.lines) _Line(line: l, cart: cart),
          const Divider(height: 28, color: Palette.line),
          SegmentedButton<Fulfilment>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: Fulfilment.delivery, label: Text('Entrega'), icon: Icon(Icons.delivery_dining)),
              ButtonSegment(value: Fulfilment.pickup, label: Text('Retirada'), icon: Icon(Icons.storefront_outlined)),
            ],
            selected: {fulfilment},
            onSelectionChanged: (s) => setState(() => fulfilment = s.first),
          ),
          const SizedBox(height: 14),
          TextField(controller: name, textCapitalization: TextCapitalization.words, autofillHints: const [AutofillHints.name], decoration: const InputDecoration(labelText: 'Seu nome')),
          if (fulfilment == Fulfilment.delivery) ...[
            const SizedBox(height: 12),
            TextField(controller: address, autofillHints: const [AutofillHints.fullStreetAddress], decoration: const InputDecoration(labelText: 'Endereço de entrega', hintText: 'Rua, número, bairro')),
          ],
          const SizedBox(height: 14),
          Text('Pagamento', style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in Payment.values)
              ChoiceChip(
                label: Text(paymentLabel(p)),
                selected: payment == p,
                showCheckmark: false,
                onSelected: (_) => setState(() => payment = p),
              ),
          ]),
          if (payment == Payment.cash) ...[
            const SizedBox(height: 12),
            TextField(controller: change, decoration: const InputDecoration(labelText: 'Troco para (opcional)', hintText: 'R\$ 100,00')),
          ],
          const Divider(height: 28, color: Palette.line),
          _Row('Subtotal', brl(cart.subtotal)),
          if (fulfilment == Fulfilment.delivery) _Row('Entrega', fee == 0 ? 'Grátis' : brl(fee)),
          const SizedBox(height: 6),
          _Row('Total', brl(cart.total(fulfilment)), big: true),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Semantics(
                liveRegion: true,
                child: Text(error!, style: const TextStyle(color: Palette.tomato, fontWeight: FontWeight.w600)),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _send,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1B7F4B),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.send_rounded, size: 20),
            label: const Text('Enviar pedido pelo WhatsApp'),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: _copy, child: const Text('Copiar mensagem'))),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => showPreview = !showPreview),
                child: Text(showPreview ? 'Ocultar prévia' : 'Ver prévia'),
              ),
            ),
          ]),
          if (showPreview)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(14),
              width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFFE7F3E3), borderRadius: BorderRadius.circular(14)),
              child: SelectableText(cart.whatsappMessage(customer), style: const TextStyle(fontSize: 13, height: 1.45)),
            ),
          const SizedBox(height: 10),
          Text('Demonstração: o número de WhatsApp é fictício e nenhum pedido real é feito.', style: t.labelSmall!.copyWith(color: Palette.muted)),
        ]);
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.big = false});
  final String label;
  final String value;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final s = big ? const TextStyle(fontSize: 18, fontWeight: FontWeight.w800) : const TextStyle(color: Palette.muted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: s), Text(value, style: s)]),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.line, required this.cart});
  final CartLine line;
  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final sub = [
      if (line.extras.isNotEmpty) line.extras.map((e) => e.name).join(', '),
      if (line.note.isNotEmpty) 'Obs.: ${line.note}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(line.dish.name, style: t.titleSmall),
            if (sub.isNotEmpty) Text(sub, style: t.bodySmall!.copyWith(color: Palette.muted)),
            const SizedBox(height: 2),
            Text(brl(line.totalCents), style: t.bodySmall!.copyWith(fontWeight: FontWeight.w700, color: Palette.green)),
          ]),
        ),
        const SizedBox(width: 8),
        Qty(value: line.qty, onChanged: (v) => cart.change(line, v - line.qty)),
      ]),
    );
  }
}
