import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';

class AddPropertyScreen extends StatefulWidget {
  final Map<String, dynamic> userSession;

  const AddPropertyScreen({
    super.key,
    required this.userSession,
  });

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _purpose = 'sell';
  String _areaUnit = 'marla';
  int _categoryId = 1; // 1: Home, 2: Plot, 3: Commercial
  int _subtypeId = 1;  // 1: House, 2: Flat, 3: Upper Portion, etc.
  int _cityId = 3;     // 1: Islamabad, 2: Lahore, 3: Karachi, 4: Rawalpindi

  int _bedrooms = 1;
  int _bathrooms = 1;

  bool _isInstallmentAvailable = false;
  bool _isReadyForPossession = true;
  bool _isFeatured = false;

  // Selected Amenities map: key = amenity_field_id, value = {'id': id, 'label': label, 'value': value}
  final Map<int, Map<String, dynamic>> _selectedAmenities = {};
  List<Map<String, dynamic>> _amenityGroups = [];
  bool _isLoadingAmenities = false;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImageFiles = [];

  bool _isLoading = false;
  String? _errorMessage;

  String get _currentContext {
    if (_categoryId == 2) return 'plot';
    if (_categoryId == 3) return 'commercial';
    return 'home';
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.userSession['email']?.toString() ?? '';
    _phoneController.text = widget.userSession['phone']?.toString() ?? '';
    _fetchAmenities();
  }

