import 'package:flutter/cupertino.dart';
import 'package:wakmusic/models/playlist.dart';

class RecPlaylistProvider extends ChangeNotifier {
  /* no api yet to fetch RecPlaylist */
  final List<Reclist> _list = [
    const Reclist(
      title: '고멤가요제',
      image: 'test',
      songlist: ['', ''],
    ),
    const Reclist(
      title: '연말공모전',
      image: 'test',
      songlist: ['', 'mLLvBeyKIUI', '0D7GPhsrXYo'],
    ),
    const Reclist(
      title: '상콘 OST',
      image: 'test',
      songlist: ['', 'mLLvBeyKIUI', '0D7GPhsrXYo', 'HXA9ZL8K5Js'],
    ),
    const Reclist(
      title: '힙합 SWAG',
      image: 'test',
      songlist: [
        '',
        'mLLvBeyKIUI',
        '0D7GPhsrXYo',
        'HXA9ZL8K5Js',
        '2j0f-ZZ77_c'
      ],
    ),
    const Reclist(
      title: '캐롤',
      image: 'test',
      songlist: [
        '',
        'mLLvBeyKIUI',
        '0D7GPhsrXYo',
        'HXA9ZL8K5Js',
        '2j0f-ZZ77_c',
        'z_FW8Tnj2z0'
      ],
    ),
    const Reclist(
      title: '노동요',
      image: 'test',
      songlist: [
        '',
        'mLLvBeyKIUI',
        '0D7GPhsrXYo',
        'HXA9ZL8K5Js',
        '2j0f-ZZ77_c',
        'z_FW8Tnj2z0',
        'ybQ2nXaoPMQ'
      ],
    ),
  ];

  List<Reclist> get list => _list;
}
