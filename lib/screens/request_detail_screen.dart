import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';
import '../models/comment_model.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class RequestDetailScreen extends StatelessWidget {
  final RequestModel request;
  final _fs = FirestoreService();

  RequestDetailScreen({required this.request});

  void _showAddComment(BuildContext context) {
    final _textCtl = TextEditingController();
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text('Novo comentário'),
        content: TextField(controller: _textCtl, decoration: InputDecoration(labelText: 'Comentário')),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(ctx), child: Text('Cancelar')),
          TextButton(onPressed: () async {
            final auth = Provider.of(context, listen:false) as dynamic;
            final user = (Provider.of(context, listen:false) as dynamic).currentUser;
            if (_textCtl.text.trim().isEmpty) return;
            await _fs.addComment(request.id, {
              'text': _textCtl.text.trim(),
              'userId': user.uid,
              'userName': user.displayName ?? user.email,
              'createdAt': DateTime.now(),
            });
            Navigator.pop(ctx);
          }, child: Text('Salvar')),
        ],
      );
    });
  }

  @override Widget build(BuildContext context) {
    final auth = Provider.of(context).watch<AuthService?>();
    final currentUser = Provider.of<AuthService>(context).currentUser;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                BackButton(),
                Expanded(child: Text(request.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                if (currentUser != null && currentUser.uid == request.userId)
                  PopupMenuButton(
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Excluir')),
                    ],
                    onSelected: (v) async {
                      if (v == 'delete') {
                        await _fs.deleteRequest(request.id);
                        Navigator.pop(context);
                      } else if (v == 'edit') {
                        // Para simplicidade, editar pode reusar a tela de cadastro com campos preenchidos (omito a implementação detalhada aqui)
                      }
                    },
                  ),
              ],
            ),
            if (request.photoUrl != null)
              Image.network(request.photoUrl!, height: 240, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(request.description),
                SizedBox(height: 8),
                Text('Enviado por: ${request.userName}'),
                Text('Localização: ${request.latitude.toStringAsFixed(6)}, ${request.longitude.toStringAsFixed(6)}'),
                Text('Data: ${DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt)}'),
              ]),
            ),
            Divider(),
            Expanded(
              child: StreamBuilder<List<CommentModel>>(
                stream: _fs.streamComments(request.id),
                builder: (context, snap) {
                  final comments = snap.data ?? [];
                  if (comments.isEmpty) return Center(child: Text('Sem comentários ainda'));
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, i){
                      final c = comments[i];
                      return ListTile(
                        title: Text(c.userName),
                        subtitle: Text(c.text),
                        trailing: Text(DateFormat('dd/MM HH:mm').format(c.createdAt)),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_comment),
        onPressed: () => _showAddComment(context),
      ),
    );
  }
}
