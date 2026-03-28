import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/manual_portfolio_provider.dart';
import '../models/stock.dart';
import '../../../shared/theme.dart';

class AddStockBottomSheet extends StatefulWidget {
  const AddStockBottomSheet({super.key});

  @override
  State<AddStockBottomSheet> createState() => _AddStockBottomSheetState();
}

class _AddStockBottomSheetState extends State<AddStockBottomSheet> {
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: 32,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '새 종목 추가',
            style: TextStyle(color: AppTheme.textMain, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildField('종목명', '예: 삼성전자', _nameController),
          const SizedBox(height: 16),
          _buildField('종목코드', '예: 005930', _symbolController),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildField('보유수량', '0', _quantityController, isNumber: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildField('매수평단', '0', _priceController, isNumber: true)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty || _symbolController.text.isEmpty) return;
                
                final stock = Stock(
                  id: _symbolController.text.trim(),
                  symbol: _symbolController.text.trim(),
                  name: _nameController.text.trim(),
                  quantity: double.tryParse(_quantityController.text) ?? 0,
                  purchasePrice: double.tryParse(_priceController.text) ?? 0,
                  currentPrice: double.tryParse(_priceController.text) ?? 0,
                );
                
                context.read<ManualPortfolioProvider>().addStock(stock);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.textMain,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('추가하기', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMain54, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: AppTheme.textMain),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textMain24),
            filled: true,
            fillColor: AppTheme.textMain.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
