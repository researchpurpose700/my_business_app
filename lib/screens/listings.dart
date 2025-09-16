import 'package:flutter/material.dart';
import 'package:my_business_app/services/listing_service.dart';
import 'package:my_business_app/components/listing_card.dart';
import 'package:my_business_app/components/listing_empty_state.dart';
import 'package:my_business_app/screens/listing_form_page.dart';
import 'package:my_business_app/utils/sizing.dart';
import 'package:my_business_app/utils/error_handling.dart';

class ListingPage extends StatefulWidget {
  const ListingPage({super.key});

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  final ListingService _listingService = ListingService.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeListings();
  }

  Future<void> _initializeListings() async {
    setState(() => _isLoading = true);
    try {
      await _listingService.initialize();
    } catch (e) {
      if (mounted) {
        ListingErrorHandler.showListingError(context, 'load', e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openForm({Listing? editListing}) async {
    final result = await Navigator.push<Listing>(
      context,
      MaterialPageRoute(
        builder: (_) => ListingFormPage(editListing: editListing),
      ),
    );

    if (result != null && mounted) {
      setState(() {}); // Refresh the UI
      final operation = editListing != null ? 'update' : 'add';
      ListingErrorHandler.showListingSuccess(context, operation);
    }
  }

  Future<void> _deleteListing(Listing listing) async {
    final confirmed = await ListingErrorHandler.showDeleteConfirmation(
      context,
      listing.title,
    );

    if (!confirmed) return;

    try {
      final success = await _listingService.deleteListing(listing.id);
      if (success && mounted) {
        setState(() {}); // Refresh the UI
        ListingErrorHandler.showListingSuccess(context, 'delete');
      } else if (mounted) {
        ListingErrorHandler.showListingError(context, 'delete', 'Failed to delete');
      }
    } catch (e) {
      if (mounted) {
        ListingErrorHandler.showListingError(context, 'delete', e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSizing.init(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("My Listings"),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: AppSizing.md),
            child: FloatingActionButton.small(
              onPressed: () => _openForm(),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_listingService.hasListings) {
      return ListingEmptyState(onAddPressed: () => _openForm());
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizing.formPadding),
      itemCount: _listingService.listings.length,
      itemBuilder: (context, index) {
        final listing = _listingService.listings[index];
        return ListingCard(
          listing: listing,
          onEdit: () => _openForm(editListing: listing),
          onDelete: () => _deleteListing(listing),
          onTap: () {
            // Optional: Add navigation to listing details
          },
        );
      },
    );
  }
}