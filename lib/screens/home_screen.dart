import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/request_model.dart';
import 'add_request_screen.dart';
import 'request_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  final _fs = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitações Públicas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddRequestScreen()));
            },
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: () async {
            await auth.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          })
        ],
      ),
      body: StreamBuilder<List<RequestModel>>(
        stream: _fs.streamRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          final list = snapshot.data ?? [];
          if (list.isEmpty) return Center(child: Text('Ainda não há solicitações realizadas'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final r = list[i];
              return ListTile(
                title: Text(r.title),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(r.createdAt)),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => RequestDetailScreen(request: r)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
