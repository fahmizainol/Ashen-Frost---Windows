
#=====================================================================================================
# Settings
#=====================================================================================================
module Settings
  # The maximum amount of money the player can deposit in the bank.
  MAX_BANK            = 999_999_999
  # The variable referring to the player's bank balance.
  BALANCE             = 29
end

#===========================================================================
# Deposit/Withdrawal Script - ATM
# Created by CBC22; modified by Michael
#===========================================================================
def pbDepositATM
  pbSEPlay("PC open")
  params = ChooseNumberParams.new
  params.setMaxDigits(6)
  params.setRange(1, $player.money)
  params.setInitialValue($player.money)
  params.setCancelValue(0)
  if $player.money < 1
    pbMessage(_INTL("\\G\\DP\\se[GUI sel buzzer]\\xn[ATM]Insufficient funds. You must have at least ${1} to make a deposit.", 1))
  elsif pbGet(Settings::BALANCE) == Settings::MAX_BANK
    pbMessage(_INTL("\\G\\DP\\se[GUI sel buzzer]\\xn[ATM]Your bank account is full. Transaction cannot be completed."))
  else 
    qty = pbMessageChooseNumber(_INTL("\\G\\DP\\se[PC access]\\xn[ATM]How much would you like to deposit?"), params)
    maxqty = Settings::MAX_BANK - pbGet(Settings::BALANCE)
    if qty > maxqty
      pbMessage(_INTL("\\G\\DP\\se[PC access]\\xn[ATM]Only ${1} was deposited. Bank account is now full.", maxqty))
      $game_variables[Settings::BALANCE] += maxqty
      $player.money -= maxqty
    else
      $game_variables[Settings::BALANCE] += qty
      $player.money -= qty
    end
    pbMessage(_INTL("\\G\\DP\\se[PC access]\\xn[ATM]Transaction completed.")) if qty > 0
  end
end

def pbWithdrawATM
  pbSEPlay("PC open")
  params = ChooseNumberParams.new
  params.setMaxDigits(9)
  params.setRange(1, pbGet(Settings::BALANCE))
  params.setInitialValue(pbGet(Settings::BALANCE))
  params.setCancelValue(0)
  maxqty = Settings::MAX_MONEY - $player.money
  if pbGet(Settings::BALANCE) == 0
    pbMessage(_INTL("\\G\\DP\\se[GUI sel buzzer]\\xn[ATM]Insufficient funds. No money in account."))
  else 
    qty = pbMessageChooseNumber(_INTL("\\G\\DP\\se[PC access]\\xn[ATM]How much would you like to withdraw?"), params)
    if qty > maxqty
      pbMessage(_INTL("\\G\\DP\\se[PC access]\\xn[ATM]Only ${1} was withdrew. Cannot carry any more money.", maxqty))
      $game_variables[Settings::BALANCE] -= maxqty
      $player.money += maxqty
    else
      $game_variables[Settings::BALANCE] -= qty
      $player.money += qty
    end
    pbMessage(_INTL("\\G\\DP\\se[PC access]\\xn[ATM]Transaction completed.")) if qty > 0
  end
end

#===========================================================================
# Deposit/Withdrawal Script - Bank
# Created by CBC22; modified by Michael
#===========================================================================
def pbDepositBank
  params = ChooseNumberParams.new
  params.setMaxDigits(6)
  params.setRange(1, $player.money)
  params.setInitialValue($player.money)
  params.setCancelValue(0)
  if $player.money < 1
    pbMessage(_INTL("\\G\\DP\\xn[Teller]\\rSorry, you must have at least ${1} to make a deposit.", 1))
  elsif pbGet(Settings::BALANCE) == Settings::MAX_BANK
    pbMessage(_INTL("\\G\\DP\\xn[Teller]\\rYour Bank Account is full, you cannot deposit any more money."))
  else 
    qty = pbMessageChooseNumber(_INTL("\\G\\DP\\xn[Teller]\\rHow much would you like to deposit?"), params)
    maxqty = Settings::MAX_BANK - pbGet(Settings::BALANCE)
    if qty > maxqty
      pbMessage(_INTL("\\G\\DP\\xn[Teller]\\rYou are only allowed to deposit ${1}.", maxqty))
      $game_variables[Settings::BALANCE] += maxqty
      $player.money -= maxqty
    else
      $game_variables[Settings::BALANCE] += qty
      $player.money -= qty
    end
    pbMessage(_INTL("\\G\\DP\\xn[Teller]\\rAll done!")) if qty > 0
  end
end
  
def pbWithdrawBank
  params = ChooseNumberParams.new
  params.setMaxDigits(9)
  params.setRange(1, pbGet(Settings::BALANCE))
  params.setInitialValue(pbGet(Settings::BALANCE))
  params.setCancelValue(0)
  maxqty = Settings::MAX_MONEY - $player.money
  if pbGet(Settings::BALANCE) == 0
      pbMessage(_INTL("\\G\\DP\\xn[Teller]\\rYou do not have any money to withdraw."))
  else 
    qty = pbMessageChooseNumber(_INTL("\\G\\DP\\xn[Teller]\\rHow much would you like to withdraw?"), params)
    if qty > maxqty
      pbMessage(_INTL("\\G\\DP\\xn[Teller]\\rWe were only allowed to give you ${1}.", maxqty))
      $game_variables[Settings::BALANCE] -= maxqty
      $player.money += maxqty
    else
      $game_variables[Settings::BALANCE] -= qty
      $player.money += qty
    end
    pbMessage(_INTL("\\G\\DP\\xn[Teller]\\rAll done!")) if qty > 0
  end
end
  
#===========================================================================
# Loan Checker Script
# Created by Michael
#===========================================================================
EventHandlers.add(:on_player_step_taken, :loan_checker,
    proc {
      # Check for money/playing as Sylvester
      next if $game_variables[31] < 1
      next if !$player.character_ID == 1
      next if $game_switches[167]
      # Handler script
      if $PokemonGlobal.loanSteps >= 5000 
        pbMessage(_INTL("\\se[Phone Ring]\\xn[Teller]\\r Hello, this is Charley's bank calling!"))
        pbMessage(_INTL("\\xn[Teller]\\r Your bank accounts have been frozen!"))
        pbMessage(_INTL("\\xn[Teller]\\r Pay your loan in full to have this undone."))
        pbSEStop
        $game_switches[167] = true
      end
      $PokemonGlobal.loanSteps += 1
    }
  )