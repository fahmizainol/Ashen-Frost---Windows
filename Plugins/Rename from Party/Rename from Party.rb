MenuHandlers.add(:party_menu, :rename, {
  "name"      => _INTL("Rename"),
  "order"     => 45,
  "condition" => proc { |screen, party, party_idx| next !party[party_idx].egg? && 
                        !([:SWINUB, :PILOSWINE, :MAMOSWINE].include?(party[party_idx].species) && party[party_idx].form == 1) && 
                        !([:SANDSLASH, :ZAPDOS].include?(party[party_idx].species) && party[party_idx].form == 0) &&
                        !$joiplay && ![5, 7, 9, 12, 14].any?($player.character_ID) },
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    name = pbMessageFreeText("#{pkmn.speciesName}'s nickname?",_INTL(""),false, Pokemon::MAX_NAME_SIZE) { screen.pbUpdate }
    name=pkmn.speciesName if name ==""
    pkmn.name=name
    screen.pbDisplay(_INTL("{1} was renamed to {2}.",pkmn.speciesName,pkmn.name))
  }
})