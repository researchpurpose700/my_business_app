import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Data Model
class Listing {
  int id;
  String title;
  String price;
  String status;
  String description;
  String imageUrl;

  Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    required this.description,
    required this.imageUrl,
  });
}

/// This is your tab screen
class ListingPage extends StatefulWidget {
  const ListingPage({super.key});

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
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
          final int index =
              listings.indexWhere((Listing l) => l.id == editListing.id);
          if (index != -1) {
            listings[index] = result;
          }
        } else {
          listings.add(result);
        }
      });
    }
  }

  void deleteListing(int id) {
    setState(() {
      listings.removeWhere((Listing l) => l.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Listings"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => openForm(),
          )
        ],
      ),
      body: listings.isEmpty
          ? const Center(child: Text("No listings yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: listings.length,
              itemBuilder: (BuildContext context, int index) {
                final Listing listing = listings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      listing.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 40),
                    ),
                    title: Text(listing.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("₹${listing.price}"),
                        Text("Status: ${listing.status}"),
                        Text(listing.description,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == "edit") {
                          openForm(editListing: listing);
                        } else if (value == "delete") {
                          deleteListing(listing.id);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          const <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(value: "edit", child: Text("Edit")),
                        PopupMenuItem<String>(
                            value: "delete", child: Text("Delete")),
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
  late TextEditingController priceController;
  late TextEditingController descController;
  late TextEditingController imageController;
  String status = "In Stock";

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.editListing?.title ?? "");
    priceController =
        TextEditingController(text: widget.editListing?.price ?? "");
    descController =
        TextEditingController(text: widget.editListing?.description ?? "");
    imageController =
        TextEditingController(text: widget.editListing?.imageUrl ?? "");
    status = widget.editListing?.status ?? "In Stock";
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descController.dispose();
    imageController.dispose();
    super.dispose();
  }

  void handleSave() {
    if (_formKey.currentState!.validate()) {
      final Listing listing = Listing(
        id: widget.editListing?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: titleController.text,
        price: priceController.text,
        status: status,
        description: descController.text,
        imageUrl: imageController.text.isNotEmpty
            ? imageController.text
            : "https://via.placeholder.com/150",
      );
      Navigator.pop(context, listing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editListing != null
            ? "Edit Listing"
            : "Create New Listing"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "Image URL"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title *"),
                validator: (String? val) =>
                    val == null || val.isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Price *",
                  prefixText: '₹',
                ),
                validator: (String? val) =>
                    val == null || val.isEmpty ? "Price is required" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: "Availability"),
                items: const [
                  DropdownMenuItem(value: "In Stock", child: Text("In Stock")),
                  DropdownMenuItem(
                      value: "Out of Stock", child: Text("Out of Stock")),
                  DropdownMenuItem(value: "Available", child: Text("Available")),
                  DropdownMenuItem(value: "Busy", child: Text("Busy")),
                ],
                onChanged: (String? val) {
                  if (val != null) setState(() => status = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description *"),
                validator: (String? val) =>
                    val == null || val.isEmpty ? "Description is required" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(widget.editListing != null
                    ? "Update Listing"
                    : "Create Listing"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
