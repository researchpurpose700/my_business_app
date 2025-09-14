
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';
import 'package:my_business_app/core/theme/dim.dart';

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
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fingerprint, size: 12, color: Colors.grey.shade600),
            SizedBox(width: Dim.xs),
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
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: FloatingActionButton.small(
              onPressed: () => openForm(),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
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
              padding: EdgeInsets.all(24),
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
            SizedBox(height: Dim.l),
            Text(
              "No listings yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: Dim.s),
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
        padding: EdgeInsets.all(20),
        itemCount: listings.length,
        itemBuilder: (BuildContext context, int index) {
          final Listing listing = listings[index];
          return Container(
            margin: EdgeInsets.only(bottom: Dim.m),
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
              padding: EdgeInsets.all(Dim.s),
              child: Row(
                children: [
                  // Product Image
                  _buildImageWidget(listing.imagePaths, 120),
                  SizedBox(width: Dim.xs),

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
                        SizedBox(height: 0),

                        // Price
                        Text(
                          "₹${listing.price}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.green.shade600,
                          ),
                        ),
                        SizedBox(height: 0),

                        // ID and Status Row
                        Row(
                          children: [
                            _buildUidBadge(listing.id),
                            SizedBox(width: Dim.s),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                        SizedBox(height: 2),

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
                          SizedBox(height: 0),
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
                      padding: EdgeInsets.all(Dim.s),
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
                          SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(height: 4),
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
                            SizedBox(width: Dim.m),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: Dim.m),
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

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Image Source', style: TextStyle(fontSize: 18)),
            SizedBox(height: Dim.l),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text('Camera'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _showCropDialog(pickedFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showCropDialog(XFile pickedFile) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crop Image?'),
          content: const Text('Would you like to crop this image before adding it?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _saveImageDirectly(pickedFile);
              },
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _cropImage(pickedFile);
              },
              child: const Text('Crop'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cropImage(XFile imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        await _saveProcessedImage(croppedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cropping image: $e')),
        );
      }
    }
  }

  Future<void> _saveImageDirectly(XFile imageFile) async {
    await _saveProcessedImage(imageFile.path);
  }

  Future<void> _saveProcessedImage(String imagePath) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = '${uuid.v4()}.jpg';
      final String newPath = '${appDir.path}/$fileName';

      await File(imagePath).copy(newPath);
      setState(() {
        savedImagePaths.add(newPath);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  void _deleteImage(int index) {
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
        SizedBox(height: Dim.s),
        if (savedImagePaths.isEmpty)
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 32),
                  SizedBox(height: Dim.s),
                  Text("Tap to add photos"),
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
            itemCount: savedImagePaths.length + (savedImagePaths.length < maxImages ? 1 : 0),
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
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _deleteImage(index),
                        child: const Icon(Icons.close, color: Colors.red, size: 20),
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
                    child: const Icon(Icons.add, size: 32),
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
    return Scaffold(
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
          padding: EdgeInsets.all(20),
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
              SizedBox(height: Dim.l),
            ],

            // ID Display
            if (isEditing) ...[
              _buildModernContainer(
                child: Row(
                  children: [
                    const Icon(Icons.fingerprint, color: Colors.blue, size: 20),
                    SizedBox(width: Dim.m),
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
              SizedBox(height: Dim.l),
            ],

            // Images
            _buildModernContainer(child: _buildImagePreviewGrid()),
            SizedBox(height: Dim.l),

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
                  SizedBox(height: Dim.s),
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
            SizedBox(height: Dim.m),

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
                    SizedBox(height: Dim.s),
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
              SizedBox(height: Dim.m),
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
            SizedBox(height: Dim.m),

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
                  SizedBox(height: Dim.s),
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
            SizedBox(height: Dim.m),

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
            SizedBox(height: Dim.m),

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
                  SizedBox(height: Dim.s),
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
            SizedBox(height: Dim.xl),

            // Save Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  isEditing ? "Save Changes" : "Add Listing",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: Dim.l),
          ],
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
      padding: EdgeInsets.all(Dim.m),
      child: child,
    );
  }
}



