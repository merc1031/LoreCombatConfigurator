--- @meta
--- @diagnostic disable

--- @class Range
--- @field Min integer
-- @field Max integer

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
--- @field DamageType string
--- @field RechargeValues Range | nil

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
--- @field VarsJson Config
--- @field SpellsAdded table<Guid, table<Guid, string[]>>
--- @field PassivesAdded table<Guid, table<Guid, string[]>>
--- @field ImplicatedGuids table<Guid, table<Guid, string[]>>
--- @field EntityCache table<Guid, EntityCacheItem>
--- @field ActionResources table<string, Guid>
--- @field Tags table<string, Guid>
--- @field Races table<string, Guid>
--- @field CombatGroups table<string, Template>
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
--- @field Archetypes table<string, boolean>
--- @field AIHints table<string, boolean>
--- @field ConfigHash integer

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
--- @field ConservativeActionPointBoosts boolean
--- @field SpecificAttackRollsStack boolean
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
--- @field RollBonusAttack ScalingLevelScaledConfig
--- @field RollBonusMeleeWeaponAttack ScalingLevelScaledConfig
--- @field RollBonusRangedWeaponAttack ScalingLevelScaledConfig
--- @field RollBonusMeleeSpellAttack ScalingLevelScaledConfig
--- @field RollBonusRangedSpellAttack ScalingLevelScaledConfig
--- @field RollBonusMeleeUnarmedAttack ScalingLevelScaledConfig
--- @field RollBonusRangedUnarmedAttack ScalingLevelScaledConfig
--- @field Damage ScalingLevelScaledConfig
--- @field AC ScalingLevelScaledConfig
--- @field Movement ScalingLevelScaledConfig
--- @field RollBonusSavingThrow ScalingLevelScaledConfig
--- @field SpellSaveDC ScalingLevelScaledConfig
--- @field Initiative ScalingLevelScaledConfig

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

--- @class DebugModeConfig
--- @field Enabled boolean
--- @field AddSpells boolean
--- @field MovementSpeedMultiplier number

--- @class Config
--- @field EnemiesEnabled boolean
--- @field BossesEnabled boolean
--- @field AlliesEnabled boolean
--- @field FollowersEnabled boolean
--- @field FollowersBossesEnabled boolean
--- @field SummonsEnabled boolean
--- @field CasterArchetypeCheck boolean
--- @field HealerArchetypeCheck boolean
--- @field FighterArchetypeCheck boolean
--- @field MonkArchetypeCheck boolean
--- @field RogueArchetypeCheck boolean
--- @field RangerArchetypeCheck boolean
--- @field WarlockArchetypeCheck boolean
--- @field ClericArchetypeCheck boolean
--- @field DruidArchetypeCheck boolean
--- @field BarbarianArchetypeCheck boolean
--- @field BardArchetypeCheck boolean
--- @field PaladinArchetypeCheck boolean
--- @field ConsistentHash boolean
--- @field ConsistentHashSalt integer | nil
--- @field DebugDisableEE boolean
--- @field Verbosity integer
--- @field DebugMode DebugModeConfig
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
--- @field Defaults EntityConfig
--- @field Enemies EntityConfig
--- @field Bosses EntityConfig
--- @field Allies EntityConfig
--- @field Followers EntityConfig
--- @field FollowersBosses EntityConfig
--- @field Summons EntityConfig
--- @field [Guid] EntityConfig

--- @class EnrichedEntity
--- @field Entity Entity
--- @field Guid Guid
--- @field ShortGuid Guid
--- @field FullGuid Guid
--- @field IsCharacter boolean
--- @field IsPartyMember boolean
--- @field IsPartyFollower boolean
--- @field IsOurSummon boolean
--- @field IsEnemy boolean
--- @field IsOrigin boolean
--- @field IsBoss boolean
--- @field HasPlayerData boolean
--- @field IsPlayer boolean
--- @field AlreadyModified boolean
--- @field SameHash boolean
--- @field IsAdditionalEnemiesSpecialBoss boolean
--- @field ConfigHash integer
EnrichedEntity = {}

--- @class LCC_Boosted
--- @field General boolean

--- @class LCC_BoostedWithHash
--- @field Hash integer | nil

--- @class LCC_BoostedWithClassification
--- @field Classification string | nil

--- @class LCC_DebugMode_RestoreSettings
--- @field OriginalMovementSpeed number
--- @field SpellsAdded boolean

--- @class LCCUserVars
--- @field LCC_PassivesAdded table<string, string>
--- @field LCC_BoostsAdded string[]
--- @field LCC_Boosted LCC_Boosted
--- @field LCC_BoostedWithHash LCC_BoostedWithHash
--- @field LCC_BoostedWithClassification LCC_BoostedWithClassification
--- @field LCC_DebugMode_RestoreSettings LCC_DebugMode_RestoreSettings

-- Might belong in MetaExtender.lua

--- @class Entity
--- @field Uuid EntityUuid
--- @field Vars LCCUserVars
--- @field ServerCharacter Character | nil
--- @field ServerItem Item | nil
--- @field PassiveContainer PassiveContainer
--- @field BoostsContainer BoostsContainer
--- @field ActionResources ActionResources
--- @field Health Health
--- @field Stats Stats

--- @class Character
--- @field Character nil | Character
--- @field Template Template
--- @field PlayerData any | nil
--- @field IsPlayer boolean | nil

--- @class Item
--- @field Template Template

--- @class Template
--- @field Name string

--- @class PassiveContainer
--- @field Passives Passive[]

--- @class Passive
--- @field PassiveId string

--- @class BoostsContainer
--- @field Boosts table<string, Boost>

--- @class ActionResources
--- @field Resources table<Guid, ActionResource[]>

--- @class ActionResource
--- @field MaxAmount integer

--- @class Health
--- @field AC integer
--- @field MaxHp integer

--- @class Stats
--- @field SpellCastingAbility string
--- @field InitiativeBonus integer

--- @class EntityUuid
--- @field EntityUuid Guid

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

--- @class GameStateEvent
--- @field FromState string
--- @field ToState string

--- @class Handle
--- @field DisplayName DisplayName

--- @class DisplayName
--- @field NameKey NameKey

--- @class NameKey
--- @field Handle LocalizationHandle

--- @class LocalizationHandle
--- @field Handle string
