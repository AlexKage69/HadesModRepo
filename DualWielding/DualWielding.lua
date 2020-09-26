
-- SwordWeapon : Stygian Blade
--   SwordBaseUpgradeTrait : Aspect of Zagreus
--   SwordCriticalParryTrait : Aspect of Nemesis
--   DislodgeAmmoTrait : Aspect of Poseidon
--   SwordConsecrationTrait : Aspect of Arthur
-- SpearWeapon : Eternal Spear
--   SpearBaseUpgradeTrait : Aspect of Zagreus
--   SpearTeleportTrait : Aspect of Achilles
--   SpearWeaveTrait : Aspect of Hades
--   SpearSpinTravel : Aspect of Guan Yu
-- ShieldWeapon : Shield of Chaos
--   ShieldBaseUpgradeTrait : Aspect of Zagreus
--   ShieldTwoShieldTrait : Aspect of Zeus
--   ShieldRushBonusProjectileTrait : Aspect of Chaos
--   ShieldLoadAmmoTrait : Aspect of Beowulf
-- BowWeapon : Heart-Seeking Bow
--   BowBaseUpgradeTrait : Aspect of Zagreus
--   BowLoadAmmoTrait : Aspect of Hera
--   BowMarkHomingTrait : Aspect of Chiron
--   BowBondTrait : Aspect of Rama
-- FistWeapon : Twin Fists
--   FistBaseUpgradeTrait : Aspect of Zagreus
--   FistVacuumTrait : Aspect of Talos
--   FistWeaveTrait : Aspect of Demeter
--   FistDetonateTrait : Aspect of Gilgamesh
-- GunWeapon : Adamant Rail
--   GunBaseUpgradeTrait : Aspect of Zagreus
--   GunManualReloadTrait : Aspect of Hestia
--   GunGrenadeSelfEmpowerTrait : Aspect of Eris
--   GunLoadedGrenadeTrait : Aspect of Lucifer

WeaponList = {
  SwordWeapon =
  {
    Name = "SwordWeapon",
    Icon = "Codex_Portrait_Sword",
    Aspects =
    {
      "SwordBaseUpgradeTrait", "SwordCriticalParryTrait", "DislodgeAmmoTrait", "SwordConsecrationTrait",
    },
  },
  SpearWeapon =
  {
    Name = "SpearWeapon",
    Icon = "Codex_Portrait_Spear",
    Aspects =
    {
      "SpearBaseUpgradeTrait", "SpearTeleportTrait", "SpearWeaveTrait", "SpearSpinTravel",
    },
  },
  ShieldWeapon =
  {
    Name = "ShieldWeapon",
    Icon = "Codex_Portrait_Shield",
    Aspects =
    {
      "ShieldBaseUpgradeTrait", "ShieldRushBonusProjectileTrait", "ShieldTwoShieldTrait", "ShieldLoadAmmoTrait",
    },
  },
  BowWeapon =
  {
    Name = "BowWeapon",
    Icon = "Codex_Portrait_Bow",
    Aspects =
    {
      "BowBaseUpgradeTrait", "BowMarkHomingTrait", "BowLoadAmmoTrait", "BowBondTrait",
    },
  },
  FistWeapon =
  {
    Name = "FistWeapon",
    Icon = "Codex_Portrait_Fist",
    Aspects =
    {
      "FistBaseUpgradeTrait", "FistVacuumTrait", "FistWeaveTrait", "FistDetonateTrait",
    },
  },
  GunWeapon =
  {
    Name = "GunWeapon",
    Icon = "Codex_Portrait_Gun",
    Aspects =
    {
      "GunBaseUpgradeTrait", "GunGrenadeSelfEmpowerTrait", "GunManualReloadTrait", "GunLoadedGrenadeTrait",
    },
  },
}

local debug = false
OnAnyLoad{function(triggerArgs)
  if ModUtil ~= nil then
    debug = true
  end
end
}

DualWieldingConfig = { }

DualWieldingScreen = { Components = {} }

local swapcd = _worldTime
local atkcd = _worldTime
local combo = 0
local canSwap = false

