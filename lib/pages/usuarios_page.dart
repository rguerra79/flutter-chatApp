import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/services/usuarios_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:chat/models/usuario.dart';

class UsuariosPage extends StatefulWidget {
  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final usuarioService = new UsuariosService();
  /* final usuarios = [
    Usuario(uid: '1', nombre: 'Olivia', email: 'test1@test.com', online: true),
    Usuario(
        uid: '2', nombre: 'Roberto', email: 'test1@test.com', online: false),
    Usuario(uid: '3', nombre: 'Lucas', email: 'test1@test.com', online: true),
    Usuario(uid: '3', nombre: 'Emilio', email: 'test1@test.com', online: true),
    Usuario(uid: '4', nombre: 'Alana', email: 'test1@test.com', online: true),
    Usuario(uid: '5', nombre: 'Chany', email: 'test1@test.com', online: true),
  ]; */

  List<Usuario> usuarios = [];

  @override
  void initState() {
    this._cargarUsuarios();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final socketService = Provider.of<SocketService>(context);
    final usuario = authService.usuario;
    final double sizeIcon = 35;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          usuario.nombre,
          style: TextStyle(color: Colors.black54),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              socketService.disconnect();
              Navigator.pushReplacementNamed(context, 'login');
              AuthService.deleteToken();
            },
            icon: Icon(Icons.exit_to_app, color: Colors.black54)),
        actions: <Widget>[
          Container(
              margin: EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                  ? Icon(Icons.check_circle,
                      color: Colors.blue[400], size: sizeIcon)
                  : Icon(Icons.offline_bolt, color: Colors.red, size: sizeIcon))
        ],
      ),
      body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: _cargarUsuarios,
          header: WaterDropHeader(
              complete: Icon(Icons.check, color: Colors.green[400]),
              waterDropColor: Colors.lightBlue),
          child: _listViewUsuarios()),
      floatingActionButton: FloatingActionButton(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(Icons.abc_outlined, color: Colors.blue),
              Icon(Icons.abc_outlined, color: Colors.green),
              Icon(Icons.abc_outlined, color: Colors.red)
            ]),
        onPressed: () {},
      ),
    );
  }

  ListView _listViewUsuarios() {
    return ListView.separated(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        itemBuilder: (_, i) => _usuarioListTile(usuarios[i]),
        separatorBuilder: (_, i) => Divider(),
        itemCount: usuarios.length);
  }

  ListTile _usuarioListTile(Usuario usuario) {
    return ListTile(
      title: Text(usuario.nombre),
      subtitle: Text(usuario.email),
      leading: CircleAvatar(
        child: Text(usuario.nombre.substring(0, 2)),
        backgroundColor: Colors.blue[100],
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: usuario.online ? Colors.green[300] : Colors.red,
            borderRadius: BorderRadius.circular(100)),
      ),
      onTap: () {
        final chatService = Provider.of<ChatService>(context, listen: false);
        chatService.usuarioPara = usuario;
        Navigator.pushNamed(context, 'chat');
      },
    );
  }

  _cargarUsuarios() async {
    this.usuarios = await usuarioService.getUsuarios();
    setState(() {});
    // await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.refreshCompleted();
  }
}
