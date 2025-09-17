import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_business_app/services/listing_service.dart';
import 'package:my_business_app/components/input_field.dart';
import 'package:my_business_app/components/image_preview_grid.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/listing_constants.dart';
import 'package:my_business_app/utils/validators.dart';
import 'package:my_business_app/utils/error_handling.dart';

class ListingFormPage extends StatefulWidget {
  final Listing? editListing;

  const ListingFormPage({super.key, this.editListing});

  @override
  State<ListingFormPage> createState() => _ListingFormPageState();
}

class _ListingFormPageState extends State<ListingFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ListingService _listingService = ListingService.instance;

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _experienceController;
  late TextEditingController _warrantyController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  // Form state
  String _listingType = "Seller";
  String _status = "In Stock";
  List<String> _imagePaths = [];
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  late String _currentListingId;

  bool get isEditing => widget.editListing != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFormData();
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _experienceController = TextEditingController();
    _warrantyController = TextEditingController();
    _priceController = TextEditingController();
    _descController = TextEditingController();

    // Add listeners to detect changes
    for (var controller in [_titleController, _experienceController, _warrantyController, _priceController, _descController]) {
      controller.addListener(_markAsChanged);
    }
  }

  void _initializeFormData() {
    if (isEditing) {
      final listing = widget.editListing!;
      _titleController.text = listing.title;
      _experienceController.text = listing.experience;
      _warrantyController.text = listing.warranty;
      _priceController.text = listing.price;
      _descController.text = listing.description;
      _listingType = listing.type;
      _status = listing.status;
      _imagePaths = List.from(listing.imagePaths);
      _currentListingId = listing.id;
    } else {
      _currentListingId = _listingService.generateListingId();
      _status = ListingConstants.getDefaultStatus(_listingType);
    }
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _experienceController.dispose();
    _warrantyController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onListingTypeChanged(String? newType) {
    if (newType != null && newType != _listingType) {
      setState(() {
        _listingType = newType;
        _status = ListingConstants.getDefaultStatus(newType);
        _markAsChanged();
      });
    }
  }

  void _onImagesChanged(List<String> newPaths) {
    setState(() {
      _imagePaths = newPaths;
      _markAsChanged();
    });
  }

  Future<bool> _handleBackPressed() async {
    if (!_hasUnsavedChanges) return true;

    return await ListingErrorHandler.showUnsavedChangesDialog(context);
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final listing = Listing(
        id: _currentListingId,
        title: _titleController.text.trim(),
        experience: _experienceController.text.trim(),
        warranty: _warrantyController.text.trim(),
        price: _priceController.text.trim(),
        status: _status,
        description: _descController.text.trim(),
        imagePaths: List.from(_imagePaths),
        type: _listingType,
      );

      bool success;
      if (isEditing) {
        success = await _listingService.updateListing(_currentListingId, listing);
      } else {
        success = await _listingService.addListing(listing);
      }

      if (success && mounted) {
        Navigator.pop(context, listing);
      } else if (mounted) {
        final operation = isEditing ? 'update' : 'add';
        ListingErrorHandler.showListingError(context, operation, 'Operation failed');
      }
    } catch (e) {
      if (mounted) {
        final operation = isEditing ? 'update' : 'add';
        ListingErrorHandler.showListingError(context, operation, e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyUID() {
    Clipboard.setData(ClipboardData(text: _currentListingId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ID copied: ${_currentListingId.substring(0, 8)}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppSizing.init(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _handleBackPressed();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(isEditing ? "Edit Listing" : "Add Listing"),
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSizing.formPadding),
            children: [
              // Listing Type Selector
              if (!isEditing) ...[
                ListingFormContainer(
                  child: ListingTypeSelector(
                    selectedType: _listingType,
                    onChanged: _onListingTypeChanged,
                  ),
                ),
                SizedBox(height: AppSizing.formPadding),
              ],

              // ID Display for editing
              if (isEditing) ...[
                ListingFormContainer(
                  child: IdDisplayWidget(
                    id: _currentListingId,
                    onCopy: _copyUID,
                  ),
                ),
                SizedBox(height: AppSizing.formPadding),
              ],

              // Images
              ListingFormContainer(
                child: ImagePreviewGrid(
                  imagePaths: _imagePaths,
                  onImagesChanged: _onImagesChanged,
                  enabled: !_isLoading,
                ),
              ),
              SizedBox(height: AppSizing.formPadding),

              // Title
              ListingFormContainer(
                child: ListingTextField(
                  controller: _titleController,
                  fieldKey: 'title',
                  listingType: _listingType,
                  validator: (value) => ListingValidators.validateTitle(value, _listingType),
                  onChanged: _markAsChanged,
                ),
              ),
              SizedBox(height: AppSizing.md),

              // Experience (Service only)
              if (_listingType == "Service") ...[
                ListingFormContainer(
                  child: ListingTextField(
                    controller: _experienceController,
                    fieldKey: 'experience',
                    listingType: _listingType,
                    validator: (value) => ListingValidators.validateExperience(value, _listingType),
                    onChanged: _markAsChanged,
                  ),
                ),
                SizedBox(height: AppSizing.md),
              ],

              // Price
              ListingFormContainer(
                child: ListingPriceField(
                  controller: _priceController,
                  onChanged: _markAsChanged,
                ),
              ),
              SizedBox(height: AppSizing.md),

              // Warranty
              ListingFormContainer(
                child: ListingTextField(
                  controller: _warrantyController,
                  fieldKey: 'warranty',
                  listingType: _listingType,
                  validator: (value) => ListingValidators.validateWarranty(value, _listingType),
                  onChanged: _markAsChanged,
                ),
              ),
              SizedBox(height: AppSizing.md),

              // Status
              ListingFormContainer(
                child: ListingDropdown(
                  value: _status,
                  items: ListingConstants.getStatusOptions(_listingType),
                  fieldKey: 'status',
                  listingType: _listingType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                        _markAsChanged();
                      });
                    }
                  },
                  validator: (value) => ListingValidators.validateStatus(value),
                ),
              ),
              SizedBox(height: AppSizing.md),

              // Description
              ListingFormContainer(
                child: ListingTextField(
                  controller: _descController,
                  fieldKey: 'description',
                  listingType: _listingType,
                  maxLines: 3,
                  validator: (value) => ListingValidators.validateDescription(value),
                  onChanged: _markAsChanged,
                ),
              ),
              SizedBox(height: AppSizing.xxl),

              // Save Button
              FormActionButton(
                text: isEditing ? "Save Changes" : "Add Listing",
                onPressed: _saveForm,
                isLoading: _isLoading,
              ),
              SizedBox(height: AppSizing.formPadding),
            ],
          ),
        ),
      ),
    );
  }
}