  Future<void> _fetchAmenities() async {
    setState(() => _isLoadingAmenities = true);
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 6),
      ));
      final response = await dio.get(ApiConstants.appAmenities);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['groups'] is List) {
          final List rawGroups = data['groups'];
          if (mounted && rawGroups.isNotEmpty) {
            setState(() {
              _amenityGroups = rawGroups.map((g) => Map<String, dynamic>.from(g as Map)).toList();
              _isLoadingAmenities = false;
            });
            return;
          }
        }
      }
    } catch (_) {}

    // Fallback predefined offline schema matching live database
    if (mounted) {
      setState(() {
        _amenityGroups = _defaultAmenityGroups;
        _isLoadingAmenities = false;
      });
    }
  }

  void _pruneAmenitiesForContext() {
    final ctx = _currentContext;
    _selectedAmenities.removeWhere((id, item) {
      final itemContext = (item['context']?.toString() ?? 'all').toLowerCase();
      if (itemContext == 'all') return false;
      return itemContext != ctx;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _sizeController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Property Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickGalleryImages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickCameraImage();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickGalleryImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);
      if (images.isNotEmpty) {
        setState(() {
          _selectedImageFiles.addAll(images);
        });
      }
    } catch (e) {
      debugPrint('Error picking gallery images: $e');
    }
  }

  Future<void> _pickCameraImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (image != null) {
        setState(() {
          _selectedImageFiles.add(image);
        });
      }
    } catch (e) {
      debugPrint('Error capturing camera image: $e');
    }
  }

  Future<List<String>> _encodeImagesToBase64() async {
    List<String> base64List = [];
    for (var xFile in _selectedImageFiles) {
      try {
        final bytes = await xFile.readAsBytes();
        final base64Str = base64Encode(bytes);
        final extension = xFile.name.split('.').last.toLowerCase();
        final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
        base64List.add('data:$mimeType;base64,$base64Str');
      } catch (e) {
        debugPrint('Error encoding image: $e');
      }
    }
    return base64List;
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await SecureStorageService.getToken();
      final dio = Dio(BaseOptions(
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'User-ID': widget.userSession['id'],
          'User-Role': widget.userSession['role'],
        },
      ));

      final imagePayload = await _encodeImagesToBase64();

      final response = await dio.post(
        ApiConstants.appAddProperty,
        data: {
          'property_title': _titleController.text.trim(),
          'property_price': double.tryParse(_priceController.text.trim()) ?? 0.0,
          'property_description': _descriptionController.text.trim(),
          'property_purpose': _purpose,
          'area_size': double.tryParse(_sizeController.text.trim()) ?? 0.0,
          'area_unit': _areaUnit,
          'category_id': _categoryId,
          'subtype_id': _subtypeId,
          'city_id': _cityId,
          'location_name': _locationController.text.trim(),
          'property_email': _emailController.text.trim(),
          'property_phone': _phoneController.text.trim(),
          'is_installment_available': _isInstallmentAvailable ? 1 : 0,
          'is_ready_for_possession': _isReadyForPossession ? 1 : 0,
          'is_featured': _isFeatured ? 1 : 0,
          'bedrooms': _bedrooms,
          'bathrooms': _bathrooms,
          'amenities': _selectedAmenities.values.map((am) => {
            'id': am['id'],
            'label': am['label'],
            'value': am['value'],
          }).toList(),
          'property_amenities': jsonEncode(_selectedAmenities.values.map((am) => {
            'id': am['id'],
            'label': am['label'],
            'value': am['value'],
          }).toList()),
          'images': imagePayload,
          'image_url': imagePayload.isNotEmpty ? imagePayload[0] : '',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data != null) {
        final res = response.data;
        if (res['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Property listed successfully! Under admin review.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception(res['message']?.toString() ?? 'Failed to list property');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (mounted) {
        final msg = e.response?.data?['message']?.toString() ?? e.message ?? 'Failed to list property';
        setState(() {
          _errorMessage = msg;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Post New Property',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),

              // SECTION 1: Purpose & Category
              _buildSectionHeader('Purpose & Category'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildPurposeChip('Sell', 'sell', Icons.sell_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPurposeChip('Rent', 'rent', Icons.key_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildCategoryCard('Home', 1, Icons.home_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildCategoryCard('Plots', 2, Icons.landscape_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildCategoryCard('Commercial', 3, Icons.business_rounded)),
                ],
              ),
              const SizedBox(height: 20),

              // SECTION 2: Property Type
              _buildSectionHeader('Property Type'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSubtypeChip('House', 1),
                  _buildSubtypeChip('Flat', 2),
                  _buildSubtypeChip('Upper Portion', 3),
                  _buildSubtypeChip('Lower Portion', 4),
                  _buildSubtypeChip('Farm House', 5),
                  _buildSubtypeChip('Room', 6),
                  _buildSubtypeChip('Penthouse', 7),
                ],
              ),
              const SizedBox(height: 20),

              // SECTION 3: Location & City
              _buildSectionHeader('Location Details'),
              const SizedBox(height: 10),
              _buildFieldCard(
                icon: Icons.location_city_rounded,
                label: 'City',
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _cityId,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Islamabad')),
                      DropdownMenuItem(value: 2, child: Text('Lahore')),
                      DropdownMenuItem(value: 3, child: Text('Karachi')),
                      DropdownMenuItem(value: 4, child: Text('Rawalpindi')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _cityId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildFieldCard(
                icon: Icons.map_rounded,
                label: 'Location Name',
                child: TextFormField(
                  controller: _locationController,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g. DHA Phase 6',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 4: Area & Price
              _buildSectionHeader('Price & Area'),
              const SizedBox(height: 10),
              _buildFieldCard(
                icon: Icons.square_foot_rounded,
                label: 'Area Size',
                child: TextFormField(
                  controller: _sizeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: '10'),
                ),
              ),
              const SizedBox(height: 12),
              _buildFieldCard(
                icon: Icons.unfold_more_rounded,
                label: 'Unit',
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _areaUnit,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'marla', child: Text('Marla')),
                      DropdownMenuItem(value: 'kanal', child: Text('Kanal')),
                      DropdownMenuItem(value: 'sqft', child: Text('Sq. Ft.')),
                      DropdownMenuItem(value: 'sqyrd', child: Text('Sq. Yd.')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _areaUnit = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildFieldCard(
                icon: Icons.payments_rounded,
                label: 'Price (PKR)',
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'e.g. 15000000'),
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 5: Specs & Features
              _buildSectionHeader('Specifications & Toggles'),
              const SizedBox(height: 10),
              if (_categoryId == 1 || _categoryId == 3) ...[
                _buildNumberGroupSelector('Bedrooms', _bedrooms, 1, 10, (val) {
                  setState(() => _bedrooms = val);
                }),
                const SizedBox(height: 12),
                _buildNumberGroupSelector('Bathrooms', _bathrooms, 1, 10, (val) {
                  setState(() => _bathrooms = val);
                }),
                const SizedBox(height: 16),
              ],

              // Features & Amenities Section
              _buildAmenitiesSection(),
              const SizedBox(height: 16),

              _buildSwitchCard('Installment Available', 'Is price payable in installments?', _isInstallmentAvailable, (val) {
                setState(() => _isInstallmentAvailable = val);
              }),
              const SizedBox(height: 8),
              _buildSwitchCard('Ready for Possession', 'Is possession immediate?', _isReadyForPossession, (val) {
                setState(() => _isReadyForPossession = val);
              }),
              const SizedBox(height: 8),
              _buildSwitchCard('Featured Property', 'Feature listing on homepage?', _isFeatured, (val) {
                setState(() => _isFeatured = val);
              }),
              const SizedBox(height: 20),

              // SECTION 6: Title & Description
              _buildSectionHeader('Title & Overview'),
              const SizedBox(height: 10),
              _buildFieldCard(
                icon: Icons.title_rounded,
                label: 'Property Title',
                child: TextFormField(
                  controller: _titleController,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g. Beautiful 10 Marla Brand New House for Sale',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildFieldCard(
                icon: Icons.description_rounded,
                label: 'Description',
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Describe main features, location benefits & fitting details...',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 7: Contact Information
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 10),
              _buildFieldCard(
                icon: Icons.email_rounded,
                label: 'Email',
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'admin@gmail.com'),
                ),
              ),
              const SizedBox(height: 12),
              _buildFieldCard(
                icon: Icons.phone_rounded,
                label: 'Mobile',
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: '0300XXXXXXX'),
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 8: Property Photos Selection (Dynamic Image Picker)
              _buildSectionHeader('Property Media (Photos)'),
              const SizedBox(height: 10),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _selectedImageFiles.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: _showImagePickerModal,
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 28),
                              SizedBox(height: 6),
                              Text(
                                'Add Photo',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final xFile = _selectedImageFiles[index - 1];
                    final isMain = index == 1;

                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isMain ? AppColors.primary : AppColors.border,
                              width: isMain ? 2.5 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(xFile.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (isMain)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'COVER',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImageFiles.removeAt(index - 1);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Submit Property',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Features & Amenities'),
            ElevatedButton.icon(
              onPressed: _isLoadingAmenities ? null : _showAmenitiesModal,
              icon: _isLoadingAmenities
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              label: Text(
                _isLoadingAmenities
                    ? 'Loading...'
                    : _selectedAmenities.isEmpty
                        ? 'Add Amenities'
                        : 'Amenities (${_selectedAmenities.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_selectedAmenities.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedAmenities.values.map((am) {
              final String label = am['label']?.toString() ?? '';
              final String val = am['value']?.toString() ?? '';
              final String display = (val.isNotEmpty && val != '1') ? '$label: $val' : label;
              return Container(
                padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      display,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAmenities.remove(am['id']);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No additional amenities added. Tap "+ Add Amenities" to select.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  void _showAmenitiesModal() {
    final ctx = _currentContext;
    // Filter groups and fields for current property context
    final filteredGroups = <Map<String, dynamic>>[];
    for (var group in _amenityGroups) {
      final fields = (group['fields'] as List<dynamic>? ?? [])
          .map((f) => Map<String, dynamic>.from(f as Map))
          .where((f) {
            final fContext = (f['context']?.toString() ?? 'all').toLowerCase();
            return fContext == 'all' || fContext == ctx;
          })
          .toList();

      if (fields.isNotEmpty) {
        filteredGroups.add({
          'id': group['id'],
          'name': group['name'],
          'fields': fields,
        });
      }
    }

    if (filteredGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No amenities available for this category.')),
      );
      return;
    }

    // Temporary copy of selected amenities
    final tempSelected = Map<int, Map<String, dynamic>>.from(_selectedAmenities);
    final controllers = <int, TextEditingController>{};

    for (var group in filteredGroups) {
      for (var f in (group['fields'] as List<Map<String, dynamic>>)) {
        final id = int.tryParse(f['id'].toString()) ?? 0;
        final existingVal = tempSelected[id]?['value']?.toString() ?? '';
        controllers[id] = TextEditingController(text: existingVal == '1' ? '' : existingVal);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        int selectedTabIndex = 0;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentGroup = filteredGroups[selectedTabIndex];
            final currentFields = currentGroup['fields'] as List<Map<String, dynamic>>;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Modal Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Feature and Amenities',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textMain),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(modalCtx),
                          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Group Tabs
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: Colors.grey.shade50),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(filteredGroups.length, (idx) {
                          final grp = filteredGroups[idx];
                          final isTabActive = selectedTabIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(grp['name']?.toString() ?? ''),
                              selected: isTabActive,
                              selectedColor: AppColors.primary,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isTabActive ? Colors.white : AppColors.textMain,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: isTabActive ? AppColors.primary : AppColors.border),
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() => selectedTabIndex = idx);
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // Tab Fields List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: currentFields.length,
                      itemBuilder: (context, fIdx) {
                        final field = currentFields[fIdx];
                        final id = int.tryParse(field['id'].toString()) ?? 0;
                        final label = field['label']?.toString() ?? '';
                        final fieldType = (field['field_type']?.toString() ?? 'switch').toLowerCase();
                        final isSwitch = fieldType == 'switch';
                        final isSelected = tempSelected.containsKey(id);

                        if (isSwitch) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? AppColors.primary : AppColors.textMain,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: isSelected,
                                  activeThumbColor: AppColors.primary,
                                  onChanged: (val) {
                                    setModalState(() {
                                      if (val) {
                                        tempSelected[id] = {
                                          'id': id,
                                          'label': label,
                                          'value': '1',
                                          'context': field['context'],
                                        };
                                      } else {
                                        tempSelected.remove(id);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Number / Text input
                          final ctrl = controllers[id]!;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isSelected ? AppColors.primary : AppColors.textMain,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 5,
                                  child: TextFormField(
                                    controller: ctrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'e.g. 2023',
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: AppColors.border),
                                      ),
                                    ),
                                    onChanged: (text) {
                                      setModalState(() {
                                        if (text.trim().isNotEmpty) {
                                          tempSelected[id] = {
                                            'id': id,
                                            'label': label,
                                            'value': text.trim(),
                                            'context': field['context'],
                                          };
                                        } else {
                                          tempSelected.remove(id);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  // Modal Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(modalCtx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedAmenities.clear();
                                _selectedAmenities.addAll(tempSelected);
                              });
                              Navigator.pop(modalCtx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Add Amenities', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPurposeChip(String label, String val, IconData icon) {
    final isSelected = _purpose == val;
    return GestureDetector(
      onTap: () => setState(() => _purpose = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String label, int id, IconData icon) {
    final isSelected = _categoryId == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _categoryId = id;
          _pruneAmenitiesForContext();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textMuted, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.primary : AppColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtypeChip(String label, int id) {
    final isSelected = _subtypeId == id;
    return GestureDetector(
      onTap: () => setState(() => _subtypeId = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textMain,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.3),
    );
  }

  Widget _buildSwitchCard(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMain)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberGroupSelector(String label, int selectedValue, int min, int max, ValueChanged<int> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(max - min + 1, (index) {
              final val = min + index;
              final isSelected = selectedValue == val;
              return GestureDetector(
                onTap: () => onSelect(val),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(
                    val == max ? '$val+' : '$val',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.textMain,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldCard({required IconData icon, required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Predefined default amenity groups schema matching website & live database
  static const List<Map<String, dynamic>> _defaultAmenityGroups = [
    {
      'id': 1,
      'name': 'Main Features',
      'fields': [
        {'id': 1, 'label': 'Built in year', 'field_type': 'number', 'context': 'home'},
        {'id': 2, 'label': 'Parking Spaces', 'field_type': 'number', 'context': 'all'},
      ]
    },
    {
      'id': 2,
      'name': 'Rooms',
      'fields': [
        {'id': 3, 'label': 'Bedrooms', 'field_type': 'number', 'context': 'home'},
        {'id': 4, 'label': 'Bathrooms', 'field_type': 'number', 'context': 'home'},
      ]
    },
    {
      'id': 3,
      'name': 'Community Features',
      'fields': [
        {'id': 5, 'label': 'Mosque', 'field_type': 'switch', 'context': 'all'},
      ]
    },
    {
      'id': 4,
      'name': 'Healthcare Recreational',
      'fields': []
    },
    {
      'id': 5,
      'name': 'Business and Communication',
      'fields': []
    },
    {
      'id': 6,
      'name': 'Plot Features',
      'fields': [
        {'id': 6, 'label': 'Corner Plot', 'field_type': 'switch', 'context': 'plot'},
        {'id': 7, 'label': 'Boundary Wall', 'field_type': 'switch', 'context': 'plot'},
      ]
    },
  ];
}