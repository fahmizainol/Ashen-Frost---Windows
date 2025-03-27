
def pbGetMonRoles(targetmon=nil)
  print("changed")
  partyRoles = []
  party = targetmon ? [targetmon] : @mondata.party
  for mon in party
    monRoles=[]
    movelist = []
    if targetmon && targetmon.class==Pokemon || !targetmon
      for i in mon.moves
        next if i.nil?
        movelist.push(i.move)
      end
    elsif targetmon && targetmon.class==Battle::Battler
      for i in targetmon.moves
        next if i.nil?
        movelist.push(i.move)
      end
    end
    monRoles.push(:LEAD) if @mondata.party.index(mon)==0 || (@mondata.party.index(mon)==1 && @battle.doublebattle && @battle.pbParty(@mondata.index)==@battle.pbPartySingleOwner(@mondata.index))
    monRoles.push(:ACE) if @mondata.party.index(mon)==(@mondata.party.length-1)
    secondhighest=true
    if party.length>2
      for i in 0..(party.length-2)
        next if party[i].nil?
        secondhighest=false if mon.level<party[i].level
      end
    end
    for i in movelist
      next if i.nil?
      healingmove=true if $cache.moves[i] && $cache.moves[i].checkFlag?(:healingmove)
      curemove=true if (i == :HEALBELL || i == :AROMATHERAPY)
      wishmove=true if i == :WISH
      phasemove=true if PBStuff::PHASEMOVE.include?(i)
      pivotmove=true if PBStuff::PIVOTMOVE.include?(i)
      spinmove=true if i == :RAPIDSPIN
      batonmove=true if i == :BATONPASS
      screenmove=true if PBStuff::SCREENMOVE.include?(i)
      tauntmove=true if i == :TAUNT
      restmove=true if i == :REST
      weathermove=true if (i == :SUNNYDAY || i == :RAINDANCE || i == :HAIL || i == :SANDSTORM || i == :SHADOWSKY)
      fieldmove=true if (i == :GRASSYTERRAIN || i == :ELECTRICTERRAIN || i == :MISTYTERRAIN || i == :PSYCHICTERRAIN || i == :MIST || i == :IONDELUGE || i == :TOPSYTURVY)
    end
    monRoles.push(:SWEEPER) 		if mon.ev[:ATTACK]>251 && (mon.nature==:MODEST || mon.nature==:JOLLY || mon.nature==:TIMID || mon.nature==:ADAMANT) || (mon.item==(:CHOICEBAND) || mon.item==(:CHOICESPECS) || mon.item==(:CHOICESCARF) || mon.ability == :GORILLATACTICS)
    monRoles.push(:PHYSICALWALL) if healingmove && (mon.ev[:DEFENSE]>251 && (mon.nature==:BOLD || mon.nature==:RELAXED || mon.nature==:IMPISH || mon.nature==:LAX))
    monRoles.push(:SPECIALWALL)	if healingmove && (mon.ev[:SPECIAL_DEFENSE]>251 && (mon.nature==:CALM || mon.nature==:GENTLE || mon.nature==:SASSY || mon.nature==:CAREFUL))
    monRoles.push(:CLERIC) 		if curemove || (wishmove && mon.ev[:HP]>251)
    monRoles.push(:PHAZER) 		if phasemove
    monRoles.push(:SCREENER) 	if mon.item==(:LIGHTCLAY) && screenmove
    monRoles.push(:PIVOT) 		if (pivotmove && healingmove) || (mon.ability == :REGENERATOR)
    monRoles.push(:SPINNER) 		if spinmove
    monRoles.push(:TANK) 		if (mon.ev[:HP]>251 && !healingmove) || mon.item==(:ASSAULTVEST)
    monRoles.push(:BATONPASSER) 	if batonmove
    monRoles.push(:STALLBREAKER) if tauntmove || mon.item==(:CHOICEBAND) || mon.item==(:CHOICESPECS) || mon.ability == :GORILLATACTICS
    monRoles.push(:STATUSABSORBER) if restmove || (mon.ability == :COMATOSE) || mon.item==(:TOXICORB) || mon.item==(:FLAMEORB) || (mon.ability == :GUTS) || (mon.ability == :QUICKFEET)|| (mon.ability == :FLAREBOOST) || (mon.ability == :TOXICBOOST) || (mon.ability == :NATURALCURE) || (mon.ability == :MAGICGUARD) || (mon.ability == :MAGICBOUNCE) || (mon.species == :ZANGOOSE && mon.item == :ZANGCREST) || hydrationCheck(mon)
    monRoles.push(:TRAPPER) 		if (mon.ability == :SHADOWTAG) || (mon.ability == :ARENATRAP) || (mon.ability == :MAGNETPULL)
    monRoles.push(:WEATHERSETTER) if weathermove || (mon.ability == :DROUGHT) || (mon.ability == :SANDSPIT)  || (mon.ability == :SANDSTREAM) || (mon.ability == :DRIZZLE) || (mon.ability == :SNOWWARNING) || (mon.ability == :PRIMORDIALSEA) || (mon.ability == :DESOLATELAND) || (mon.ability == :DELTASTREAM)
    monRoles.push(:FIELDSETTER) 	if fieldmove || (mon.ability == :GRASSYSURGE) || (mon.ability == :ELECTRICSURGE) || (mon.ability == :MISTYSURGE) || (mon.ability == :PSYCHICSURGE) || mon.item==(:AMPLIFIELDROCK)|| (mon.ability == :DARKSURGE) 
    monRoles.push(:SECOND) 		if secondhighest
    partyRoles.push(monRoles)
  end
  return partyRoles[0] if targetmon
  return partyRoles
end