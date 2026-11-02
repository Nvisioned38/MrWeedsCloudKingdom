/// Central mapping from stable content keys to replaceable art files.
/// Entries are intentionally allowed to point to not-yet-created art; widgets
/// use their fixed-size fallback when an image is absent.
class ArtRegistry {
  ArtRegistry._();

  static const paths = <String, String>{
    'room_cloud_house': 'assets/art/rooms/cloud_house.png',
    'room_lounge': 'assets/art/rooms/lounge.png',
    'room_kitchen': 'assets/art/rooms/kitchen.png',
    'room_art_gallery': 'assets/art/rooms/higher_art_gallery.png',
    'room_basement': 'assets/art/rooms/secret_basement.png',
    'room_festival': 'assets/art/rooms/festival_grounds.png',
    'symbol_unknown_workshop': 'assets/art/props/unmarked_workshop.png',
    'portrait_mr_weed': 'assets/art/characters/mr_weed_portrait.png',
    'character_mr_weed': 'assets/art/characters/mr_weed_full.png',
    'portrait_chef_blaze': 'assets/art/characters/chef_blaze_portrait.png',
    'character_chef_blaze': 'assets/art/characters/chef_blaze_full.png',
    'portrait_dr_cloud': 'assets/art/characters/dr_cloud_portrait.png',
    'character_dr_cloud': 'assets/art/characters/dr_cloud_full.png',
    'portrait_mona_chromatic':
        'assets/art/characters/mona_chromatic_portrait.png',
    'character_mona_chromatic': 'assets/art/characters/mona_chromatic_full.png',
    'portrait_riff': 'assets/art/characters/riff_portrait.png',
    'character_riff': 'assets/art/characters/riff_full.png',
    'portrait_collector': 'assets/art/characters/collector_portrait.png',
    'character_collector': 'assets/art/characters/collector_full.png',
    'card_bluebeary_pancakes': 'assets/art/cards/bluebeary_pancakes.png',
    'card_soldier_field_haze': 'assets/art/cards/soldier_field_haze.png',
    'card_bong_berry_blitz': 'assets/art/cards/bong_berry_blitz.png',
    'card_cortezs_curse': 'assets/art/cards/cortezs_curse.png',
    'card_sugar_skull_sherbet': 'assets/art/cards/sugar_skull_sherbet.png',
    'card_exotic_kush': 'assets/art/cards/exotic_kush.png',
    'card_blackberry_kush': 'assets/art/cards/blackberry_kush.png',
    'card_baked_alien': 'assets/art/cards/baked_alien.png',
    'card_blue_walker': 'assets/art/cards/blue_walker.png',
    'card_avatar_og': 'assets/art/cards/avatar_og.png',
  };

  static String? pathFor(String key) => paths[key];
}
