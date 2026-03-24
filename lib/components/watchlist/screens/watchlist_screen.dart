import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/watchlist_provider.dart';
import '../../analysis/providers/analysis_provider.dart';
import '../../../shared/theme.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: Consumer<WatchlistProvider>(
              builder: (context, provider, child) {
                if (provider.items.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final stock = provider.items[index];
                    return _buildStockItem(context, stock);
                  },
                );
              },
            ),
          ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.star_rounded, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(width: 14),
          const Text(
            '관심종목',
            style: TextStyle(
              color: AppTheme.textMain,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: AppTheme.textMain38),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton.icon(
        onPressed: () => _showAddStockDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('종목 추가'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, color: AppTheme.textMain24, size: 64),
          const SizedBox(height: 16),
          const Text(
            '관심종목이 비어 있습니다.',
            style: TextStyle(color: AppTheme.textMain54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '플러스 버튼을 눌러 종목을 추가하세요.',
            style: TextStyle(color: AppTheme.textMain38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _handleStockSelected(String symbol) {
    context.read<WatchlistProvider>().selectStock(symbol);
    context.read<AnalysisProvider>().selectStock(symbol);
    Navigator.pop(context); // Drawer 닫기
  }

  Widget _buildStockItem(BuildContext context, dynamic stock) {
    final watchlistProvider = context.watch<WatchlistProvider>();
    final isSelected = watchlistProvider.selectedSymbol == stock.symbol;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _handleStockSelected(stock.symbol),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                _buildSymbolIcon(stock.symbol, isSelected),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              stock.name,
                              style: TextStyle(
                                color: AppTheme.textMain,
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (stock.isHolding) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '보유',
                                style: TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stock.symbol,
                        style: const TextStyle(
                          color: AppTheme.textMain38,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primaryBlue, size: 20)
                else
                  _buildActionButtons(context, stock.symbol),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSymbolIcon(String symbol, bool isSelected) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryBlue : AppTheme.primaryBlue.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          symbol.substring(0, 1),
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String symbol) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            context.read<AnalysisProvider>().selectStock(symbol);
            context.read<WatchlistProvider>().selectStock(symbol);
            DefaultTabController.of(context).animateTo(0); // 종목분석 탭
            Navigator.pop(context); // Drawer 닫기
          },
          icon: const Icon(Icons.analytics_outlined, color: AppTheme.textMain54, size: 20),
          tooltip: '종목분석',
        ),
        IconButton(
          onPressed: () => context.read<WatchlistProvider>().removeStock(symbol),
          icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed, size: 20),
          tooltip: '삭제',
        ),
      ],
    );
  }


  void _showAddStockDialog(BuildContext context) {
    _symbolController.clear();
    _nameController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text('종목 추가', style: TextStyle(color: AppTheme.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _symbolController,
              decoration: const InputDecoration(
                labelText: '심볼/코드 (예: 005930)',
                labelStyle: TextStyle(color: AppTheme.textMain54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.textMain24)),
              ),
              style: const TextStyle(color: AppTheme.textMain),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름 (예: 삼성전자)',
                labelStyle: TextStyle(color: AppTheme.textMain54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.textMain24)),
              ),
              style: const TextStyle(color: AppTheme.textMain),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppTheme.textMain54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_symbolController.text.isNotEmpty) {
                context.read<WatchlistProvider>().addStock(
                  _symbolController.text,
                  _nameController.text.isEmpty ? _symbolController.text : _nameController.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}
