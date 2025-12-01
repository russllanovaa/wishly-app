import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../wishlist/bloc/wishlist_bloc.dart';
import '../wishlist/bloc/wishlist_event.dart';
import '../wishlist/bloc/wishlist_state.dart';
import '../../repository/wishlist_repository.dart';
import '../../models/wishlist.dart';

import '../wishlist/add_edit_wishlist/add_edit_wishlist_bloc.dart';
import '../wishlist/add_edit_wishlist/add_edit_wishlist_event.dart';
import '../wishlist/add_edit_wishlist/add_edit_wishlist_state.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/wavy_header.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
int _selectedIndex = 0;
final TextEditingController _searchController = TextEditingController();
String _sortBy = 'name';

void _onItemTapped(int index) {
    setState(() {
       _selectedIndex = index;
   });
}

@override
void initState() {
 super.initState();
   context.read<WishlistBloc>().add(LoadWishlists());
}

@override
void dispose() {
   _searchController.dispose();
   super.dispose();
}

@override
Widget build(BuildContext context) {
   return Scaffold(
       backgroundColor: Colors.white,
       body: SingleChildScrollView(
           child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                   const WavyHeader(),
                   Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 24.0),
                       child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                               Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                       const Text(
                                           'My desires',
                                           style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                       ),
                                       IconButton(
                                           icon: const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
                                           tooltip: 'Test Error Load',
                                           onPressed: () {
                                               context.read<WishlistBloc>().add(FetchWishlistsWithError());
                                           },
                                       ),
                                   ],
                               ),
                               const SizedBox(height: 16),
                               
                               Row(
                                   children: [
                                       Expanded(
                                           child: TextField(
                                               controller: _searchController,
                                               decoration: InputDecoration(
                                                   hintText: 'Search wishlists...',                                                   prefixIcon: const Icon(Icons.search),
                                                   border: OutlineInputBorder(
                                                       borderRadius: BorderRadius.circular(12),
                                                   ),
                                               ),
                                               onChanged: (value) {
                                                  context.read<WishlistBloc>().add(FilterWishlists(query: value));
                                               },
                                           ),
                                       ),
                                       const SizedBox(width: 12),
                                       DropdownButton<String>(
                                           value: _sortBy,
                                           items: const [
                                               DropdownMenuItem(value: 'name', child: Text('Name')),
                                               DropdownMenuItem(value: 'date', child: Text('Date')),
                                           ],
                                           onChanged: (value) {
                                               setState(() {
                                                   _sortBy = value!;                                               });
                                               context.read<WishlistBloc>().add(SortWishlists(by: value!));
                                           },
                                       ),
                                   ],
                               ),
                           ],
                       ),
                   ),
                   const SizedBox(height: 20),

                   BlocBuilder<WishlistBloc, WishlistState>(
                       builder: (context, state) {
                           if (state is WishlistLoading && state.wishlists.isEmpty) {
                               return const Center(
                                   heightFactor: 5,
                                   child: CircularProgressIndicator(),
                               );
                           }

                           if (state is WishlistError) {
                               return Center(
                                   heightFactor: 5,
                                    child: Padding(
                                       padding: const EdgeInsets.all(16.0),                                       child: Column(
                                          children: [
                                              Text(
                                                   'Не вдалося завантажити: ${state.message}',
                                                   style: const TextStyle(color: Colors.red),
                                                   textAlign: TextAlign.center,
                                               ),
                                               const SizedBox(height: 16),
                                               ElevatedButton(
                                                   onPressed: () {
                                                       context.read<WishlistBloc>().add(LoadWishlists());
                                                   },
                                                   child: const Text('Спробувати знову'),
                                               ),
                                           ],
                                       ),
                                   ),
                               );
                           }

                           if (state.wishlists.isEmpty) {
                               return const Center(
                                   heightFactor: 5,
                                   child: Column(
                                       children: [
                                           Icon(Icons.list_alt, size: 64, color: Colors.grey),
                                           SizedBox(height: 16),
                                           Text('У вас ще немає списків бажань.'),
                                       ],
                                   ),
                               );
                           }

                            return ListView.builder(
                               shrinkWrap: true,
                               physics: const NeverScrollableScrollPhysics(),
                               itemCount: state.wishlists.length,
                               itemBuilder: (context, index) {
                                   final list = state.wishlists[index];
                                   return _buildWishlistCard(list);
                               },
                           );
                       },
                   ),

                   const SizedBox(height: 20),
                   // ✅ ВИПРАВЛЕНО: Блок зображення повністю видалено, кнопку зроблено повною шириною
                   Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 24.0),
                       child: AppButton(
                           text: '+ Add new',
                           onPressed: () {
                               _showAddEditWishlistDialog(context);
                           },
                           width: double.infinity, // Розтягуємо кнопку
                       ),
                   ),                   const SizedBox(height: 40),
               ],
           ),
       ),
       bottomNavigationBar: _buildBottomNav(context),
   );
}

