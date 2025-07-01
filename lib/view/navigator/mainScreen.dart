import 'package:flutter/material.dart';
import 'package:tugas16/helper/preference.dart';
import 'package:tugas16/view/api/user_api.dart';
import 'package:tugas16/view/login_screen.dart';
import 'package:tugas16/view/menu drawer/deletbuku.dart';
import 'package:tugas16/view/model/berhasilgetbuku.dart';
import 'package:tugas16/view/navigator/kembalikanbuku.dart';
import 'package:tugas16/view/navigator/pinjambuku.dart';
import 'package:tugas16/view/navigator/riwayatpinjaman.dart';
import 'package:tugas16/view/navigator/tambahbuku.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String userName = 'Nama Pengguna';
  String userEmail = 'email@pengguna.com';
  final GlobalKey<DaftarBukuState> _homeKey = GlobalKey<DaftarBukuState>();

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final name = await PreferenceHandler.getUserName() ?? 'Nama Pengguna';
    final email =
        await PreferenceHandler.getUserEmail() ?? 'email@pengguna.com';
    setState(() {
      userName = name;
      userEmail = email;
    });
  }

  final List<String> _titles = ['Beranda', 'Pinjam', 'Kembalikan', 'Riwayat'];

  final List<IconData> _icons = [
    Icons.home,
    Icons.book_online,
    Icons.assignment_return,
    Icons.history,
  ];

  late final List<Widget> _pages = [
    DaftarBuku(key: _homeKey),
    const Pinjambuku(),
    const Kembalikanbuku(),
    const RiwayatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        actions: _currentIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: () => _homeKey.currentState?.loadData(),
                ),
              ]
            : null,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.black,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              accountName: Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              accountEmail: Text(
                userEmail,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _drawerItem(
                    icon: Icons.delete_forever,
                    text: "Delete Buku",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Deletbuku()),
                    ),
                  ),

                  _drawerItem(
                    icon: Icons.add,
                    text: "Tambah Buku",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TambahBukuScreen(),
                      ),
                    ),
                  ),
                  const Divider(),
                  _drawerItem(
                    icon: Icons.logout_outlined,
                    text: "Logout",
                    onTap: () async {
                      await PreferenceHandler.removeToken();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        onTap: (index) => setState(() => _currentIndex = index),
        items: List.generate(_titles.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _titles[index],
          );
        }),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}

class DaftarBuku extends StatefulWidget {
  const DaftarBuku({super.key});

  @override
  DaftarBukuState createState() => DaftarBukuState();
}

class DaftarBukuState extends State<DaftarBuku> {
  late Future<List<GetBuku>> _bukuFuture;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    setState(() {
      _bukuFuture = UserService().daftarbuku();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GetBuku>>(
      future: _bukuFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Terjadi kesalahan: \${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Tidak ada buku tersedia"));
        }

        final daftarBuku = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: daftarBuku.length,
            itemBuilder: (context, index) {
              final buku = daftarBuku[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(buku.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Penulis: ${buku.author}"),
                      Text("Stok: ${buku.stock}"),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
