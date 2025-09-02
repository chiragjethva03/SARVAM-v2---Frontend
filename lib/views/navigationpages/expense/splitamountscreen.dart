import 'package:flutter/material.dart';

class SplitAmountScreen extends StatefulWidget {
  final List<Map<String, dynamic>> participants; // [{name,isCurrent,userId?,mobile?},...]
  final double totalAmount;
  final String currentUser;
  final Map<String, double>? initialSplits;

  const SplitAmountScreen({
    super.key,
    required this.participants,
    required this.totalAmount,
    required this.currentUser,
    this.initialSplits,
  });

  @override
  State<SplitAmountScreen> createState() => _SplitAmountScreenState();
}

class _SplitAmountScreenState extends State<SplitAmountScreen> {
  late Map<String, TextEditingController> _controllers;
  double _remaining = 0.0;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final equal = (widget.participants.isEmpty)
        ? 0.0
        : widget.totalAmount / widget.participants.length;

    _controllers = {
      for (final p in widget.participants)
        p["name"] as String: TextEditingController(
          text: widget.initialSplits != null &&
                  widget.initialSplits!.containsKey(p["name"])
              ? widget.initialSplits![p["name"]]!.toStringAsFixed(2)
              : equal.toStringAsFixed(2),
        ),
    };

    _recalcRemaining();
  }

  void _recalcRemaining() {
    final sum = _controllers.values.fold<double>(
        0.0, (a, c) => a + (double.tryParse(c.text.trim()) ?? 0.0));
    setState(() =>
        _remaining = double.parse((widget.totalAmount - sum).toStringAsFixed(2)));
  }

  void _resetEqual() {
    final equal = (widget.participants.isEmpty)
        ? 0.0
        : widget.totalAmount / widget.participants.length;
    for (final entry in _controllers.entries) {
      entry.value.text = equal.toStringAsFixed(2);
    }
    _recalcRemaining();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBalanced = _remaining == 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Split Amount"),
        actions: [
          TextButton(
            onPressed: () {
              final splits = <String, double>{};
              for (final p in widget.participants) {
                final name = p["name"] as String;
                final amount =
                    double.tryParse(_controllers[name]!.text.trim()) ?? 0.0;
                splits[name] = double.parse(amount.toStringAsFixed(2));
              }
              if (_remaining != 0.0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Remaining must be 0. Adjust amounts.")));
                return;
              }
              Navigator.pop(context, {"method": "custom", "splits": splits});
            },
            child: const Text("Done",
                style: TextStyle(color: Color(0xFF000000))),
          ),
          IconButton(
            tooltip: "Reset equal",
            onPressed: _resetEqual,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: widget.participants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, i) {
                final name = widget.participants[i]["name"] as String;
                final isCurrent =
                    (widget.participants[i]["isCurrent"] as bool?) ?? false;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isCurrent ? "$name" : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF263238)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("₹",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF263238))),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _controllers[name],
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            textAlign: TextAlign.left,
                            onChanged: (_) => _recalcRemaining(),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 3),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFF263238), width: 2),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF263238)),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            color: Colors.grey.shade100,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBalanced
                      ? "All balanced ✅"
                      : "Remaining: ₹${_remaining.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isBalanced ? const Color(0xFF0059FF) : Colors.red,
                  ),
                ),
                Text("Total: ₹${widget.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