Widget _buildWishlistCard(Wishlist list) {
   return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: GestureDetector(
           onTap: () {
               Navigator.pushNamed(context, '/wishlist_detail', arguments: list);
           },
           child: Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                   color: Colors.grey[100],
                   borderRadius: BorderRadius.circular(16),
                   boxShadow: [
                       BoxShadow(
                           color: Colors.black.withAlpha(15),
                          blurRadius: 4,
                           offset: const Offset(0, 2),
                       ),
                   ],
               ),
               child: Row(
                   children: [
                       // ✅ ЗАМІНЕНО: list.icon на статичну іконку-заглушку
                       CircleAvatar(
                           radius: 24,
                           backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
                           child: const Icon(Icons.star, color: Colors.blueAccent),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                           child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                   Text(
                                       list.name,
                                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                   ),
                                   const SizedBox(height: 4),
                                   Text(
                                       '${list.itemCount} items', 
                                       style: TextStyle(
                                           fontSize: 14,
                                           color: Colors.grey[600],
                                       ),
                                   ),
                               ],
                           ),
                       ),
                       IconButton(
                           onPressed: () {
                               _showDeleteWishlistDialog(context, list);
                           },
                           icon: const Icon(Icons.delete_outline, color: Colors.grey),
                       ),
                       const SizedBox(width: 8),
                       ElevatedButton(
                           onPressed: () {
                               _showEditWishlistDialog(context, list);
                           },
                           style: ElevatedButton.styleFrom(
                               backgroundColor: Theme.of(context).primaryColor,
                               foregroundColor: Colors.white,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                           ),
                           child: const Text('Edit'),
                       ),
                   ],
               ),
           ),
       ),
    );
}

void _showDeleteWishlistDialog(BuildContext context, Wishlist wishlist) {
   showDialog(
       context: context,
       builder: (context) => AlertDialog(
           title: const Text('Delete Wishlist'),
           content: Text('Are you sure you want to delete "${wishlist.name}"?'),
           actions: [
               TextButton(
                   onPressed: () => Navigator.pop(context),
                   child: const Text('Cancel'),
               ),
               ElevatedButton(
                   onPressed: () {
                       context.read<WishlistBloc>().add(DeleteWishlist(id: wishlist.id));
                       Navigator.pop(context);
                   },
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                   child: const Text('Delete'),
               ),
           ],
       ),
   );
}

void _showEditWishlistDialog(BuildContext context, Wishlist wishlist) {
   _showAddEditWishlistDialog(context, wishlist: wishlist);
}

void _showAddEditWishlistDialog(BuildContext context, {Wishlist? wishlist}) {
    showDialog(
       context: context,
       builder: (dialogContext) {
           return BlocProvider(
               create: (context) => AddEditWishlistBloc(
                   wishlistRepository: context.read<WishlistRepository>(),
               ),
               child: _AddEditWishlistForm(wishlist: wishlist),
           );
       },
   );
}