function ModCheckCooldown(name, time)
  if time == nil then
    return
  end
  if name == nil then
    name = _worldTime
    return false
  end
  if _worldTime > name + time then
    name = _worldTime
    return true
  end
  return false
end

function SwapCounter()
  if canSwap then
    CreateAnimation({ Name = "SkillProcFeedbackFx", DestinationId = CurrentRun.Hero.ObjectId, Scale = 1.2 })
    return
  end
  if combo >= 5 and ModCheckCooldown(swapcd, 5.0) then
    canSwap = true
    combo = 0
    CreateAnimation({ Name = "SkillProcFeedbackFx", DestinationId = CurrentRun.Hero.ObjectId, Scale = 1.2 })
  else
    combo = combo + 1
  end
end

function SwitchWeapon()
  if DualWieldingConfig == nil or DualWieldingConfig.weapon1 == nil or DualWieldingConfig.weapon2 == nil then
    if debug then
      ModUtil.Hades.PrintStack("Config is empty or incomplete!")
    end
    return
  end
  local weapon = GetEquippedWeapon()
  if weapon == DualWieldingConfig.weapon1 and not HeroHasTrait(DualWieldingConfig.weapon2aspect) then
    RemoveTrait(CurrentRun.Hero, DualWieldingConfig.weapon1aspect)
    EquipPlayerWeapon(WeaponData[DualWieldingConfig.weapon2], { PreLoadBinks = true })
    AddTraitToHero({ TraitData = GetProcessedTraitData({ Unit = CurrentRun.Hero, TraitName = DualWieldingConfig.weapon2aspect,
    Rarity = GetRarityKey(GetWeaponUpgradeLevel( DualWieldingConfig.weapon2, DualWieldingConfig.weapon2aspectIndex )) })})
  else
    RemoveTrait(CurrentRun.Hero, DualWieldingConfig.weapon2aspect)
    EquipPlayerWeapon(WeaponData[DualWieldingConfig.weapon1], { PreLoadBinks = true })
    AddTraitToHero({ TraitData = GetProcessedTraitData({ Unit = CurrentRun.Hero, TraitName = DualWieldingConfig.weapon1aspect,
    Rarity = GetRarityKey(GetWeaponUpgradeLevel( DualWieldingConfig.weapon1, DualWieldingConfig.weapon1aspectIndex )) })})
  end
  ReloadAllTraits()
end

function SelectDualWieldingWeapon(screen, button)
  if button.Slot == 1 then
    DualWieldingConfig.weapon1 = button.Weapon
    DualWieldingConfig.weapon1aspect = button.Aspect
    DualWieldingConfig.weapon1aspectIndex = button.Index
  else
    DualWieldingConfig.weapon2 = button.Weapon
    DualWieldingConfig.weapon2aspect = button.Aspect
    DualWieldingConfig.weapon2aspectIndex = button.Index
  end
end

