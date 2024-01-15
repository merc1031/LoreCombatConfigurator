--- @meta
--- @diagnostic disable

--- @class Spell
--- @field Name string
--- @field SpellFlags table<string, boolean>
--- @field Level integer
--- @field SpellSchool string
--- @field VerbalIntent string
--- @field UseCosts table<string, string>
--- @field Requirements table<string, table<string, boolean>>
--- @field AIFlags table<string, boolean>
--- @field CanAIUse boolean
--- @field CanUseInCombat boolean
--- @field Origin string
--
--- @class SpellSelector
--- @field SpellUUID string
--- @field Spells table<string, Spell>

--- @class PassiveSelector
--- @field UUID string
--- @field Passives string[]

--- @class Progression
--- @field Name string
--- @field PassivesAdded string[]
--- @field PassivesRemoved string[]
--- @field AddSpells SpellSelector[]
--- @field SelectSpells SpellSelector[]
--- @field SelectPassives PassiveSelector[]
--- @field Boosts string[]
--- @field Level integer
--- @field UUIDs Guid[]

--- @class Subclass
--- @field Name string
--- @field ParentGuid Guid
--- @field PrimaryAbility integer
--- @field ProgressionTableUUID Guid
--- @field Progression table<integer, Progression>
--- @field ResourceUUID Guid
--- @field SpellCastingAbility integer
--- @field SpellList Guid
--- @field Tags string[]

--- @class Class
--- @field Name string
--- @field ParentGuid Guid
--- @field PrimaryAbility integer
--- @field ProgressionTableUUID Guid
--- @field Progression table<integer, Progression>
--- @field ResourceUUID Guid
--- @field SpellCastingAbility integer
--- @field SpellList Guid
--- @field Tags string[]
--- @field Subclasses table<string, Subclass>

--- @class ClassSpells
--- @field Spells table<string, ClassSpell>
--- @field SpellsBySpellLevel table<string, string[]>
--- @field AbilitiesByLevel table<string, string[]>

--- @class ClassSpell
--- @field Spell Spell
--- @field ClassLevel integer

--- @class ClassPassives
--- @field Passives table<string, boolean>
--- @field PassivesByLevel table<string, string[]>

--- @alias Consumables "Arrow" | "Consumable" | "Grenade" | "Potion" | "Scroll" | "Throwable"
--- @alias ArmorSlot "Amulet" | "Boots" | "Breast" | "Cloak" | "Gloves" | "Helmet" | "Melee Offhand Weapon" | "Musical Instrument" | "Ring" | "Underwear" | "VanityBody" | "VanityBoots"
--- @alias WeaponSlot "Helmet" | "Melee Main Weapon" | "Melee Offhand Weapon" | "Ranged Main Weapon" | "Ranged Offhand Weapon"

--- @class Stat
--- @field Name string
--- @field Using string | nil

--- @class (exact) Consumable : Stat
--- @field ItemUseType Consumables
--- @field UseCosts string[]
--- @field RootTemplate Guid
--- @field ObjectCategory string
--- @field UseConditions string

--- @alias Unique 1 | 0

--- @class (exact) Armor : Stat
--- @field Slot ArmorSlot
--- @field Boosts string[]
--- @field RootTemplate Guid
--- @field PassivesOnEquip string[]
--- @field StatusOnEquip string[]
--- @field Unique Unique
--- @field ProficiencyGroup string[]

--- @class (exact) Weapon : Stat
--- @field Slot WeaponSlot
--- @field Boosts string[]
--- @field BoostsOnEquipMainHand string[]
--- @field BoostsOnEquipOffHand string[]
--- @field DefaultBoosts string[]
--- @field RootTemplate Guid
--- @field PassivesOnEquip string[]
--- @field StatusOnEquip string[]
--- @field Unique Unique
--- @field ProficiencyGroup string[]
--- @field UseConditions string
--- @field PersonalStatusImmunities string[]
--- @field WeaponProperties string[]
--- @field WeaponGroup string
--- @field DamageType string

