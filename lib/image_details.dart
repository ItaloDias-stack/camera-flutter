import 'dart:io';

import 'package:flutter/material.dart';

showImageDetails(String imagePath, BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    )),
    builder: (context) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: imagePath.contains("https://")
            ? Image.network(
                imagePath,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    margin: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: const Text("Erro ao carregar a imagem"),
                  );
                },
              )
            : Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
      );
    },
  );
}