Widget _buildBottomNav(BuildContext context) {
   return Container(
       margin: const EdgeInsets.all(16),
       decoration: BoxDecoration(
           color: Colors.grey[100],
           borderRadius: BorderRadius.circular(20),
           boxShadow: [
               BoxShadow(
                   color: Colors.black.withAlpha(26),
                   blurRadius: 10,
                   offset: const Offset(0, 5),
               )
           ],
       ),
       child: ClipRRect(
           borderRadius: BorderRadius.circular(20),
           child: BottomNavigationBar(
               items: const <BottomNavigationBarItem>[
                   BottomNavigationBarItem(
                       icon: Icon(Icons.home_outlined),
                       activeIcon: Icon(Icons.home),
                       label: 'Home',
                   ),
                   BottomNavigationBarItem(
                       icon: Icon(Icons.calendar_today_outlined),
                       activeIcon: Icon(Icons.calendar_today),
                       label: 'Calendar',
                   ),
                   BottomNavigationBarItem(
                       icon: Icon(Icons.person_outline),                       activeIcon: Icon(Icons.person),
                       label: 'Profile',
                   ),
               ],
              currentIndex: _selectedIndex,
               selectedItemColor: Theme.of(context).primaryColor,
               unselectedItemColor: Colors.grey,
               onTap: _onItemTapped,
               backgroundColor: Colors.grey[100],
               elevation: 0,
               showSelectedLabels: true,
               showUnselectedLabels: true,
           ),
       ),
  );
}
}

class _AddEditWishlistForm extends StatefulWidget {
final Wishlist? wishlist;
const _AddEditWishlistForm({this.wishlist});

@override
State<_AddEditWishlistForm> createState() => _AddEditWishlistFormState();
}

class _AddEditWishlistFormState extends State<_AddEditWishlistForm> {
final _formKey = GlobalKey<FormState>();
late TextEditingController _nameController;
// ❌ _selectedIcon ВИДАЛЕНО
bool get _isEditMode => widget.wishlist != null;

// ❌ _iconOptions ВИДАЛЕНО

@override
void initState() {
   super.initState();
   _nameController = TextEditingController(text: widget.wishlist?.name ?? '');
   // ❌ Ініціалізація _selectedIcon ВИДАЛЕНО
}

@override
void dispose() {
   _nameController.dispose();
   super.dispose();
}

void _onSavePressed() {
if (_formKey.currentState!.validate()) {
final bloc = context.read<AddEditWishlistBloc>();

// ❌ Отримання параметрів IconData ВИДАЛЕНО

if (_isEditMode) {
final updatedWishlist = Wishlist(
   id: widget.wishlist!.id,
  ownerId: widget.wishlist!.ownerId,
   name: _nameController.text,
   // ❌ Параметри іконки ВИДАЛЕНО
   createdAt: widget.wishlist!.createdAt,
   itemCount: widget.wishlist!.itemCount, 
);
bloc.add(UpdateWishlist(wishlist: updatedWishlist));
} else {
bloc.add(CreateWishlist(
   name: _nameController.text,
   // ❌ Параметри іконки ВИДАЛЕНО
));
}
}
}

@override
Widget build(BuildContext context) {
return BlocListener<AddEditWishlistBloc, AddEditWishlistState>(
listener: (context, state) {
if (state is AddEditWishlistSuccess) {
   Navigator.pop(context); 
}
if (state is AddEditWishlistError) {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Помилка збереження: ${state.message}')),
   );
}
},
child: AlertDialog(
title: Text(_isEditMode ? 'Edit Wishlist' : 'Add Wishlist'),
content: Form(
  key: _formKey,
   child: SingleChildScrollView(
       child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
               TextFormField(
                   controller: _nameController,
                   decoration: const InputDecoration(
                       labelText: 'Name',
                       border: OutlineInputBorder(),
                   ),
                   validator: (value) {
                       if (value == null || value.isEmpty) {
                           return 'Please enter a name';
                       }
                       return null;
                   },
               ),
               // ❌ ВЕСЬ БЛОК ВИБОРУ ІКОНКИ ВИДАЛЕНО
           ],
       ),
   ),
),
actions: [
   TextButton(
       onPressed: () => Navigator.pop(context),
       child: const Text('Cancel'),
   ),
   BlocBuilder<AddEditWishlistBloc, AddEditWishlistState>(
       builder: (context, state) {
           if (state is AddEditWishlistLoading) {
               return const ElevatedButton(
                   onPressed: null,
                   child: SizedBox(
                       width: 20, 
                       height: 20, 
                       child: CircularProgressIndicator(strokeWidth: 2),
                   ),
               );
           }
           return ElevatedButton(
               onPressed: _onSavePressed,
               child: const Text('Save'),
           );
       },
   ),
],
),
);
}
}