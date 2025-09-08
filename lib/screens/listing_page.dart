import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';

/// Data Model
class Listing {
  final String id;
  String title;
  String experience;
  String price;
  String warranty;
  String status;
  String description;
  List<String> imagePaths;
  String type; // "Seller" or "Service"

  Listing({
    required this.id,
    required this.title,
    required this.experience,
    required this.price,
    required this.warranty,
    required this.status,
    required this.description,
    required this.imagePaths,
    required this.type,
  });

  // Helper getter for backward compatibility
  String get imagePath => imagePaths.isNotEmpty ? imagePaths.first : "";
}

/// This is your main listing screen (renamed from ListingPage to MyListing)
class listingPage extends StatefulWidget {
  const listingPage({super.key});

  @override
  State<listingPage> createState() => _MyListingState();
}

class _MyListingState extends State<listingPage> {
  List<Listing> listings = [];

  void openForm({Listing? editListing}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<Listing>(
        builder: (_) => ListingForm(editListing: editListing),
      ),
    );

    if (result is Listing) {
      setState(() {
        if (editListing != null) {
          final int index = listings.indexWhere((Listing l) => l.id == editListing.id);
          if (index != -1) {
            listings[index] = result;
          }
        } else {
          listings.add(result);
        }
      });
    }
  }

  void deleteListing(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                listings.removeWhere((l) => l.id == id);
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _copyUID(String uid) {
    Clipboard.setData(ClipboardData(text: uid));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ID copied: ${uid.substring(0, 8)}...')),
    );
  }

  Widget _buildUidBadge(String uid) {
    return GestureDetector(
      onTap: () => _copyUID(uid),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fingerprint, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              'ID: ${uid.substring(0, 8)}...',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "In Stock":
      case "Available":
        return Colors.green;
      case "Out of Stock":
      case "Busy":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildImageWidget(List<String> imagePaths, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: imagePaths.isEmpty
          ? Icon(
        Icons.image_outlined,
        size: size * 0.8,
        color: Colors.grey.shade400,
      )
          : ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            Image.file(
              File(imagePaths.first),
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade100,
                child: Icon(
                  Icons.broken_image_outlined,
                  size: size * 0.8,
                  color: Colors.red.shade300,
                ),
              ),
            ),
            if (imagePaths.length > 1)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+${imagePaths.length - 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("My Listings"),
        toolbarHeight: 80,
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 22),
            child: SizedBox(
              width: 50,   // set your custom width
              height: 50,  // set your custom height
              child: FloatingActionButton(
                onPressed: () => openForm(),
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: listings.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.blue.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No listings yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap + to add your first listing",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: listings.length,
        itemBuilder: (BuildContext context, int index) {
          final Listing listing = listings[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Product Image
                  _buildImageWidget(listing.imagePaths, 120),
                  const SizedBox(width: 5),

                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Title
                        Text(
                          listing.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w200,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 0),

                        // Price
                        Text(
                          "₹${listing.price}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(height: 0),

                        // ID and Status Row
                        Row(
                          children: [
                            _buildUidBadge(listing.id),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(listing.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                listing.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w200,
                                  color: _getStatusColor(listing.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Description - Multiple lines as shown in image
                        if (listing.description.isNotEmpty)
                          Text(
                            listing.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                        // Experience for services
                        if (listing.type == "Service" && listing.experience.isNotEmpty) ...[
                          const SizedBox(height: 0),
                          Text(
                            "Experience: ${listing.experience}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Three dots menu
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    position: PopupMenuPosition.under,
                    onSelected: (String value) {
                      if (value == "edit") {
                        openForm(editListing: listing);
                      } else if (value == "delete") {
                        deleteListing(listing.id);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: "edit",
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 12),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 12),
                            Text("Delete", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}

/// Form Page
class ListingForm extends StatefulWidget {
  final Listing? editListing;
  const ListingForm({super.key, this.editListing});

  @override
  State<ListingForm> createState() => _ListingFormState();
}

class _ListingFormState extends State<ListingForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController experienceController;
  late TextEditingController warrantyController;
  late TextEditingController priceController;
  late TextEditingController descController;
  String status = "In Stock";
  List<String> savedImagePaths = [];
  String listingType = "Seller";
  final ImagePicker _picker = ImagePicker();
  final Uuid uuid = const Uuid();
  static const int maxImages = 5;
  late String currentListingId;

  // SOLUTION 2: Add boolean flag to prevent multiple crop operations
  bool _isCropping = false;
  bool _isProcessingImage = false;

  bool get isEditing => widget.editListing != null;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.editListing?.title ?? "");
    experienceController = TextEditingController(text: widget.editListing?.experience ?? "");
    warrantyController = TextEditingController(text: widget.editListing?.warranty ?? "");
    priceController = TextEditingController(text: widget.editListing?.price ?? "");
    descController = TextEditingController(text: widget.editListing?.description ?? "");

    if (isEditing) {
      listingType = widget.editListing!.type;
      status = widget.editListing!.status;
      currentListingId = widget.editListing!.id;
    } else {
      currentListingId = uuid.v4();
      if (listingType == "Seller") {
        status = "In Stock";
      } else {
        status = "Available";
      }
    }

    savedImagePaths = List.from(widget.editListing?.imagePaths ?? []);
  }

  @override
  void dispose() {
    titleController.dispose();
    experienceController.dispose();
    priceController.dispose();
    warrantyController.dispose();
    descController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<String>> get _getDropdownItems {
    if (listingType == "Service") {
      return const [
        DropdownMenuItem(value: "Available", child: Text("Available")),
        DropdownMenuItem(value: "Busy", child: Text("Busy")),
      ];
    } else {
      return const [
        DropdownMenuItem(value: "In Stock", child: Text("In Stock")),
        DropdownMenuItem(value: "Out of Stock", child: Text("Out of Stock")),
      ];
    }
  }

  void _onListingTypeChanged(String? newType) {
    if (newType != null && newType != listingType) {
      setState(() {
        listingType = newType;
        if (listingType == "Seller") {
          status = "In Stock";
        } else {
          status = "Available";
        }
      });
    }
  }

  void _showImageSourceDialog() {
    if (savedImagePaths.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $maxImages images allowed')),
      );
      return;
    }

    if (_isProcessingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait, processing image...')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isDismissible: !_isProcessingImage,
      enableDrag: !_isProcessingImage,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Image Source', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessingImage ? null : () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessingImage ? null : () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            if (_isProcessingImage) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Processing image...'),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessingImage) return;

    setState(() {
      _isProcessingImage = true;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Reduce quality to prevent memory issues
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null && mounted) {
        await _cropImageSafe(pickedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

  // Confirmation dialog removed: we crop immediately after picking

  // SOLUTION 2: Safe crop method with state management
  Future<void> _cropImageSafe(XFile imageFile) async {
    if (_isCropping || !mounted) return; // Prevent multiple calls

    setState(() {
      _isCropping = true;
    });

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 75,
        maxWidth: 1920,
        maxHeight: 1920,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
            activeControlsWidgetColor: Colors.blue,
            backgroundColor: Colors.white,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPickerButtonHidden: false,
          ),
        ],
      ).timeout(
        const Duration(minutes: 2), // Add timeout to prevent hanging
        onTimeout: () {
          throw Exception('Crop operation timed out');
        },
      );

      // Check if widget is still mounted and croppedFile is valid
      if (croppedFile != null && mounted) {
        await _saveProcessedImage(croppedFile.path);
      } else if (mounted) {
        // User cancelled cropping, save original
        await _saveImageDirectly(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cropping image: $e')),
        );
        // Fallback to saving original image
        await _saveImageDirectly(imageFile);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCropping = false;
        });
      }
    }
  }

  Future<void> _saveImageDirectly(XFile imageFile) async {
    if (!mounted) return;

    try {
      await _saveProcessedImage(imageFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    }
  }

  Future<void> _saveProcessedImage(String imagePath) async {
    if (!mounted) return;

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = '${uuid.v4()}.jpg';
      final String newPath = '${appDir.path}/$fileName';

      await File(imagePath).copy(newPath);

      if (mounted) {
        setState(() {
          savedImagePaths.add(newPath);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image added successfully!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    }
  }

  void _deleteImage(int index) {
    if (_isProcessingImage) return;

    setState(() {
      savedImagePaths.removeAt(index);
    });
  }

  void _copyUID(String uid) {
    Clipboard.setData(ClipboardData(text: uid));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ID copied: ${uid.substring(0, 8)}...')),
    );
  }

  Widget _buildImagePreviewGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Add Photos", style: TextStyle(fontSize: 16)),
            Text('${savedImagePaths.length}/$maxImages'),
          ],
        ),
        const SizedBox(height: 12),
        if (savedImagePaths.isEmpty)
          GestureDetector(
            onTap: _isProcessingImage ? null : _showImageSourceDialog,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessingImage ? Colors.grey.shade300 : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
                color: _isProcessingImage ? Colors.grey.shade50 : Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isProcessingImage) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text("Processing..."),
                  ] else ...[
                    const Icon(Icons.add_photo_alternate, size: 32),
                    const SizedBox(height: 8),
                    const Text("Tap to add photos"),
                  ],
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: savedImagePaths.length + (savedImagePaths.length < maxImages && !_isProcessingImage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < savedImagePaths.length) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(savedImagePaths[index]),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _deleteImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isProcessingImage
                        ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Processing...', style: TextStyle(fontSize: 10)),
                      ],
                    )
                        : const Icon(Icons.add, size: 32),
                  ),
                );
              }
            },
          ),
      ],
    );
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isProcessingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for image processing to complete')),
      );
      return;
    }

    final newListing = Listing(
      id: currentListingId,
      title: titleController.text.trim(),
      experience: experienceController.text.trim(),
      warranty: warrantyController.text.trim(),
      price: priceController.text.trim(),
      status: status,
      description: descController.text.trim(),
      imagePaths: List.from(savedImagePaths),
      type: listingType,
    );

    Navigator.pop(context, newListing);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessingImage && !_isCropping,
      onPopInvoked: (didPop) {
        if (!didPop && (_isProcessingImage || _isCropping)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait for processing to complete')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(isEditing ? "Edit Listing" : "Add Listing"),
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: Colors.black87,
          elevation: 0,
          leading: _isProcessingImage || _isCropping
              ? null
              : IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Listing Type
              if (!isEditing) ...[
                _buildModernContainer(
                  child: DropdownButtonFormField<String>(
                    value: listingType,
                    items: const [
                      DropdownMenuItem(value: "Seller", child: Text("🏪 Seller")),
                      DropdownMenuItem(value: "Service", child: Text("🛠 Service")),
                    ],
                    decoration: const InputDecoration(
                      labelText: "What are you listing?",
                      border: InputBorder.none,
                    ),
                    onChanged: _onListingTypeChanged,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ID Display
              if (isEditing) ...[
                _buildModernContainer(
                  child: Row(
                    children: [
                      const Icon(Icons.fingerprint, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      const Text("ID: ", style: TextStyle(fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () => _copyUID(currentListingId),
                        child: Text(
                          '${currentListingId.substring(0, 8)}...',
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.copy, color: Colors.grey, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Images
              _buildModernContainer(child: _buildImagePreviewGrid()),
              const SizedBox(height: 20),

              // Title
              _buildModernContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: listingType == "Seller" ? "Product Name" : "Service Name",
                        prefixIcon: Icon(
                          listingType == "Seller" ? Icons.inventory_2_outlined : Icons.handyman_outlined,
                          color: Colors.blue,
                        ),
                        border: InputBorder.none,
                        counterText: "", // Hide default counter
                      ),
                      maxLength: 50,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      onChanged: (value) => setState(() {}),
                      validator: (value) => value?.isEmpty == true ? "Required" : null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${50 - titleController.text.length} characters left",
                        style: TextStyle(
                          fontSize: 12,
                          color: (50 - titleController.text.length) <= 10
                              ? Colors.red
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Experience (Service only)
              if (listingType == "Service") ...[
                _buildModernContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: experienceController,
                        decoration: const InputDecoration(
                          labelText: "Experience",
                          prefixIcon: Icon(Icons.timeline, color: Colors.blue),
                          border: InputBorder.none,
                          hintText: "e.g., 5 years, Expert level",
                          counterText: "", // Hide default counter
                        ),
                        maxLength: 8,
                        maxLengthEnforcement: MaxLengthEnforcement.none,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(8),
                        ],
                        onChanged: (value) => setState(() {}),
                        validator: (value) => value?.isEmpty == true ? "Required" : null,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${8 - experienceController.text.length} characters left",
                          style: TextStyle(
                            fontSize: 12,
                            color: (8 - experienceController.text.length) <= 2
                                ? Colors.red
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Price
              _buildModernContainer(
                child: TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: "Price",
                    prefixIcon: Icon(Icons.currency_rupee, color: Colors.blue),
                    border: InputBorder.none,
                    hintText: "Enter amount",
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Price is required";
                    }
                    final intPrice = int.tryParse(value.trim());
                    if (intPrice == null) {
                      return "Enter a valid number";
                    }
                    if (intPrice > 99999) {
                      return "Maximum allowed price is ₹99999";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Warranty
              _buildModernContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: warrantyController,
                      decoration: InputDecoration(
                        labelText: "Warranty ${listingType == "Service" ? "(Optional)" : ""}",
                        prefixIcon: const Icon(Icons.verified_outlined, color: Colors.blue),
                        border: InputBorder.none,
                        hintText: "e.g., 1 year, 6 months",
                        counterText: "", // Hide default counter
                      ),
                      maxLength: 8,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(8),
                      ],
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${8 - warrantyController.text.length} characters left",
                        style: TextStyle(
                          fontSize: 12,
                          color: (8 - warrantyController.text.length) <= 2
                              ? Colors.red
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status
              _buildModernContainer(
                child: DropdownButtonFormField<String>(
                  value: status,
                  items: _getDropdownItems,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    prefixIcon: Icon(Icons.info_outline, color: Colors.blue),
                    border: InputBorder.none,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) setState(() => status = newValue);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Description
              _buildModernContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: listingType == "Seller" ? "Product Description" : "Service Description",
                        prefixIcon: const Icon(Icons.description_outlined, color: Colors.blue),
                        border: InputBorder.none,
                        hintText: "Tell us more about your ${listingType.toLowerCase()}...",
                        alignLabelWithHint: true,
                        counterText: "", // Hide default counter
                      ),
                      maxLines: 3,
                      maxLength: 300,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(300),
                      ],
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${300 - descController.text.length} characters left",
                        style: TextStyle(
                          fontSize: 12,
                          color: (300 - descController.text.length) <= 30
                              ? Colors.red
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isProcessingImage || _isCropping
                        ? [Colors.grey.shade400, Colors.grey.shade500]
                        : [Colors.blue, Colors.blueAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_isProcessingImage || _isCropping
                          ? Colors.grey
                          : Colors.blue).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: (_isProcessingImage || _isCropping) ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isProcessingImage || _isCropping) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isCropping ? "Cropping..." : "Processing...",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ] else
                        Text(
                          isEditing ? "Save Changes" : "Add Listing",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}