function OpenDualwieldingConfigMenu()
  ScreenAnchors.DualWieldingScreen = DeepCopyTable(DualWieldingScreen)
  local screen = ScreenAnchors.DualWieldingScreen
  local components = screen.Components
  screen.Name = "DualWieldingConfigMenu"
  screen.RowStartX = -495
  screen.RowStartY = -170
  OnScreenOpened({ Flag = screen.Name, PersistCombatUI = true })
  SetConfigOption({ Name = "UseOcclusion", Value = false })
  FreezePlayerUnit()
  EnableShopGamepadCursor()
  PlaySound({ Name = "/SFX/Menu Sounds/GodBoonInteract" })
  --Background
  components.BackgroundDim = CreateScreenComponent({ Name = "rectangle01", Group = "DualWielding" })
  components.Background = CreateScreenComponent({ Name = "BlankObstacle", Group = "DualWielding" })
  SetScale({ Id = components.BackgroundDim.Id, Fraction = 4 })
  SetColor({ Id = components.BackgroundDim.Id, Color = {0.090, 0.055, 0.157, 0.8} })
  components.LeftPart = CreateScreenComponent({ Name = "TraitTrayBackground", Group = "DualWielding", X = 830, Y = 400})
  components.MiddlePart = CreateScreenComponent({ Name = "TraitTray_Center", Group = "DualWielding", X = 490, Y = 464 })
  components.RightPart = CreateScreenComponent({ Name = "TraitTray_Right", Group = "DualWielding", X = 1710, Y = 423 })
  SetScaleY({Id = components.LeftPart.Id, Fraction = 1.3})
  SetScaleY({Id = components.MiddlePart.Id, Fraction = 1.3})
  SetScaleX({Id = components.MiddlePart.Id, Fraction = 10})
  SetScaleY({Id = components.RightPart.Id, Fraction = 1.3})
  --Title
  CreateTextBox({ Id = components.Background.Id, Text = "DualWielding Config Menu", FontSize = 34,
  OffsetX = 100, OffsetY = -370, Color = Color.White, Font = "SpectralSCLight",
  ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 1}, Justification = "Center" })
  --Close button
  components.CloseButton = CreateScreenComponent({ Name = "ButtonClose", Scale = 0.7, Group = "DualWielding" })
  Attach({ Id = components.CloseButton.Id, DestinationId = components.Background.Id, OffsetX = 100, OffsetY = ScreenCenterY - 70 })
  components.CloseButton.OnPressedFunctionName = "CloseDualWieldingConfigMenu"
  components.CloseButton.ControlHotkey = "Cancel"
  --Display weapon choice
  --Weapon 1
  CreateTextBox({ Id = components.Background.Id, Text = "Weapon 1", FontSize = 19,
  OffsetX = 100, OffsetY = -300, Width = 840, Color = Color.White, Font = "UbuntuMonoBold",
  ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 1}, Justification = "Center" })
  local index = 1
  for i, weapon in pairs (WeaponList) do
    local purchaseButtonKey = "PurchaseButton"..index
    local index2 = 1
    local rowoffset = 230
    local columnoffset = 220
    local numperrow = 6
    local offsetX = screen.RowStartX + columnoffset * ((index - 1) % numperrow)
    local offsetY = screen.RowStartY + rowoffset * (math.floor((index - 1) / numperrow))
    components[purchaseButtonKey] = CreateScreenComponent({ Name = "rectangle01", Group = "DualWielding", Scale = 0.4, })
    SetAnimation({ DestinationId = components[purchaseButtonKey].Id, Name = weapon.Icon })
    SetAlpha({ Id = components[purchaseButtonKey].Id, Fraction = 1 })
    SetThingProperty({ Property = "Ambient", Value = 0.0, DestinationId = components[purchaseButtonKey].Id })
    Attach({ Id = components[purchaseButtonKey].Id, DestinationId = components.Background.Id, OffsetX = offsetX, OffsetY = offsetY })
    offsetY = offsetY - 75
    for t, aspect in pairs (weapon.Aspects) do
      local aspectPurchaseButtonKey = "AspectPurchaseButton"..index..t
      local aspectRowOffset = 45
      local aspectOffsetX = offsetX + 110
      local aspectOffsetY = offsetY + aspectRowOffset * (math.floor(t - 1))
      components[aspectPurchaseButtonKey] = CreateScreenComponent({ Name = "BoonSlot1", Group = "DualWielding", Scale = 0.16, })
      components[aspectPurchaseButtonKey].OnPressedFunctionName = "SelectDualWieldingWeapon"
      components[aspectPurchaseButtonKey].Slot = 1
      components[aspectPurchaseButtonKey].Index = t
      components[aspectPurchaseButtonKey].Weapon = weapon.Name
      components[aspectPurchaseButtonKey].Aspect = aspect
      Attach({ Id = components[aspectPurchaseButtonKey].Id, DestinationId = components.Background.Id, OffsetX = aspectOffsetX, OffsetY = aspectOffsetY })
      CreateTextBox({ Id = components[aspectPurchaseButtonKey].Id, Text = aspect,
        FontSize = 15, OffsetX = 0, OffsetY = 0, Width = 720, Color = Color.White, Font = "AlegreyaSansSCLight",
        ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset = {0, 2}, Justification = "Center"
      })
      index2 = index2 +1
    end
    index = index + 1
  end
  --Weapon 2
  CreateTextBox({ Id = components.Background.Id, Text = "Weapon 2", FontSize = 19,
  OffsetX = 100, OffsetY = -40, Width = 840, Color = Color.White, Font = "UbuntuMonoBold",
  ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 1}, Justification = "Center" })
  for i, weapon in pairs (WeaponList) do
    local purchaseButtonKey = "PurchaseButton"..index
    local index2 = 1
    local rowoffset = 230
    local columnoffset = 220
    local numperrow = 6
    local offsetX = screen.RowStartX + columnoffset * ((index - 1) % numperrow)
    local offsetY = screen.RowStartY + rowoffset * (math.floor((index - 1) / numperrow))
    components[purchaseButtonKey] = CreateScreenComponent({ Name = "rectangle01", Group = "DualWielding", Scale = 0.4, })
    SetAnimation({ DestinationId = components[purchaseButtonKey].Id, Name = weapon.Icon })
    SetAlpha({ Id = components[purchaseButtonKey].Id, Fraction = 1 })
    SetThingProperty({ Property = "Ambient", Value = 0.0, DestinationId = components[purchaseButtonKey].Id })
    Attach({ Id = components[purchaseButtonKey].Id, DestinationId = components.Background.Id, OffsetX = offsetX, OffsetY = offsetY })
    offsetY = offsetY - 75
    for t, aspect in pairs (weapon.Aspects) do
      local aspectPurchaseButtonKey = "AspectPurchaseButton"..index..t
      local aspectRowOffset = 45
      local aspectOffsetX = offsetX + 110
      local aspectOffsetY = offsetY + aspectRowOffset * (math.floor(t - 1))
      components[aspectPurchaseButtonKey] = CreateScreenComponent({ Name = "BoonSlot1", Group = "DualWielding", Scale = 0.16, })
      components[aspectPurchaseButtonKey].OnPressedFunctionName = "SelectDualWieldingWeapon"
      components[aspectPurchaseButtonKey].Slot = 2
      components[aspectPurchaseButtonKey].Index = t
      components[aspectPurchaseButtonKey].Weapon = weapon.Name
      components[aspectPurchaseButtonKey].Aspect = aspect
      Attach({ Id = components[aspectPurchaseButtonKey].Id, DestinationId = components.Background.Id, OffsetX = aspectOffsetX, OffsetY = aspectOffsetY })
      CreateTextBox({ Id = components[aspectPurchaseButtonKey].Id, Text = aspect,
        FontSize = 15, OffsetX = 0, OffsetY = 0, Width = 720, Color = Color.White, Font = "AlegreyaSansSCLight",
        ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset = {0, 2}, Justification = "Center"
      })
      index2 = index2 +1
    end
    index = index + 1
  end
  --End
  screen.KeepOpen = true
  HandleScreenInput(screen)
