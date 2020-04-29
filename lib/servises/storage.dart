import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:maps/classes/SharableUserInfo.dart';
import 'package:path_provider/path_provider.dart';

class StorageService{
  StorageReference _storageReference = FirebaseStorage.instance.ref();
  Directory _tempDirectory;
  void setTempDir () async {
    _tempDirectory = await getTemporaryDirectory();
  }

  Directory get tempDirectory => _tempDirectory;

  void downloadPhoto(String path) async {
    StorageReference pictureRef = FirebaseStorage.instance.ref().child(path);
    setTempDir();
    final File tempImageFile = File('${_tempDirectory.path}/$path');
    final StorageFileDownloadTask downloadTask = pictureRef.writeToFile(tempImageFile);
    downloadTask.future.then((snapshot) =>  print('Image downloaded')) ;
  }
  ImageProvider usersPhoto (SharableUserInfo userInfo){
    if(userInfo.photo){
      try{
        downloadPhoto(userInfo.photoPath);
        return FileImage(File(('${tempDirectory.path}/'+userInfo.photoPath)));
      }
      catch(e){
        return null;
      }
    }
    else{
      if(userInfo.gender == Gender.Female)
        return AssetImage('assets/images/profileFemale.png');
      else
        return AssetImage('assets/images/profileMale.gif');
    }
  }
  ImageProvider groupsImage (bool photoExists,String groupPhoto){
    if(photoExists){
      try{
        downloadPhoto(groupPhoto);
        return FileImage(File(('${tempDirectory.path}/$groupPhoto')));
      }
      catch(e){
        return null;
      }
    }
    else{
      return AssetImage('assets/images/groupe.png');
    }
  }
}