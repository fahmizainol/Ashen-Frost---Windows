Name         = Edited Consistent AI
Version      = 2.0.3
Essentials   = 20.1
Requires     = v20.1 Hotfixes,1.0.7
Optional     = Essentials Deluxe,1.0
Optional     = Improved AI,1.0
Optional     = Generation 9 Pack,1.0
Optional     = Soulstones 2 Specific Changes,0.1
Website      = https://eeveeexpo.com/resources/1272/
Credits      = DemICE,Azery(Recovery and EndOfTurnEffects code),Marcello(Priority section in EffectScores)
#
#v2.0.1
#- Fixes AI using Fake Out after the first turn.
#- Fixes AI not having a low enough score to not use some status moves on pokemon with Guts or other abilities that would benefit from it.
#
#v2.0.3
#- Added certain Generation 9 methods that I've been using in my AI and realized people without the Generation 9 Pack would have crashes.
#
#v2.0.2
#- Cleaned up remnant code from Ashen Frost that I had missed that was causing AI crashes.
#- Made my plugin to load after Essentials Deluxe to avoid its methods overriding mine and causing crashes. (I have added support for Essentials Deluxe in my AI anyway)
#
#v2.0.1
#- Fixed AI getting insane scores on speed reducing moves like icy wind against slower pokemon when it could just OHKO them with another move instead.
#
#v2.0
#- Added a lot more move function specific code in AI Move EffectScores. AI should now have massively improved and consistent decision making for most moves.
#- Improved priority move related AI using Reborn's priority moves AI as a base
#- Reworked the process of selecting the proper damaging move. Most damaging moves whose power depends on other factors are now handled in pbGetMoveScoreDamage instead of pbGetMoveScoreFunctionCode and will be chosen based on their calcualted resulting damage rather than arbitary scoring.
#- A completely made from scratch AI on selecting the next pokemon to bring into battle that decides based on approximate incoming and outcoming damage calculation, speed comparison, and a lot of other factors. To achieve that a fake battler is created for every party member not yet into battle, and the one that gets the best outcome in a clash with the current opposing pokemon is chosen.
#- Reworked AI for usage of healing items in battle. Instead of arbitary scoring based on isolated factors and rng, it now basically uses logic similar to recovery moves for healing items,  and similar to set-up moves for X items, with the proper damage and other calculations to assist in decision making.
#- New code for the purpose of calculating if a pokemon will survive another pokemon's moves after taking into account damage calculation, abilities, items, priority moves on the following turn, and other factors.
#- Code that helps AI access the biggest threat in doubles+,  and prioritise targeting it.
#- Integration of the new elements from the Generation 9 Pack v2.0 for compatibility.
#- Emulation of "mind games" for sucker punch and wide guard.
#
#v1.0.1
#-Fixed an error when the AI tried to switch while having only 1 pokemon alive.