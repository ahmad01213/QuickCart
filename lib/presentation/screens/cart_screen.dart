import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../cubit/cart/cart_cubit.dart';
import '../cubit/cart/cart_state.dart';
import 'product_details_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.productRepository,
  });

  final ProductRepository productRepository;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product> _allProducts = [];
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedIds.clear();
    });
  }

  void _toggleItemSelection(int productId) {
    setState(() {
      if (_selectedIds.contains(productId)) {
        _selectedIds.remove(productId);
      } else {
        _selectedIds.add(productId);
      }
    });
  }

  void _bulkDelete(CartCubit cubit) {
    final toRemove = cubit.state.items
        .where((e) => _selectedIds.contains(e.product.id))
        .toList();
    for (final item in toRemove) {
      cubit.remove(item.product);
    }
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  void _confirmRemove(BuildContext context, CartItem item, VoidCallback onRemove) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text(
          'هل تريد إزالة "${item.product.title}" من السلة؟',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'حذف',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true) onRemove();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final list = await widget.productRepository.getProducts();
      if (mounted) setState(() => _allProducts = list);
    } catch (_) {}
  }

  List<Product> _getRelatedProducts(List<CartItem> cartItems) {
    if (cartItems.isEmpty || _allProducts.isEmpty) return [];
    final cartIds = cartItems.map((e) => e.product.id).toSet();
    final cartCategories = cartItems
        .map((e) => e.product.category)
        .where((c) => c.isNotEmpty)
        .toSet();
    if (cartCategories.isEmpty) return [];
    final related = _allProducts
        .where((p) =>
            !cartIds.contains(p.id) &&
            cartCategories.contains(p.category))
        .toList();
    return related.take(8).toList();
  }

  List<Product> _getRecommendedProducts(List<CartItem> cartItems) {
    if (_allProducts.isEmpty) return [];
    final cartIds = cartItems.map((e) => e.product.id).toSet();
    final related = _getRelatedProducts(cartItems);
    final relatedIds = related.map((e) => e.id).toSet();
    final others = _allProducts
        .where((p) => !cartIds.contains(p.id) && !relatedIds.contains(p.id))
        .toList();
    return others.take(8).toList();
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ProductDetailsScreen(
          product: product,
          productRepository: widget.productRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primary.withValues(alpha: 0.08),
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                  stops: const [0.0, 0.2, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAppBar(context, primary),
                  Expanded(
                    child: BlocBuilder<CartCubit, CartState>(
                      builder: (context, state) {
                        if (state.items.isEmpty) {
                          return _buildEmptyCart(context);
                        }
                        final related = _getRelatedProducts(state.items);
                        final recommended = _getRecommendedProducts(state.items);

                        return CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                                child: Text(
                                  'عناصر السلة',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = state.items[index];
                                  final isSelected = _selectedIds.contains(item.product.id);
                                  return _CartItemTile(
                                    item: item,
                                    primary: primary,
                                    isSelectionMode: _isSelectionMode,
                                    isSelected: isSelected,
                                    onToggleSelect: () => _toggleItemSelection(item.product.id),
                                    onRemoveRequest: () => _confirmRemove(
                                      context,
                                      item,
                                      () => context.read<CartCubit>().remove(item.product),
                                    ),
                                    onQuantityChanged: (qty) => context
                                        .read<CartCubit>()
                                        .setQuantity(item.product, qty),
                                    onTap: () {
                                      if (_isSelectionMode) {
                                        _toggleItemSelection(item.product.id);
                                      } else {
                                        _openProduct(item.product);
                                      }
                                    },
                                  );
                                },
                                childCount: state.items.length,
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 24)),
                            SliverToBoxAdapter(
                              child: _buildSummarySection(context, state, primary),
                            ),
                            if (_allProducts.isNotEmpty) ...[
                              const SliverToBoxAdapter(child: SizedBox(height: 28)),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'منتجات ذات صلة',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(child: SizedBox(height: 12)),
                              SliverToBoxAdapter(
                                child: _buildProductHorizontalList(
                                  context,
                                  related,
                                  primary,
                                ),
                              ),
                              const SliverToBoxAdapter(child: SizedBox(height: 28)),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'مناسب لك',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(child: SizedBox(height: 12)),
                              SliverToBoxAdapter(
                                child: _buildProductHorizontalList(
                                  context,
                                  recommended,
                                  primary,
                                ),
                              ),
                            ],
                            const SliverToBoxAdapter(child: SizedBox(height: 100)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) return const SizedBox.shrink();
                  return _buildCheckoutBar(context, state, primary);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHorizontalList(
    BuildContext context,
    List<Product> products,
    Color primary,
  ) {
    if (products.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = products[index];
          return _CartProductCard(
            product: p,
            primary: primary,
            onTap: () => _openProduct(p),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_isSelectionMode) {
                _toggleSelectionMode();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Boxicons.bx_chevron_right, size: 28),
            color: const Color(0xFF1F2937),
          ),
          Expanded(
            child: Text(
              _isSelectionMode
                  ? (_selectedIds.isEmpty
                      ? 'تحديد العناصر'
                      : '${_selectedIds.length} محدد')
                  : 'سلة المشتريات',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                  ),
            ),
          ),
          if (_isSelectionMode)
            IconButton(
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () {
                      final cubit = context.read<CartCubit>();
                      _bulkDelete(cubit);
                    },
              icon: const Icon(Boxicons.bx_trash, size: 24),
              color: _selectedIds.isEmpty
                  ? Colors.grey
                  : Theme.of(context).colorScheme.error,
            )
          else
            TextButton(
              onPressed: _toggleSelectionMode,
              child: Text(
                'تحديد',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Boxicons.bx_shopping_bag,
                size: 64,
                color: primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'سلة المشتريات فارغة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'أضف منتجات من المتجر لتظهر هنا',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    CartState state,
    Color primary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الطلب',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
            ),
            const SizedBox(height: 16),
            _summaryRow(context, 'المجموع الفرعي', state.totalPrice),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                ),
                Text(
                  '${state.totalPrice.toStringAsFixed(1)} ر.س',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
        Text(
          '${value.toStringAsFixed(1)} ر.س',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartState state, Color primary) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('جاري إعداد الطلب... (واجهة الدفع قريباً)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'إتمام الطلب',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${state.totalPrice.toStringAsFixed(1)} ر.س)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.primary,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onRemoveRequest,
    required this.onQuantityChanged,
    required this.onTap,
  });

  final CartItem item;
  final Color primary;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onRemoveRequest;
  final void Function(int quantity) onQuantityChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggleSelect(),
                      activeColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 88,
                    height: 88,
                    color: Colors.grey.shade100,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Boxicons.bx_image_alt,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${product.price.toStringAsFixed(1)} ر.س',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (!isSelectionMode) ...[
                        const SizedBox(height: 10),
                        _QuantityStepper(
                          value: item.quantity,
                          primary: primary,
                          onChanged: onQuantityChanged,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isSelectionMode)
                  IconButton(
                    onPressed: onRemoveRequest,
                    icon: Icon(
                      Boxicons.bx_trash,
                      size: 22,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartProductCard extends StatelessWidget {
  const _CartProductCard({
    required this.product,
    required this.primary,
    required this.onTap,
  });

  final Product product;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Boxicons.bx_image_alt,
                        size: 32,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${product.price.toStringAsFixed(1)} ر.س',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.primary,
    required this.onChanged,
  });

  final int value;
  final Color primary;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: value <= 1 ? null : () => onChanged(value - 1),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(
                Boxicons.bx_minus,
                size: 20,
                color: value <= 1 ? Colors.grey : primary,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '$value',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
          ),
        ),
        Material(
          color: primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => onChanged(value + 1),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(Boxicons.bx_plus, size: 20, color: primary),
            ),
          ),
        ),
      ],
    );
  }
}
