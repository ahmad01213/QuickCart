import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../cubit/auth/auth_cubit.dart';
import '../cubit/cart/cart_cubit.dart';
import '../cubit/cart/cart_state.dart';
import '../cubit/products/products_cubit.dart';
import '../cubit/products/products_state.dart';
import '../widgets/shimmer_loading.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

const List<String> _sampleAddresses = [
  'الرياض، حي النخيل',
  'جدة، حي الروضة',
  'الدمام، حي الفيصلية',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.productRepository,
    required this.authRepository,
  });

  final ProductRepository productRepository;
  final AuthRepository authRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  int _selectedAddressIndex = 0;
  int _bottomNavIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) context.read<ProductsCubit>().setSearchQuery(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocProvider(
      create: (_) => ProductsCubit(widget.productRepository)..loadProducts(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          bottomNavigationBar: _buildBottomNav(context),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primary.withValues(alpha: 0.06),
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                    stops: const [0.0, 0.25, 1.0],
                  ),
                ),
                child: CustomPaint(
                  painter: _HomeBackgroundPainter(color: primary),
                  size: Size.infinite,
                ),
              ),
              SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildAppBar(context, primary),
                  SliverToBoxAdapter(child: _buildSearchAndAddress(context)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyTabBarDelegate(
                      height: 72,
                      builder: _buildCategoryTabs,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    sliver: BlocBuilder<ProductsCubit, ProductsState>(
                      builder: (context, state) {
                        if (state.status == ProductsStatus.loading) {
                          return _buildShimmerGrid();
                        }
                        if (state.status == ProductsStatus.error) {
                          return SliverToBoxAdapter(
                            child: _buildErrorSection(context),
                          );
                        }
                        final products = state.filteredProducts;
                        if (products.isEmpty) {
                          return SliverToBoxAdapter(
                            child: _buildEmptySection(context),
                          );
                        }
                        return _buildProductGrid(
                          context,
                          products,
                          primary,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    const items = [
      Boxicons.bx_home_alt,
      Boxicons.bx_category_alt,
      Boxicons.bx_shopping_bag,
      Boxicons.bx_user,
    ];
    return Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isSelected = _bottomNavIndex == i;
              return IconButton(
                onPressed: () {
                  if (i == 2) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => CartScreen(
                          productRepository: widget.productRepository,
                        ),
                      ),
                    );
                  } else {
                    setState(() => _bottomNavIndex = i);
                  }
                },
                icon: Icon(
                  items[i],
                  size: 26,
                  color: isSelected ? primary : Colors.grey.shade600,
                ),
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color primary) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildAppBarAddress(context, primary),
      leadingWidth: 160,
      title: Text(
        'كويك كارت',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
      ),
      actions: [
        BlocBuilder<CartCubit, CartState>(
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
        IconButton(
          icon: const Icon(Boxicons.bx_log_out, size: 24),
          onPressed: () => context.read<AuthCubit>().logout(),
          color: const Color(0xFF1F2937),
        ),
      ],
    );
  }

  Widget _buildAppBarAddress(BuildContext context, Color primary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'اختر العنوان',
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        ...List.generate(_sampleAddresses.length, (i) {
                          return ListTile(
                            leading: Icon(
                              Icons.location_on_outlined,
                              color: i == _selectedAddressIndex ? primary : Colors.grey,
                            ),
                            title: Text(
                              _sampleAddresses[i],
                              textAlign: TextAlign.right,
                            ),
                            onTap: () {
                              setState(() => _selectedAddressIndex = i);
                              Navigator.pop(context);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              constraints: const BoxConstraints(maxWidth: 152),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, size: 18, color: primary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _sampleAddresses[_selectedAddressIndex],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                            fontSize: 12,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndAddress(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'ابحث عن منتجات...',
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final categories = ['all', ...state.categories];
        final selected = state.selectedCategory ?? 'all';
        final primary = Theme.of(context).colorScheme.primary;

        return SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final label = cat == 'all' ? 'الكل' : _categoryLabel(cat);
              final isSelected = selected == cat;

              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        context.read<ProductsCubit>().selectCategory(cat),
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primary
                            : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? primary : Colors.grey.shade300,
                          width: isSelected ? 0 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (cat == 'all')
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(
                                Boxicons.bx_grid_alt,
                                size: 18,
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                          Text(
                            label,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                                  fontWeight:
                                      isSelected ? FontWeight.w700 : FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _categoryLabel(String category) {
    if (category.isEmpty || category == 'all') return 'الكل';
    return category[0].toUpperCase() + category.substring(1);
  }

  Widget _buildShimmerGrid() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.60,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ShimmerBox(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(height: 14, width: double.infinity),
                    const SizedBox(height: 6),
                    ShimmerBox(height: 16, width: 80),
                  ],
                ),
              ),
            ],
          ),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildErrorSection(BuildContext context) {
    final state = context.read<ProductsCubit>().state;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            state.errorMessage ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.read<ProductsCubit>().loadProducts(),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(
    BuildContext context,
    List<Product> products,
    Color primary,
  ) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          return _ProductCard(
            product: product,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => ProductDetailsScreen(
                  product: product,
                  productRepository: widget.productRepository,
                ),
              ),
            ),
          );
        },
        childCount: products.length,
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate({required this.height, required this.builder});

  final double height;
  final Widget Function(BuildContext context) builder;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: builder(context),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return oldDelegate.height != height;
  }
}

class _HomeBackgroundPainter extends CustomPainter {
  _HomeBackgroundPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.85, 120), 140, paint);
    canvas.drawCircle(Offset(0, size.height * 0.35), 100, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.85), 80, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: primary.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = (w - 7).clamp(1.0, double.infinity);
                    return Container(
                      height: h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Boxicons.bx_image_alt,
                            size: 44,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade50,
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                            color: const Color(0xFF0F172A),
                          ),
                    ),
                    if (product.rating > 0 || product.ratingCount > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Boxicons.bx_star,
                            size: 14,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.rating > 0
                                ? product.rating.toStringAsFixed(1)
                                : '—',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                          ),
                          if (product.ratingCount > 0) ...[
                            Text(
                              ' (${product.ratingCount})',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(1)} ر.س',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Boxicons.bx_shopping_bag,
                                size: 22,
                                color: primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