end

function CloseDualWieldingConfigMenu(screen, button)
  DisableShopGamepadCursor()
  SetConfigOption({ Name = "FreeFormSelectWrapY", Value = false })
  SetConfigOption({ Name = "UseOcclusion", Value = true })
  CloseScreen(GetAllIds(screen.Components), 0.1)
  PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENU" })
  ScreenAnchors.DualWieldingScreen = nil
  UnfreezePlayerUnit()
  screen.KeepOpen = false
  OnScreenClosed({ Flag = screen.Name })
end

OnHit{
  function (triggerArgs)
    if triggerArgs.TriggeredByTable ~= nil and not triggerArgs.IsInvulnerable and triggerArgs.AttackerId == CurrentRun.Hero.ObjectId then
      SwapCounter()
    end
  end
}

OnControlPressed{ "Reload",
  function (triggerArgs)
    if canSwap then
      canSwap = false
      SwitchWeapon()
    end
  end
}

OnControlPressed{ "Shout",
	function( triggerArgs )
		local ticks = 0
		wait(0.25)
		while IsControlDown({ Name = "Shout" }) do
			ticks = ticks + 1
			if ticks > 3 then
        OpenDualwieldingConfigMenu()
				return
			end
			if ticks > 0 then
        ModUtil.Hades.PrintStack(ticks,0.5)
			end
			wait(0.5)
		end
	end
}
