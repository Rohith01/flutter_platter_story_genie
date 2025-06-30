import 'dart:math';

String pickFeaturedImage(String character) {
  List<String> featuredImage;
  switch (character.toLowerCase()) {
    case 'animal':
      featuredImage = [
        'https://i.ibb.co/BV7FcSnv/animal1.jpg',
        'https://i.ibb.co/B2xByCTW/animal2.jpg',
        'https://i.ibb.co/h1hNTZhn/animal3.jpg',
      ];
      break;

    case 'boy' || 'girl':
      featuredImage = [
        'https://i.ibb.co/vx1xqvvx/kids1.jpg',
        'https://i.ibb.co/4gwD8ct6/kids2.jpg',
        'https://i.ibb.co/JjMVKGCY/kids3.jpg',
      ];
      break;

    case 'robot':
      featuredImage = [
        'https://i.ibb.co/gLFCcd8R/robot1.jpg',
        'https://i.ibb.co/tTHGbnt7/robot2.jpg',
        'https://i.ibb.co/7NLSTt1d/robot3.jpg',
      ];
      break;

    case 'princess':
      featuredImage = [
        'https://i.ibb.co/HL2RwdNk/princess1.jpg',
        'https://i.ibb.co/4gTKLgpG/princess2.jpg',
        'https://i.ibb.co/F4D50qfX/ptincess3.jpg',
      ];
      break;

    case 'superhero':
      featuredImage = [
        'https://i.ibb.co/0pmcVXrX/superhero1.jpg',
        'https://i.ibb.co/Fk34YZWr/superhero2.jpg',
        'https://i.ibb.co/DD4dQDHp/superhero3.jpg',
      ];
      break;

    case 'ghost':
      featuredImage = [
        'https://i.ibb.co/b5WnMf8P/ghost1.jpg',
        'https://i.ibb.co/gZgjFN6v/ghost2.jpg',
        'https://i.ibb.co/RTzvhbDH/ghost3.jpg',
      ];

      break;

    default:
      featuredImage = [
        'https://i.ibb.co/vx1xqvvx/kids1.jpg',
        'https://i.ibb.co/BV7FcSnv/animal1.jpg',
        'https://i.ibb.co/0pmcVXrX/superhero1.jpg',
      ];

      break;
  }
  return featuredImage[Random().nextInt(3)];
}
