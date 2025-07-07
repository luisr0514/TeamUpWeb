import 'package:flutter/material.dart';
import 'package:teamup_web/models/user_model.dart';
import 'package:intl/intl.dart';
import 'user_details_dialog.dart';

class UserCard extends StatefulWidget {
  final UserModel user;
  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isHovering ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(_isHovering ? 0.4 : 0.2),
              spreadRadius: _isHovering ? 2 : 1,
              blurRadius: _isHovering ? 8 : 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                backgroundImage: user.profileImageUrl.isNotEmpty
                    ? NetworkImage(user.profileImageUrl)
                    : null,
                child: user.profileImageUrl.isEmpty
                    ? Icon(Icons.person, size: 35, color: Colors.grey[600])
                    : null,
              ),
              Column(
                children: [
                  Text(
                    user.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.email.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        user.email,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => UserDetailsDialog(user: user),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 133, 167, 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Ver Información', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}