--- @class ItemLists
--- @field Consumable table<Consumables, Consumable>
--- @field Armor table<ArmorSlot, Armor>
--- @field Weapon table<WeaponSlot, Weapon>

--- @class EntityCacheItem
--- @field SpellRoots table<string, boolean>

--- @class SessionContext
--- @field VarsJson table
--- @field SpellsAdded table<Guid, table<Guid, string[]>>
--- @field PassivesAdded table<Guid, table<Guid, string[]>>
--- @field ImplicatedGuids table<Guid, table<Guid, string[]>>
--- @field EntityCache table<Guid, table<Guid, EntityCacheItem>>
--- @field ActionResources table<string, Guid>
--- @field Tags table<string, Guid>
--- @field ConfigFailed integer
--- @field Log fun(level: integer, str: string) | nil
--- @field LogI fun(level: integer, indent: integer, str: string) | nil
--- @field EntityToKinds (fun(target: string): table<string, boolean> | nil) | nil
--- @field EntityToRestrictions (fun(target: string): table<string, boolean> | nil) | nil
--- @field SpellData table<string, Spell> | nil
--- @field SpellListsByClass table<string, ClassSpells> | nil
--- @field PassiveListsByClass table<string, ClassPassives> | nil
--- @field ItemLists ItemLists | nil
--- @field AbilityDependencies table<string, string[]> | nil
--- @field PassiveDependencies table<string, string[]> | nil
--- @field Archetypes table<string>
--- @field SessionLoaded boolean

--- @alias Enabled 0 | 1

--- @class LevelScaledBoostConfig
--- @field StaticBoost integer
--- @field LevelStepToIncrementOn integer
--- @field ValueToIncrementByOnLevel integer

--- @class ScalingLevelScaledConfig : LevelScaledBoostConfig
--- @field MaxPercentage integer
--- @field ScalingPercentage integer
--- @field ScalingLevelStepToIncrementOn integer

--- @class SpellsLevelGate
--- @field MinCharLevelForLevel1 integer
--- @field MinCharLevelForLevel2 integer
--- @field MinCharLevelForLevel3 integer
--- @field MinCharLevelForLevel4 integer
--- @field MinCharLevelForLevel5 integer
--- @field MinCharLevelForLevel6 integer
--- @field MinCharLevelForLevel7 integer
--- @field MinCharLevelForLevel8 integer
--- @field MinCharLevelForLevel9 integer

--- @class LevelGate
--- @field MinCharLevelForLevel1 integer
--- @field MinCharLevelForLevel2 integer
--- @field MinCharLevelForLevel3 integer
--- @field MinCharLevelForLevel4 integer
--- @field MinCharLevelForLevel5 integer
--- @field MinCharLevelForLevel6 integer
--- @field MinCharLevelForLevel7 integer
--- @field MinCharLevelForLevel8 integer
--- @field MinCharLevelForLevel9 integer
--- @field MinCharLevelForLevel10 integer
--- @field MinCharLevelForLevel11 integer
--- @field MinCharLevelForLevel12 integer
--- @field MinCharLevelForLevel13 integer
--- @field MinCharLevelForLevel14 integer
--- @field MinCharLevelForLevel15 integer
--- @field MinCharLevelForLevel16 integer
--- @field MinCharLevelForLevel17 integer
--- @field MinCharLevelForLevel18 integer
--- @field MinCharLevelForLevel19 integer
--- @field MinCharLevelForLevel20 integer

--- @class SpellAddedConfig : LevelScaledBoostConfig
--- @field LevelGate SpellsLevelGate

--- @class ClassSpecificAddedConfig : LevelScaledBoostConfig
--- @field LevelGate LevelGate

