import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // 👈 Потрібен імпорт

import '../../core/widgets/wavy_header.dart';
import '../../core/widgets/app_button.dart';
import '../../models/wish_item.dart';
import '../../repository/storage_repository.dart'; // 👈 Потрібен імпорт

import '../../screens/wishlist/add_edit_item/add_edit_item_bloc.dart';
import '../../screens/wishlist/add_edit_item/add_edit_item_event.dart';
import '../../screens/wishlist/add_edit_item/add_edit_item_state.dart';

class AddEditItemScreen extends StatefulWidget {
  const AddEditItemScreen({super.key});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _linkController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;

  String? _selectedCategory;
  bool _isPublic = false;
  bool _addUrlPhoto = false;
  bool _isEditMode = false;

  // 🔽 Нові змінні для Storage
  XFile? _pickedImageFile;
  bool _isPickingImage = false;
  // 🔼

  String? _wishlistId;
  WishItem? _existingItem;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _linkController = TextEditingController();
    _descriptionController = TextEditingController();
    _imageUrlController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_existingItem != null || _wishlistId != null) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _wishlistId = args['wishlistId'] as String?;

      if (args.containsKey('item') && args['item'] != null) {
        final item = args['item'] as WishItem;
        _existingItem = item;
        _isEditMode = true;

        _nameController.text = item.name;
        _priceController.text = item.price.toString();
        _linkController.text = item.link;
        _descriptionController.text = item.description;
        _selectedCategory = item.category;
        _isPublic = item.isPublic;

        if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
          _addUrlPhoto = true;
          _imageUrlController.text = item.imageUrl!;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // 🔽 Новий метод для вибору зображення
  Future<void> _onPickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final storageRepo = context.read<StorageRepository>();
      final XFile? image = await storageRepo.pickImage();

      if (image != null) {
        setState(() {
          _pickedImageFile = image;
          _addUrlPhoto = false; // Вимикаємо URL, якщо обрали файл
          _imageUrlController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка вибору зображення: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }
  // 🔼

  // 🔽 Оновлений метод збереження
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 1. Визначаємо, яким буде URL
      String? imageUrl;
      if (_pickedImageFile != null) {
        // Якщо обрали файл, URL буде null.
        // BLoC завантажить файл і сам згенерує URL.
        imageUrl = null;
      } else if (_addUrlPhoto) {
        // Якщо ввели URL вручну
        imageUrl = _imageUrlController.text;
      } else if (_isEditMode && _existingItem?.imageUrl != null) {
        // Якщо режим редагування і нічого не міняли, беремо старий URL
        imageUrl = _existingItem!.imageUrl;
      } else {
        // Новий айтем, без фото
        imageUrl = null;
      }

      // 2. Створюємо об'єкт WishItem
      final item = WishItem(
        id: _isEditMode ? _existingItem!.id : '',
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        link: _linkController.text,
        description: _descriptionController.text,
        category: _selectedCategory ?? 'Other',
        isPublic: _isPublic,
        isBooked: _isEditMode ? _existingItem!.isBooked : false,
        createdAt:
            _isEditMode ? _existingItem!.createdAt : Timestamp.now(),
        imageUrl: imageUrl, // <-- Передаємо фінальний URL
      );

      // 3. Конвертуємо XFile у File (якщо він є)
      final fileToUpload =
          _pickedImageFile == null ? null : File(_pickedImageFile!.path);

      // 4. Відправляємо подію у BLoC
      if (_isEditMode) {
        context.read<AddEditItemBloc>().add(
              UpdateItem(
                wishlistId: _wishlistId!,
                item: item,
                imageFile: fileToUpload, // <-- Передаємо файл
              ),
            );
      } else {
        context.read<AddEditItemBloc>().add(
              CreateItem(
                wishlistId: _wishlistId!,
                item: item,
                imageFile: fileToUpload, // <-- Передаємо файл
              ),
            );
      }
    }
  }
  // 🔼

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddEditItemBloc, AddEditItemState>(
      listener: (context, state) {
        if (state is AddEditItemSuccess) {
          Navigator.pop(context);
        }
        if (state is AddEditItemError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Помилка: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  WavyHeader(),
                  Positioned(
                    bottom: 60,
                    left: 20,
                    child: Text(
                      _isEditMode ? 'Edit Item' : 'Add Item',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 251, 250, 250),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'Name',
                        controller: _nameController,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Це поле не може бути пустим'
                            : null,
                      ),
                      _buildTextField(
                        label: 'Price',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Це поле не може бути пустим';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Введіть коректну ціну';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Link',
                        controller: _linkController,
                        keyboardType: TextInputType.url,
                        isRequired: false,
                      ),
                      _buildCategoryDropdown(),
                      _buildTextField(
                        label: 'Short description',
                        controller: _descriptionController,
                        maxLines: 3,
                        isRequired: false,
                      ),

                      // 🔽 Новий віджет
                      _buildImagePickerSection(),
                      // 🔼

                      _buildCheckboxRow(
                        title: 'Add URL photo',
                        value: _addUrlPhoto,
                        // 🔽 Оновлена логіка
                        onChanged: (val) => setState(() {
                          _addUrlPhoto = val!;
                          if (_addUrlPhoto) {
                            _pickedImageFile =
                                null; // Очищуємо файл, якщо вмикаємо URL
                          }
                        }),
                        // 🔼
                      ),

                      if (_addUrlPhoto)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: _buildTextField(
                            label: 'Image URL',
                            controller: _imageUrlController,
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Будь ласка, введіть URL зображення';
                              }
                              final uri = Uri.tryParse(value);
                              if (uri == null ||
                                  !uri.isAbsolute ||
                                  !(uri.scheme == 'http' ||
                                      uri.scheme == 'https')) {
                                return 'Введіть коректний URL (http:// або https://)';
                              }
                              return null;
                            },
                          ),
                        ),
                      _buildCheckboxRow(
                        title: 'Public publication',
                        value: _isPublic,
                        onChanged: (val) => setState(() => _isPublic = val!),
                      ),
                      const SizedBox(height: 30),
                      BlocBuilder<AddEditItemBloc, AddEditItemState>(
                        builder: (context, state) {
                          final isLoading = state is AddEditItemLoading;

                          return AppButton(
                            text: _isEditMode ? 'Save Changes' : '+ Add Item',
                            onPressed: isLoading ? null : _submitForm,
                            isLoading: isLoading,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Cancel',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        isPrimary: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: validator ??
                (value) {
                  if (isRequired && (value == null || value.isEmpty)) {
                    return 'Це поле не може бути пустим';
                  }
                  return null;
                },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedCategory),
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            hint: const Text('Select category'),
            items: ['Gaming', 'Tech', 'Audio', 'Books', 'Fashion', 'Other']
                .map(
                  (label) => DropdownMenuItem(
                    value: label,
                    child: Text(label),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            validator: (value) => (value == null) ? 'Оберіть категорію' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
        Text(title),
      ],
    );
  }

  // 🔽 Новий допоміжний віджет
  Widget _buildImagePickerSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Image',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _pickedImageFile != null
                ? ClipRRect(
                    // Показуємо новий обраний файл
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_pickedImageFile!.path),
                      fit: BoxFit.cover,
                    ),
                  )
                : (_isEditMode &&
                        _existingItem?.imageUrl != null &&
                        _existingItem!.imageUrl!.isNotEmpty &&
                        !_addUrlPhoto) // Або старе фото з мережі
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _existingItem!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey),
                        ),
                      )
                    : const Center(
                        // Або іконка-заглушка
                        child: Icon(Icons.photo_camera_back_outlined,
                            color: Colors.grey, size: 40),
                      ),
          ),
          const SizedBox(height: 10),
          AppButton(
            text: _isPickingImage ? 'Picking...' : 'Pick from Gallery',
            onPressed: _isPickingImage ? null : _onPickImage,
            isPrimary: false,
          ),
        ],
      ),
    );
  }
  // 🔼
}