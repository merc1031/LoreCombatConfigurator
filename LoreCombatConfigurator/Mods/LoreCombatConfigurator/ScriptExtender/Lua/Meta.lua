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

--- @class SessionContext
--- @field VarsJson table
--- @field SpellsAdded table<Guid, table<Guid, string[]>>
--- @field PassivesAdded table<Guid, table<Guid, string[]>>
--- @field ImplicatedGuids table<Guid, table<Guid, string[]>>
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
