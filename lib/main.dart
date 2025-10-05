import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solo 3',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const DogGallery(),
    );
  }
}

class DogGallery extends StatefulWidget {
  const DogGallery({super.key});
  @override
  State<DogGallery> createState() => _DogGalleryState();
}

class _DogGalleryState extends State<DogGallery> {
  final _controller = TextEditingController();
  List<String> _images = [];
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages([String? breed]) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final path = (breed == null || breed.isEmpty)
        ? 'breeds/image/random/12'
        : 'breed/${breed.toLowerCase()}/images/random/12';

    try {
      final response = await http.get(Uri.parse('https://dog.ceo/api/$path'));
      if (response.statusCode != 200) {
        throw Exception('Failed to load images (${response.statusCode})');
      }
      final data = jsonDecode(response.body);
      if (data['status'] != 'success') throw Exception(data['message']);
      setState(() => _images = List<String>.from(data['message']));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      return _ErrorView(message: _error!, onRetry: () => _fetchImages(_controller.text));
    } else if (_images.isEmpty) {
      return const Center(child: Text('No images found. Try another breed.'));
    } else {
      return RefreshIndicator(
        onRefresh: () => _fetchImages(_controller.text),
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: _images.length,
          itemBuilder: (context, i) {
            return _DogCard(imageUrl: _images[i]);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text('Dog Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _fetchImages(_controller.text),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _fetchImages,
              decoration: InputDecoration(
                labelText: 'Search by breed (e.g. hound)',
                hintText: 'Leave empty for random',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _fetchImages(_controller.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.download),
        label: const Text('Fetch'),
        onPressed: () => _fetchImages(_controller.text),
      ),
    );
  }
}

class _DogCard extends StatelessWidget {
  final String imageUrl;
  const _DogCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
        );
      },
      child: Ink.image(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
