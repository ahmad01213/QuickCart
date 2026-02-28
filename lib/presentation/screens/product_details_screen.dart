import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../cubit/cart/cart_cubit.dart';
import '../cubit/cart/cart_state.dart';
import '../widgets/shimmer_loading.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.productRepository,
  });

  final Product product;
  final ProductRepository productRepository;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Product? _product;
  bool _loading = false;
  String? _error;
  List<Product> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _fetchDetails();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final list = await widget.productRepository.getProducts();
      if (mounted) setState(() => _allProducts = list);
    } catch (_) {}
  }

  Future<void> _fetchDetails() async {
    setState(() => _loading = true);
    try {
      final p = await widget.productRepository.getProductById(widget.product.id);
      if (mounted) {
        setState(() {
          _product = p ?? widget.product;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'فشل تحميل التفاصيل';
        });
      }
    }
  }

  void _addToCart() {
    if (_product == null) return;
    context.read<CartCubit>().add(_product!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تمت إضافة المنتج إلى السلة'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'حسناً',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product ?? widget.product;
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(context, primary),
        body: _loading && _product == widget.product
            ? _buildShimmerLoading(context)
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildProductImage(context, product, primary)),
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -24),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_error != null) _buildErrorBanner(context),
                              _buildCategoryChip(context, product, primary),
                              const SizedBox(height: 12),
                              Text(
                                product.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      height: 1.3,
                                      color: const Color(0xFF0F172A),
                                    ),
                              ),
                              const SizedBox(height: 14),
                              _buildPriceAndRatingRow(context, product, primary),
                              const SizedBox(height: 24),
                              _buildDescription(context, product),
                              if (_allProducts.isNotEmpty) ...[
                                const SizedBox(height: 32),
                                _buildSectionTitle(context, 'منتجات ذات صلة'),
                                const SizedBox(height: 12),
                                _buildProductHorizontalList(
                                  context,
                                  _getRelatedProducts(product),
                                  primary,
                                ),
                                const SizedBox(height: 28),
                                _buildSectionTitle(context, 'مناسب لك'),
                                const SizedBox(height: 12),
                                _buildProductHorizontalList(
                                  context,
                                  _getRecommendedProducts(product),
                                  primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
        bottomNavigationBar: _buildBottomBar(context, product, primary),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: AspectRatio(
              aspectRatio: 1,
              child: ShimmerBox(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -24),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      height: 28,
                      width: 100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 16),
                    ShimmerBox(
                      height: 24,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 8),
                    ShimmerBox(
                      height: 24,
                      width: 180,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ShimmerBox(
                          height: 28,
                          width: 80,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const Spacer(),
                        ShimmerBox(
                          height: 22,
                          width: 60,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ShimmerBox(
                      height: 14,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 10),
                    ShimmerBox(
                      height: 14,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 10),
                    ShimmerBox(
                      height: 14,
                      width: 240,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Color primary) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Boxicons.bx_chevron_right, size: 26),
        onPressed: () => Navigator.of(context).pop(),
        color: const Color(0xFF1F2937),
      ),
      title: Text(
        'تفاصيل المنتج',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Boxicons.bx_heart, size: 24),
          onPressed: () {},
          color: const Color(0xFF1F2937),
        ),
        IconButton(
          icon: const Icon(Boxicons.bx_share_alt, size: 24),
          onPressed: () {},
          color: const Color(0xFF1F2937),
        ),
        BlocBuilder<CartCubit, CartState>(
          buildWhen: (prev, curr) => prev.count != curr.count,
          builder: (context, cartState) {
            final count = cartState.count;
            return IconButton(
              icon: count > 0
                  ? Badge(
                      label: Text('$count'),
                      child: const Icon(Boxicons.bx_shopping_bag, size: 26),
                    )
                  : const Icon(Boxicons.bx_shopping_bag, size: 26),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => CartScreen(
                      productRepository: widget.productRepository,
                    ),
                  ),
                );
              },
              color: const Color(0xFF1F2937),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductImage(BuildContext context, Product product, Color primary) {
    return GestureDetector(
      onTap: () => _openZoomableImage(context, product.imageUrl, primary),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Boxicons.bx_image_alt,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(color: primary),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openZoomableImage(BuildContext context, String imageUrl, Color primary) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => _ZoomableImageView(
          imageUrl: imageUrl,
          primary: primary,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildPriceAndRatingRow(BuildContext context, Product product, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${product.price.toStringAsFixed(1)} ر.س',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: primary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        if (product.rating > 0 || product.ratingCount > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Boxicons.bx_star, size: 18, color: Colors.amber.shade700),
              const SizedBox(width: 4),
              Text(
                product.rating > 0 ? product.rating.toStringAsFixed(1) : '—',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
              ),
              if (product.ratingCount > 0) ...[
                Text(
                  ' (${product.ratingCount})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ],
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Boxicons.bx_error_circle,
              color: Theme.of(context).colorScheme.error,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, Product product, Color primary) {
    if (product.category.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        product.category.isNotEmpty
            ? product.category[0].toUpperCase() + product.category.substring(1)
            : product.category,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  List<Product> _getRelatedProducts(Product current) {
    if (current.category.isEmpty) return [];
    final sameCategory = _allProducts
        .where((p) => p.id != current.id && p.category == current.category)
        .toList();
    return sameCategory.take(8).toList();
  }

  List<Product> _getRecommendedProducts(Product current) {
    final relatedIds = _getRelatedProducts(current).map((p) => p.id).toSet();
    final others = _allProducts
        .where((p) => p.id != current.id && !relatedIds.contains(p.id))
        .toList();
    return others.take(8).toList();
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
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
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = products[index];
          return _RelatedProductCard(
            product: p,
            primary: primary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => ProductDetailsScreen(
                  product: p,
                  productRepository: widget.productRepository,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescription(BuildContext context, Product product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        product.description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: const Color(0xFF475569),
            ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Product product, Color primary) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${product.price.toStringAsFixed(1)} ر.س',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Boxicons.bx_plus, size: 22),
                  label: const Text('الإضافة للسلة'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelatedProductCard extends StatelessWidget {
  const _RelatedProductCard({
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

class _ZoomableImageView extends StatelessWidget {
  const _ZoomableImageView({
    required this.imageUrl,
    required this.primary,
    required this.onClose,
  });

  final String imageUrl;
  final Color primary;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(color: primary),
                    );
                  },
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Boxicons.bx_image_alt,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      onTap: onClose,
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Boxicons.bx_x, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
