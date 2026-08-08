import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../viewmodel/product_viewmodel.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final ProductViewModel _viewModel = Get.find<ProductViewModel>();

  late String _selectedCategory;
  late String _selectedRating;
  late String _selectedSort;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    // Copy current filter states from ViewModel locally
    _selectedCategory = _viewModel.selectedCategory.value;
    _selectedRating = _viewModel.minimumRating.value;
    _selectedSort = _viewModel.selectedSort.value;
    _minPriceController = TextEditingController(
      text: _viewModel.minPrice.value?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: _viewModel.maxPrice.value?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _selectedCategory = 'All';
      _selectedRating = 'All';
      _selectedSort = 'Default';
      _minPriceController.clear();
      _maxPriceController.clear();
    });
    _viewModel.clearFilters();
  }

  void _apply() {
    final min = double.tryParse(_minPriceController.text);
    final max = double.tryParse(_maxPriceController.text);

    _viewModel.selectedCategory.value = _selectedCategory;
    _viewModel.minimumRating.value = _selectedRating;
    _viewModel.selectedSort.value = _selectedSort;
    _viewModel.minPrice.value = min;
    _viewModel.maxPrice.value = max;

    _viewModel.filterProducts();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 8.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Indicator
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                TextButton(
                  onPressed: _clearAll,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: 12.h),

            // 1. Categories
            Text(
              'Categories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => SizedBox(
                height: 38.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _viewModel.categories.length,
                  itemBuilder: (context, index) {
                    final cat = _viewModel.categories[index];
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: ChoiceChip(
                        label: Text(
                          cat.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // 2. Price Range
            Text(
              'Price Range',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 13.sp),
                    decoration: InputDecoration(
                      hintText: 'Min Price',
                      labelText: 'Minimum Price',
                      prefixIcon: const Icon(
                        Icons.attach_money_rounded,
                        size: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 13.sp),
                    decoration: InputDecoration(
                      hintText: 'Max Price',
                      labelText: 'Maximum Price',
                      prefixIcon: const Icon(
                        Icons.attach_money_rounded,
                        size: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // 3. Ratings
            Text(
              'Minimum Rating',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: ['All', '4+', '3+', '2+'].map((rating) {
                final isSelected = rating == _selectedRating;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (rating != 'All') ...[
                        Icon(
                          Icons.star_rounded,
                          size: 14.r,
                          color: isSelected ? Colors.white : Colors.amber[700],
                        ),
                        SizedBox(width: 2.w),
                      ],
                      Text(
                        rating,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedRating = rating;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),

            // 4. Sorting
            Text(
              'Sort Options',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedSort,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              items:
                  [
                    'Default',
                    'Price: Low to High',
                    'Price: High to Low',
                    'Rating: High to Low',
                    'Name: A to Z',
                  ].map((sort) {
                    return DropdownMenuItem<String>(
                      value: sort,
                      child: Text(sort),
                    );
                  }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedSort = val;
                  });
                }
              },
            ),
            SizedBox(height: 24.h),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 42.h,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
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