--- @class EntityConfig
--- @field ConservativeActionPointBoosts Enabled
--- @field SpellsAdded SpellAddedConfig
--- @field PassivesAdded ClassSpecificAddedConfig
--- @field AbilitiesAdded ClassSpecificAddedConfig
--- @field SpellSlotBoosts LevelScaledBoostConfig
--- @field ActionPointBoosts LevelScaledBoostConfig
--- @field BonusActionPointBoosts LevelScaledBoostConfig
--- @field RageBoosts LevelScaledBoostConfig
--- @field SorceryPointBoosts LevelScaledBoostConfig
--- @field TidesOfChaosBoosts LevelScaledBoostConfig
--- @field SuperiorityDieBoosts LevelScaledBoostConfig
--- @field WildShapeBoosts LevelScaledBoostConfig
--- @field NaturalRecoveryBoosts LevelScaledBoostConfig
--- @field FungalInfestationBoosts LevelScaledBoostConfig
--- @field LayOnHandsBoosts LevelScaledBoostConfig
--- @field ChannelOathBoosts LevelScaledBoostConfig
--- @field ChannelDivinityBoosts LevelScaledBoostConfig
--- @field KiPointBoosts LevelScaledBoostConfig
--- @field DeflectMissilesBoosts LevelScaledBoostConfig
--- @field SneakAttackBoosts LevelScaledBoostConfig
--- @field Health ScalingLevelScaledConfig
--- @field Dexterity ScalingLevelScaledConfig
--- @field Strength ScalingLevelScaledConfig
--- @field Constitution ScalingLevelScaledConfig
--- @field Intelligence ScalingLevelScaledConfig
--- @field Charisma ScalingLevelScaledConfig
--- @field Wisdom ScalingLevelScaledConfig
--- @field RollBonus ScalingLevelScaledConfig
--- @field Damage ScalingLevelScaledConfig
--- @field AC ScalingLevelScaledConfig
--- @field Movement ScalingLevelScaledConfig

--- @alias KindsConfig tabled<string, string[]>

--- @class SpellSchoolRestriction
--- @field Exclusive string[]

--- @class SpellRestriction
--- @field School SpellSchoolRestriction

--- @class AbilityCostRestriction
--- @field Restrict string[]

--- @class AbilityRestriction
--- @field Cost AbilityCostRestriction

--- @class Restriction
--- @field Spell SpellRestriction
--- @field Ability AbilityRestriction

--- @alias RestrictionsConfig table<string, Restriction>

--- @alias BlacklistConfig table<string, boolean>

--- @class Config
--- @field EnemiesEnabled Enabled
--- @field BossesEnabled Enabled
--- @field AlliesEnabled Enabled
--- @field FollowersEnabled Enabled
--- @field FollowersBossesEnabled Enabled
--- @field SummonsEnabled Enabled
--- @field Lore Enabled
--- @field CasterArchetypeCheck Enabled
--- @field HealerArchetypeCheck Enabled
--- @field FighterArchetypeCheck Enabled
--- @field MonkArchetypeCheck Enabled
--- @field RogueArchetypeCheck Enabled
--- @field RangerArchetypeCheck Enabled
--- @field WarlockArchetypeCheck Enabled
--- @field ClericArchetypeCheck Enabled
--- @field DruidArchetypeCheck Enabled
--- @field BarbarianArchetypeCheck Enabled
--- @field BardArchetypeCheck Enabled
--- @field PaladinArchetypeCheck Enabled
--- @field ConsistentHash Enabled
--- @field ConsistentHashSalt integer | nil
--- @field DebugDisableEE Enabled
--- @field Verbosity integer
--- @field Kinds KindsConfig
--- @field Restrictions RestrictionsConfig
--- @field BlacklistedAbilities BlacklistConfig
--- @field BlacklistedAbilities BlacklistConfig
--- @field BlacklistedPassives BlacklistConfig
--- @field BlacklistedAbilitiesByClass BlacklistConfig
--- @field BlacklistedPassivesByClass BlacklistConfig
--- @field BlacklistedLists BlacklistConfig
--- @field AbilityDependencies table<string, string[]>
--- @field PassiveDependencies table<string, string[]>



-- Might belong in MetaExtender.lua

--- @class Entity

--- @class BoostCause
--- @field Cause string

--- @class BoostParams
--- @field Boost string
--- @field Params string
--- @field Params2 string

--- @class BoostInfo
--- @field Cause BoostCause
--- @field Owner Entity
--- @field Params BoostParams

--- @class Boost
--- @field BoostInfo BoostInfo
