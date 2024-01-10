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
