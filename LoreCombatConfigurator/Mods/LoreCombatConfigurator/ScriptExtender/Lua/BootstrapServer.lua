-- Courtesy to @Buns on Discord
function SafeGet(object, ...)
    local result = object
    local error = "SafeGet: object"
    if not result then
        error = error .. " is nil"
        return nil, error
    end
    local arg = {...}
    for i,v in ipairs(arg) do

        error = error .. "." .. tostring(v)

        local ok, maybe_err = pcall(function() return result[v] end)

        if not ok then
            error = error .. ":  " .. maybe_err
            return nil, error
        end

        result = result[v]
        if not result then
            error = error .. " is nil"
            return nil, error
        end
    end
    return result, nil
end

function ConsistentHash(salt, buckets, str, ...)
    local params = {...}
    for _, v in ipairs(params) do
        if v ~= nil then
            str = str .. tostring(v)
        end
    end
    local hash = 0
    for i=1,#str do
        hash = (((hash << 5) - hash) + string.byte(str, i)) & 0xFFFFFFFF
    end
    hash = hash ~ salt
    return hash % buckets
end

function ToSet(list)
    local tab = {}
    for _, l in ipairs(list) do
        tab[l] = true
    end
    return tab
end

function Split(inputStr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputStr, string.format("([^%s]+)", sep)) do
        table.insert(t, str)
    end
    return t
end

function TableCombine(t1, t2)
    return table.move(t1, 1, #t1, #t2 + 1, t2)
end

function ArrayToList(array)
    local list = {}
    for _, elem in pairs(array) do
        table.insert(list, elem)
    end
    return list
end

function Values(tab)
    local list = {}
    for key, elem in pairs(tab) do
        table.insert(list, elem)
    end
    return list
end

function Keys(tab)
    local list = {}
    for key, elem in pairs(tab) do
        table.insert(list, key)
    end
    return list
end

function DropBlacklisted(blacklist, elems)
    local filteredElems = {}
    for _, elem in ipairs(elems) do
        local inBlacklist = blacklist[elem]
        if inBlacklist == nil or not inBlacklist then
            table.insert(filteredElems, elem)
        end
    end
    return filteredElems
end

Restrictions = {
    DarkJusticiar_Caster = {},
    DarkJusticiar_Melee = {},
    DarkJusticiar_Ranger = {},
    Dragonborn_Barbarian = {},
    Dragonborn_Cleric = {},
    Dragonborn_Melee = {},
    Dragonborn_Ranger = {},
    Dwarf_Bard = {},
    Dwarf_Caster = {},
    Dwarf_Druid = {},
    Dwarf_Duergar_Barbarian = {},
    Dwarf_Duergar_Caster = {},
    Dwarf_Duergar_Cleric = {},
    Dwarf_Duergar_Melee = {},
    Dwarf_Duergar_Melee_StoneGuard = {},
    Dwarf_Duergar_Melee_Strong = {},
    Dwarf_Duergar_Ranger = {},
    Dwarf_Duergar_Ranger_Strong = {},
    Dwarf_Duergar_Rogue = {},
    Dwarf_Melee = {},
    Dwarf_Ranger = {},
    Dwarf_Rogue = {},
    END_Hellrider_Paladin = {},
    Elf_Barbarian = {},
    Elf_Caster = {},
    Elf_Drow_Caster = {},
    Elf_Drow_Rogue = {},
    Elf_Druid = {},
    Elf_Melee = {},
    Elf_Monk = {},
    Elf_Ranger = {},
    Elf_Rogue = {},
    Elf_ShadarKai_Ranger = {},
    Elf_Wood_Caster = {},
    FOR_Human_Cultist_Zariel_Paladin = {},
    FlamingFist_Human_Ranger = {},
    FlamingFist_Tiefling = {},
    GLO_Oathbreaker_Paladin = {},
    GOB_Dwarf_Warlock = {},
    Githyanki_Caster = {},
    Githyanki_Gish = {},
    Githyanki_Melee = {},
    Githyanki_Ranger = {},
    Githyanki_Warrior = {},
    Gnome_Caster = {},
    Gnome_Deep_Caster = {},
    Gnome_Druid = {},
    Gnome_Gondian_Caster = {},
    Gnome_Melee = {},
    Gnome_Monk = {},
    Gnome_Ranger = {},
    Gnome_Rogue = {},
    Goblin_Boss = {},
    Goblin_Caster = {},
    Goblin_Cleric = {},
    Goblin_Melee = {},
    Goblin_Melee_Strong = {},
    Goblin_Ranger = {},
    Goblin_Ranger_Strong = {},
    Goblin_Warlock = {},
    Hag_Green = {
        Spell = {
            School = {
                Exclusive = {
                    "Illusion",
                    "Enchantment",
                    "Transmutation",
                },
            },
        },
        Ability = {
            Cost = {
                Restrict = {
                    "WildShape",
                },
            },
        },
    },
    HalfElf_Barbarian = {},
    HalfElf_Bard = {},
    HalfElf_Caster = {},
    HalfElf_Fighter_Rogue = {},
    HalfElf_Monk = {},
    HalfElf_Ranger = {},
    HalfOrc_Barbarian = {},
    HalfOrc_Caster = {},
    HalfOrc_Melee = {},
    Halfling_Caster = {},
    Halfling_Druid = {},
    Halfling_Melee = {},
    Halfling_Ranger = {},
    Halfling_Rogue = {},
    Human_Barbarian = {},
    Human_Bard = {},
    Human_Caster = {},
    Human_Cleric = {},
    Human_Druid = {},
    Human_Melee = {},
    Human_Ranger = {},
    Human_Rogue = {},
    KillerReplica_Barbarian = {},
    KillerReplica_Cleric = {},
    KillerReplica_Druid = {},
    KillerReplica_Fighter = {},
    KillerReplica_Monk = {},
    KillerReplica_Paladin = {},
    KillerReplica_Ranger = {},
    KillerReplica_Rogue = {},
    KillerReplica_Sorcerer = {},
    KillerReplica_Warlock = {},
    KillerReplica_Wizard = {},
    Kobold_Inventor = {},
    Kobold_Melee = {},
    Kobold_Ranger = {},
    Kuotoa_Caster = {
        Spell = {
            School = {
                Exclusive = {
                    "Evocation",
                    "Enchantment",
                    "Abjuration",
                    "Conjuration",
                    "Transmutation",
                },
            },
        },
    },
    Kuotoa_Ranger = {},
    LOW_Githyanki_Paladin = {},
    RedCap_Caster = {},
    SCL_Ketheric = {},
    Skeleton_Caster = {},
    Skeleton_Melee = {},
    Skeleton_Ranger = {},
    Skeleton_Strong = {},
    Steel_Watcher = {},
    TWN_Githyanki_Warlock = {},
    Tiefling_Bard = {},
    Tiefling_Caster = {},
    Tiefling_Cleric = {},
    Tiefling_Melee = {},
    Tiefling_Ranger = {},
    Tiefling_Rogue = {},
    _Fey= {
        Spell = {
            School = {
                Exclusive = {
                    "Illusion",
                    "Enchantment",
                },
            },
        },
    },
}

Kinds = {
    DarkJusticiar_Caster = {"Caster", "Fighter"},
    DarkJusticiar_Melee = {"Fighter"},
    DarkJusticiar_Ranger = {"Fighter", "Ranger"},
    Dragonborn_Barbarian = {"Barbarian"},
    Dragonborn_Cleric = {"Cleric"},
    Dragonborn_Melee = {"Fighter"},
    Dragonborn_Ranger = {"Ranger"},
    Dwarf_Bard = {"Bard"},
    Dwarf_Caster = {"Caster"},
    Dwarf_Druid = {"Druid"},
    Dwarf_Duergar_Barbarian = {"Barbarian"},
    Dwarf_Duergar_Caster = {"Caster"},
    Dwarf_Duergar_Cleric = {"Cleric"},
    Dwarf_Duergar_Melee = {"Fighter"},
    Dwarf_Duergar_Melee_StoneGuard = {"Barbarian", "Fighter"},
    Dwarf_Duergar_Melee_Strong = {"Barbarian", "Fighter"},
    Dwarf_Duergar_Ranger = {"Ranger"},
    Dwarf_Duergar_Ranger_Strong = {"Fighter", "Ranger"},
    Dwarf_Duergar_Rogue = {"Rogue"},
    Dwarf_Melee = {"Fighter"},
    Dwarf_Ranger = {"Ranger"},
    Dwarf_Rogue = {"Rogue"},
    END_Hellrider_Paladin = {"Paladin"},
    Elf_Barbarian = {"Barbarian"},
    Elf_Caster = {"Caster"},
    Elf_Drow_Caster = {"Caster"},
    Elf_Drow_Rogue = {"Rogue"},
    Elf_Druid = {"Druid"},
    Elf_Melee = {"Fighter"},
    Elf_Monk = {"Monk"},
    Elf_Ranger = {"Ranger"},
    Elf_Rogue = {"Rogue"},
    Elf_ShadarKai_Ranger = {"Ranger"},
    Elf_Wood_Caster = {"Caster"},
    FOR_Human_Cultist_Zariel_Paladin = {"Paladin"},
    FlamingFist_Human_Ranger = {"Ranger"},
    FlamingFist_Tiefling = {"Fighter"},
    GLO_Oathbreaker_Paladin = {"Paladin"},
    GOB_Dwarf_Warlock = {"Warlock"},
    Githyanki_Caster = {"Caster"},
    Githyanki_Gish = {"Caster", "Monk"},
    Githyanki_Melee = {"Fighter"},
    Githyanki_Ranger = {"Ranger"},
    Githyanki_Warrior = {"Fighter"},
    Gnome_Caster = {"Caster"},
    Gnome_Deep_Caster = {"Caster"},
    Gnome_Druid = {"Druid"},
    Gnome_Gondian_Caster = {"Caster"},
    Gnome_Melee = {"Fighter"},
    Gnome_Monk = {"Monk"},
    Gnome_Ranger = {"Ranger"},
    Gnome_Rogue = {"Rogue"},
    Goblin_Boss = {"Fighter"},
    Goblin_Caster = {"Caster"},
    Goblin_Cleric = {"Cleric"},
    Goblin_Melee = {"Fighter"},
    Goblin_Melee_Strong = {"Barbarian", "Fighter"},
    Goblin_Ranger = {"Ranger"},
    Goblin_Ranger_Strong = {"Fighter", "Ranger"},
    Goblin_Warlock = {"Warlock"},
    Hag_Green = {"Druid", "Ranger"},
    HalfElf_Barbarian = {"Barbarian"},
    HalfElf_Bard = {"Bard"},
    HalfElf_Caster = {"Caster"},
    HalfElf_Fighter_Rogue = {"Fighter", "Rogue"},
    HalfElf_Monk = {"Monk"},
    HalfElf_Ranger = {"Ranger"},
    HalfOrc_Barbarian = {"Barbarian"},
    HalfOrc_Caster = {"Caster"},
    HalfOrc_Melee = {"Fighter"},
    Halfling_Caster = {"Caster"},
    Halfling_Druid = {"Druid"},
    Halfling_Melee = {"Fighter"},
    Halfling_Ranger = {"Ranger"},
    Halfling_Rogue = {"Rogue"},
    Human_Barbarian = {"Barbarian"},
    Human_Bard = {"Bard"},
    Human_Caster = {"Caster"},
    Human_Cleric = {"Cleric"},
    Human_Druid = {"Druid"},
    Human_Melee = {"Fighter"},
    Human_Ranger = {"Ranger"},
    Human_Rogue = {"Rogue"},
    KillerReplica_Barbarian = {"Barbarian"},
    KillerReplica_Cleric = {"Cleric"},
    KillerReplica_Druid = {"Druid"},
    KillerReplica_Fighter = {"Fighter"},
    KillerReplica_Monk = {"Monk"},
    KillerReplica_Paladin = {"Paladin"},
    KillerReplica_Ranger = {"Ranger"},
    KillerReplica_Rogue = {"Rogue"},
    KillerReplica_Sorcerer = {"Caster"},
    KillerReplica_Warlock = {"Warlock"},
    KillerReplica_Wizard = {"Caster"},
    Kobold_Inventor = {"Caster"},
    Kobold_Melee = {"Fighter"},
    Kobold_Ranger = {"Ranger"},
    Kuotoa_Caster = {"Cleric"},
    Kuotoa_Ranger = {"Ranger"},
    LOW_Githyanki_Paladin = {"Paladin"},
    RedCap_Caster = {"Caster"},
    SCL_Ketheric = {"Paladin"},
    Skeleton_Caster = {"Caster"},
    Skeleton_Melee = {"Fighter"},
    Skeleton_Ranger = {"Ranger"},
    Skeleton_Strong = {"Barbarian", "Fighter"},
    Steel_Watcher = {"Fighter"},
    TWN_Githyanki_Warlock = {"Warlock"},
    Tiefling_Bard = {"Bard"},
    Tiefling_Caster = {"Caster"},
    Tiefling_Cleric = {"Cleric"},
    Tiefling_Melee = {"Fighter"},
    Tiefling_Ranger = {"Ranger"},
    Tiefling_Rogue = {"Rogue"},
}

KindMapping = {
    Caster = {
        "Sorcerer",
        "Wizard",
    },
    Bard = {
        "Bard",
    },
    Sorcerer = {
        "Sorcerer",
    },
    Wizard = {
        "Wizard",
    },
    Warlock = {
        "Warlock",
    },
    Cleric = {
        "Cleric",
    },
    Druid = {
        "Druid",
    },
    Paladin = {
        "Paladin",
    },
    Ranger = {
        "Ranger",
    },
    Barbarian = {
        "Barbarian",
    },
    Monk = {
        "Monk",
    },
    Rogue = {
        "Rogue",
    },
    Fighter = {
        "Fighter",
    },
}

function _EntityToKinds(vars, kinds, target)
    local entity = Ext.Entity.Get(target)
    local res, kind = pcall(function () return entity["ServerCharacter"]["Character"]["Template"]["Stats"] end)
    while kind ~= nil do
        local overrideKinds = SafeGet(vars, "Kinds", kind)
        if overrideKinds ~= nil then
            return ToSet(overrideKinds)
        end
        if kinds[kind] ~= nil then
            return ToSet(kinds[kind])
        end
        res, kind = pcall(function() return Ext.Stats.Get(kind).Using end)
    end
    return nil
end

function _EntityToRestrictions(vars, restrictions, target)
    local entity = Ext.Entity.Get(target)
    local res, stat = pcall(function () return entity["ServerCharacter"]["Character"]["Template"]["Stats"] end)
    while stat ~= nil do
        local overrideRestrictions = SafeGet(vars, "Restrictions", stat)
        if overrideRestrictions ~= nil then
            return overrideRestrictions
        end
        if restrictions[stat] ~= nil then
            return restrictions[stat]
        end
        res, stat = pcall(function() return Ext.Stats.Get(stat).Using end)
    end
    return nil
end

function AllowedByRestrictions(restrictionsDefinition, restrictionType, candidate)
    local restrictions = restrictionsDefinition[restrictionType]
    if restrictions == nil then
        return true
    end
    local spellData = SpellData[candidate]
    if spellData == nil then
        LogI(2, 18, string.format("Spell %s not found in SpellData", candidate))
        return true
    end
    if restrictions.Cost ~= nil then
        local costRestrictions = restrictions.Cost.Restrict
        for _, costRestriction in ipairs(costRestrictions or {}) do
            if spellData.UseCosts[costRestriction] ~= nil then
                return false
            end
        end
    end
    if restrictions.School ~= nil then
        local exclusiveSchoolRestrictions = restrictions.School.Exclusive
        if exclusiveSchoolRestrictions == nil then
            return true
        end

        if exclusiveSchoolRestrictions == {} then
            -- No schools allowed
            return false
        end

        local allowed = false
        for _, exclusiveSchoolRestriction in ipairs(exclusiveSchoolRestrictions or {}) do
            if spellData.SpellSchool == exclusiveSchoolRestriction then
                allowed = true
            end
        end
        return allowed
    end
    return true
end

function DropBlacklistedPassives(passives)
    return DropBlacklisted(BlacklistedPassives, passives)
end

function DropBlacklistedAbilities(abilities)
    return DropBlacklisted(BlacklistedAbilities, abilities)
end

function SpellListsToSpells()
    local allSpellLists = Ext.Definition.GetAll("SpellList")
    local spellListToSpells = {}

    for _, p in ipairs(allSpellLists) do
        spellListToSpells[p] = {}
        local spellList = Ext.Definition.Get(p, "SpellList")
        for _, spell in ipairs(Ext.Types.Serialize(spellList.Spells)) do
            local spellData = Ext.Stats.Get(spell)

            local useCosts = Split(spellData.UseCosts, ";")
            local useCostsProcessed = {}
            for _, useCost in ipairs(useCosts) do
                local res = Split(useCost, ":")
                if #res == 2 then
                    useCostsProcessed[res[1]] = res[2]
                end
            end

            local aiFlags = ToSet(Split(spellData.AIFlags, ";"))

            local canUseInCombat = true
            for _, requirement in ipairs(spellData.Requirements) do
                if requirement.Requirement == "Combat" and requirement.Not then
                    canUseInCombat = false
                end
            end

            spellListToSpells[p][spell] = {
                Name = spell,
                SpellFlags = ToSet(spellData.SpellFlags),
                Level = spellData.Level,
                SpellSchool = spellData.SpellSchool,
                VerbalIntent = spellData.VerbalIntent,
                UseCosts = useCostsProcessed,
                Requirements = spellData.Requirements,
                AIFlags = aiFlags,
                CanAIUse = aiFlags["CanNotUse"] == nil,
                CanUseInCombat = canUseInCombat,
                Origin = Ext.Mod.GetMod(spellData.ModId).Info.Name,
            }
        end
    end

    return spellListToSpells
end

function PassiveListsToPassives()
    local allPassiveLists = Ext.Definition.GetAll("PassiveList")
    local passiveListToPassives = {}

    for _, p in ipairs(allPassiveLists) do
        local passiveList = Ext.Definition.Get(p, "PassiveList")
        passiveListToPassives[p] = Ext.Types.Serialize(passiveList.Passives)
    end

    return passiveListToPassives
end

function ProgressionsByTable()
    local spellListToSpells = SpellListsToSpells()
    local passiveListToPassives = PassiveListsToPassives()

    function AnnotateWithSpells(selectors)
        for _, selector in ipairs(selectors) do
            selector.Spells = spellListToSpells[selector.SpellUUID] or {}
        end
        return selectors
    end

    function AnnotateWithPassives(selectors)
        for _, selector in ipairs(selectors) do
            selector.Passives = passiveListToPassives[selector.UUID] or {}
        end
        return selectors
    end

    local allProgressions = Ext.Definition.GetAll("Progression")
    local progressionsByTable = {}

    for _, p in ipairs(allProgressions) do
        local progression = Ext.Definition.Get(p, "Progression")
        if progressionsByTable[progression.TableUUID] == nil then
            progressionsByTable[progression.TableUUID] = {}
        end

        if
            (progression.PassivesAdded ~= nil and progression.PassivesAdded ~= "" ) or
            (progression.PassivesRemoved ~= nil and progression.PassivesRemoved ~= "" ) or
            (progression.AddSpells ~= nil and #progression.AddSpells > 0 ) or
            (progression.SelectSpells ~= nil and #progression.SelectSpells > 0 ) or
            (progression.SelectPassives ~= nil and #progression.SelectPassives > 0 ) or
            (progression.Boosts ~= nil and progression.Boosts ~= "" )
        then
            if progressionsByTable[progression.TableUUID][progression.Level] == nil then
                progressionsByTable[progression.TableUUID][progression.Level] = {
                    Name = progression.Name,
                    PassivesAdded = {},
                    PassivesRemoved = {},
                    AddSpells = {},
                    SelectSpells = {},
                    SelectPassives = {},
                    Boosts = {},
                    UUIDs = {},
                }
            end

            TableCombine(Split(progression.PassivesAdded, ";"), progressionsByTable[progression.TableUUID][progression.Level].PassivesAdded)
            TableCombine(Split(progression.PassivesRemoved, ";"), progressionsByTable[progression.TableUUID][progression.Level].PassivesRemoved)
            TableCombine(AnnotateWithSpells(Ext.Types.Serialize(progression.AddSpells)), progressionsByTable[progression.TableUUID][progression.Level].AddSpells)
            TableCombine(AnnotateWithSpells(Ext.Types.Serialize(progression.SelectSpells)), progressionsByTable[progression.TableUUID][progression.Level].SelectSpells)
            TableCombine(AnnotateWithPassives(Ext.Types.Serialize(progression.SelectPassives)), progressionsByTable[progression.TableUUID][progression.Level].SelectPassives)
            TableCombine(Split(progression.Boosts, ";"), progressionsByTable[progression.TableUUID][progression.Level].Boosts)
            table.insert(progressionsByTable[progression.TableUUID][progression.Level].UUIDs, p)
        end

    end

    return progressionsByTable
end

function FindRootClasses()
    local progressionsByTable = ProgressionsByTable()

    local allClasses = Ext.Definition.GetAll("ClassDescription")
    local rootClasses = {}
    for _, c in ipairs(allClasses) do
        local class = Ext.Definition.Get(c, "ClassDescription")
        local parentClass = Ext.Definition.Get(class.ParentGuid, "ClassDescription")
        while (parentClass ~= nil) do
            class = parentClass
            parentClass = Ext.Definition.Get(class.ParentGuid, "ClassDescription")
            if parentClass == nil then
                rootClasses[class.Name] = {
                    Name = class.Name,
                    ParentGuid = class.ParentGuid,
                    PrimaryAbility = class.PrimaryAbility,
                    ProgressionTableUUID = class.ProgressionTableUUID,
                    Progression = progressionsByTable[class.ProgressionTableUUID],
                    ResourceUUID = class.ResourceUUID,
                    SpellCastingAbility = class.SpellCastingAbility,
                    SpellList = class.SpellList,
                    Tags = class.Tags,
                    Subclasses = {},
                }
            end
        end
    end
    for _, c in ipairs(allClasses) do
        local class = Ext.Definition.Get(c, "ClassDescription")
        local parentClass = Ext.Definition.Get(class.ParentGuid, "ClassDescription")
        if parentClass ~= nil then
            rootClasses[parentClass.Name]["Subclasses"][class.Name] = {
                Name = class.Name,
                ParentGuid = class.ParentGuid,
                PrimaryAbility = class.PrimaryAbility,
                ProgressionTableUUID = class.ProgressionTableUUID,
                Progression = progressionsByTable[class.ProgressionTableUUID],
                ResourceUUID = class.ResourceUUID,
                SpellCastingAbility = class.SpellCastingAbility,
                SpellList = class.SpellList,
                Tags = class.Tags,
            }
        end
    end
    return rootClasses
end

SpellLevelToName = {
    "Cantrips",
    "Level1",
    "Level2",
    "Level3",
    "Level4",
    "Level5",
    "Level6",
    "Level7",
    "Level8",
    "Level9",
}

function GenerateSpellLists(blacklistedAbilitiesByClass, blacklistedAbilities, blaclistedLists, rootClasses)
    local classToSpellLists = {}
    for className, class in pairs(rootClasses) do
        local spells, spellsBySpellLevel, abilitiesByLevel = GenerateClassSpellLists(blacklistedAbilitiesByClass, blacklistedAbilities, blaclistedLists, class)
        classToSpellLists[class.Name] = {
            Spells = spells,
            SpellsBySpellLevel = spellsBySpellLevel,
            AbilitiesByLevel = abilitiesByLevel,
        }
    end
    return classToSpellLists
end

function GenerateClassSpellLists(blacklistedAbilitiesByClass, blacklistedAbilities, blaclistedLists, class)
    local spells = {}
    for level, progression in pairs(class.Progression) do
        if not blacklistedAbilitiesByClass[progression.Name] then
            for _, selector in ipairs(progression.AddSpells) do
                for spellId, spell in pairs(selector.Spells) do
                    if not blacklistedAbilities[spell.Name] then
                        spells[spell.Name] = {
                            Spell = spell,
                            ClassLevel = level,
                        }
                    end
                end
            end
            for _, selector in ipairs(progression.SelectSpells) do
                for spellId, spell in pairs(selector.Spells) do
                    if not blacklistedAbilities[spell.Name] then
                        spells[spell.Name] = {
                            Spell = spell,
                            ClassLevel = level,
                        }
                    end
                end
            end
        end
    end
    for subclassName, subclass in pairs(class.Subclasses) do
        for level, progression in pairs(subclass.Progression) do
            if not blacklistedAbilitiesByClass[progression.Name] then
                for _, selector in ipairs(progression.AddSpells) do
                    for spellId, spell in pairs(selector.Spells) do
                        if not blacklistedAbilities[spell.Name] then
                            spells[spell.Name] = {
                                Spell = spell,
                                ClassLevel = level,
                            }
                        end
                    end
                end
                for _, selector in ipairs(progression.SelectSpells) do
                    for spellId, spell in pairs(selector.Spells) do
                        if not blacklistedAbilities[spell.Name] then
                            spells[spell.Name] = {
                                Spell = spell,
                                ClassLevel = level,
                            }
                        end
                    end
                end
            end
        end
    end
    local spellsBySpellLevel = {}
    local abiltiiesByLevel = {}
    for spellName, spell in pairs(spells) do
        if spell.Spell.CanUseInCombat and spell.Spell.CanAIUse then
            if spell.Spell.SpellFlags["IsSpell"] then
                local levelName = SpellLevelToName[spell.Spell.Level + 1]
                if spellsBySpellLevel[levelName] == nil then
                    spellsBySpellLevel[levelName] = {}
                end
                table.insert(spellsBySpellLevel[levelName], spellName)
            else
                local levelName = "Level" .. spell.ClassLevel
                if abiltiiesByLevel[levelName] == nil then
                    abiltiiesByLevel[levelName] = {}
                end
                table.insert(abiltiiesByLevel[levelName], spellName)
            end
        end
    end
    for _, spells in pairs(spellsBySpellLevel) do
        table.sort(spells)
    end
    for _, abilities in pairs(abiltiiesByLevel) do
        table.sort(abilities)
    end
    return spells, spellsBySpellLevel, abiltiiesByLevel
end

function GeneratePassiveLists(blacklistedPassivesByClass, blacklistedPassives, blaclistedLists, rootClasses)
    local classToPassiveLists = {}
    for className, class in pairs(rootClasses) do
        local passives, passivesByLevel = GenerateClassPassiveLists(blacklistedPassivesByClass, blacklistedPassives, blaclistedLists, class)
        classToPassiveLists[class.Name] = {
            Passives = passives,
            PassivesByLevel = passivesByLevel,
        }
    end
    return classToPassiveLists
end

function GenerateClassPassiveLists(blacklistedPassivesByClass, blacklistedPassives, blaclistedLists, class)
    local passives = {}
    local passivesByLevel = {}
    for level, progression in pairs(class.Progression) do
        if not blacklistedPassivesByClass[progression.Name] then
            for _, selector in ipairs(progression.SelectPassives) do
                for _, passive in ipairs(selector.Passives) do
                    if not blacklistedPassives[passive] then
                        passives[passive] = true
                        if passivesByLevel["Level" .. level] == nil then
                            passivesByLevel["Level" .. level] = {}
                        end
                        passivesByLevel["Level" .. level][passive] = true
                    end
                end
            end
            for _, passive in ipairs(progression.PassivesAdded) do
                if not blacklistedPassives[passive] then
                    passives[passive] = true
                    if passivesByLevel["Level" .. level] == nil then
                        passivesByLevel["Level" .. level] = {}
                    end
                    passivesByLevel["Level" .. level][passive] = true
                end
            end
        end
    end
    for subclassName, subclass in pairs(class.Subclasses) do
        for level, progression in pairs(subclass.Progression) do
            if not blacklistedPassivesByClass[progression.Name] then
                for _, selector in ipairs(progression.SelectPassives) do
                    for _, passive in ipairs(selector.Passives) do
                        if not blacklistedPassives[passive] then
                            passives[passive] = true
                            if passivesByLevel["Level" .. level] == nil then
                                passivesByLevel["Level" .. level] = {}
                            end
                            passivesByLevel["Level" .. level][passive] = true
                        end
                    end
                end
                for _, passive in ipairs(progression.PassivesAdded) do
                    if not blacklistedPassives[passive] then
                        passives[passive] = true
                        if passivesByLevel["Level" .. level] == nil then
                            passivesByLevel["Level" .. level] = {}
                        end
                        passivesByLevel["Level" .. level][passive] = true
                    end
                end
            end
        end
    end
    local passivesByLevelLists = {}
    for level, passives in pairs(passivesByLevel) do
        local passivesList = Keys(passives)
        table.sort(passivesList)
        passivesByLevelLists[level] = passivesList
    end

    return passives, passivesByLevelLists
end

function LevelGate(VarsJson, varSection, max, npcLevel, target, configType)
    local minLevels = {}
    local requiredLevelsChoices = {}
    local gates = GetVarComplex(VarsJson, varSection, "LevelGate", target, configType) or {}
    for i = 1, max, 1 do
        local gateForLevel = SafeGet(gates, string.format("MinCharLevelForLevel%s", i))
        minLevels[i] = tonumber(gateForLevel or 13)

        local requireLevelAtLevel = {}
        for j = 1, i, 1 do
            table.insert(requireLevelAtLevel, j)
        end
        requiredLevelsChoices[i] = requireLevelAtLevel
    end

    local requiredLevels
    for i = max, 1, -1 do
        if npcLevel >= minLevels[i] then
            requiredLevels = requiredLevelsChoices[i]
            break
        end
    end
    return requiredLevels or {}
end

function ComputeClassLevelAdditions(sourceTables, var, presenceCheckFn, target, configType, combatid)
    local toAdd = {}
    local requiredLevels = LevelGate(VarsJson, var, 20, Osi.GetLevel(target), target, configType)

    LogI(5, 26, string.format("DBG: Required levels %s for %s", Ext.Json.Stringify(requiredLevels), target))
    local npcTable = {}
    for _, level in ipairs(requiredLevels) do
        local levels = sourceTables["Level" .. level]

        if levels then
            for _, addition in pairs(levels) do
                if presenceCheckFn(target, addition) == 0 then
                    table.insert(npcTable, addition)
                end
            end
        end
    end

    LogI(5, 26, string.format("DBG: Found %s %s additions table for %s", #npcTable, Ext.Json.Stringify(npcTable), target))
    local lookupFn = function(range, ...)
        return Osi.Random(range)
    end

    if VarsJson["ConsistentHash"] == 1 and VarsJson["ConsistentHashSalt"] ~= nil then
        LogI(5, 26, string.format("DBG: Using consistent hash for %s wiht salt %s", target, VarsJson["ConsistentHashSalt"]))
        lookupFn = function(range, ...)
            local params = {...}
            return ConsistentHash(VarsJson["ConsistentHashSalt"], range, target, table.unpack(params))
        end
    end

    if #npcTable > 0 then
        local npcs = ComputeSimpleIncrementalBoost(var, target, configType, combatid)
        for i = npcs, 1, -1 do
            local additionCandidate = nil
            local attempts = 1
            while attempts <= #npcTable and (additionCandidate == nil or toAdd[additionCandidate] ~= nil) do
                local rnd = lookupFn(#npcTable, string.format("addition_%s", i), string.format("attempts_%s", attempts)) + 1
                additionCandidate = npcTable[rnd]
                LogI(4, 26, string.format("Selected %s on %s with %s attempt %s", additionCandidate, target, rnd, attempts))
                attempts = attempts + 1
            end
            if additionCandidate ~= nil then
                toAdd[additionCandidate] = additionCandidate
            end
        end
    end

    return toAdd
end

function ComputeClassSpecificPassives(target, configType, combatid)
    local passivesToAdd = {}
    local passiveTables = {}

    local kinds = EntityToKinds(target) or {}
    local allClasses = {}
    for kind, _ in pairs(kinds) do
        local classes = KindMapping[kind]
        allClasses = TableCombine(classes, allClasses)
    end

    local combinedClassPassives = {}
    for _, class in ipairs(allClasses) do
        local classPassives = PassiveListsByClass[class].PassivesByLevel or {}
        if classPassives ~= nil then
            for level, passives in pairs(classPassives) do
                if combinedClassPassives[level] == nil then
                    combinedClassPassives[level] = {}
                end
                for _, passive in ipairs(passives) do
                    combinedClassPassives[level][passive] = true
                end
            end
        end
    end

    local passivesCount = 0
    for level, passives in pairs(combinedClassPassives) do
        local passiveTable = {}
        for passive, _ in pairs(passives) do
            table.insert(passiveTable, passive)
            passivesCount = passivesCount + 1
        end
        table.sort(passiveTable)
        passiveTables[level] = passiveTable
    end

    if passivesCount == 0 then
        LogI(2, 18, "No passives available, please check config")
        return passivesToAdd
    end

    return ComputeClassLevelAdditions(passiveTables, "PassivesAdded", Osi.HasPassive, target, configType, combatid)
end

function ComputeClassSpecificAbilities(target, configType, combatid)
    local abiltiesToAdd = {}
    local abilityTables = {}

    local kinds = EntityToKinds(target) or {}
    local allClasses = {}
    for kind, _ in pairs(kinds) do
        local classes = KindMapping[kind]
        allClasses = TableCombine(classes, allClasses)
    end
    local restrictions = EntityToRestrictions(target) or {}

    LogI(5, 26, string.format("DBG: Found classes %s for %s", Ext.Json.Stringify(allClasses), target))

    local combinedClassAbilities = {}
    for _, class in ipairs(allClasses) do
        local classPassives = SpellListsByClass[class].AbilitiesByLevel or {}
        if classPassives ~= nil then
            for level, abilities in pairs(classPassives) do
                if combinedClassAbilities[level] == nil then
                    combinedClassAbilities[level] = {}
                end
                for _, ability in ipairs(abilities) do

                    local allowedByRestrictions = AllowedByRestrictions(restrictions, "Ability", ability)
                    if allowedByRestrictions and not HasSpellThorough(target, ability) then
                        combinedClassAbilities[level][ability] = true
                    end
                end
            end
        end
    end
    LogI(5, 26, string.format("DBG: Found abilities %s for %s", Ext.Json.Stringify(combinedClassAbilities), target))

    local abilitiesCount = 0
    for level, abilities in pairs(combinedClassAbilities) do
        local abilityTable = {}
        for ability, _ in pairs(abilities) do
            table.insert(abilityTable, ability)
            abilitiesCount = abilitiesCount + 1
        end
        table.sort(abilityTable)
        abilityTables[level] = abilityTable
    end

    if abilitiesCount == 0 then
        LogI(2, 18, "No abilities available, please check config")
        return abiltiesToAdd
    end
    LogI(5, 26, string.format("DBG: Found ability tables %s for %s", Ext.Json.Stringify(abilityTables), target))

    return ComputeClassLevelAdditions(abilityTables, "AbilitiesAdded", Osi.HasSpell, target, configType, combatid)
end

function CheckIfOrigin(target)
    for i=#ExcludedNPCs,1,-1 do
        if (ExcludedNPCs[i] == target) then
            return 1
        end
    end
    return 0
end

function InSpellTable(spellTable, candidate)
    for _, spells in pairs(spellTable) do
        for _, spell in pairs(spells) do
            if spell == candidate then
                return true
            end
        end
    end
    return false
end

function IsEnemiesEnhancedLoaded()
    local eeDisabled = VarsJson["DebugDisableEE"] or 0
    return eeDisabled == 0 and Ext.Mod.IsModLoaded("7deea48e-8b9d-45e4-8685-5acfd0ce39ad")
end

function CheckIfParty(target)
    if (Osi.IsPartyMember(target,1) == 1) then
        return 1
    else return 0
    end
end

function CheckIfOurSummon(target)
    local us = Ext.Entity.Get(target)["IsSummon"]
    if us ~= nil then
        local parent = us["Owner_M"]
        return CheckIfParty(parent["Uuid"]["EntityUuid"])
    end
    return 0
end

function GetVar(vars, var, guid, configType)
    local race = Osi.GetRace(guid, 0)
    local specific = vars[guid]
    if specific ~= nil then
        local result = specific[var]
        if result ~= nil then
            LogI(7, 36, string.format("Found specific override for %s %s, applying", guid, var))
            return result
        end
    end
    local general = vars[configType]
    if general ~= nil then
        local raceResult = general[race]
        if raceResult ~= nil then
            local raceVarResult = raceResult[var]
            if raceVarResult ~= nil then
                LogI(7, 36, string.format("Found race override for %s %s, applying", guid, var))
                return raceVarResult
            end
        end
        local result = general[var]
        if result ~= nil then
            return result
        end
    end
    local result = Defaults[var]
    return result
end

function GetVarComplex(vars, topvar, var, guid, configType)
    local race = Osi.GetRace(guid, 0)
    local specific = vars[guid]
    if specific ~= nil then
        local topresult = specific[topvar]
        if topresult ~= nil then
            local result = topresult[var]
            if result ~= nil then
                LogI(7, 36, string.format("Found specific override for %s %s %s, applying", guid, topvar, var))
                return result
            end
        end
    end
    local general = vars[configType]
    if general ~= nil then
        LogI(7, 36, string.format("Found settings for %s %s %s %s", configType, guid, topvar, var))
        local raceResult = general[race]
        if raceResult ~= nil then
            LogI(7, 36, string.format("Found race settings for %s %s %s %s %s", configType, race, guid, topvar, var))
            local topRaceVarResult = raceResult[topvar]
            if topRaceVarResult ~= nil then
                LogI(7, 36, string.format("Found topvar race settings for %s %s %s %s %s", configType, race, guid, topvar, var))
                local raceVarResult = topRaceVarResult[var]
                if raceVarResult ~= nil then
                    LogI(7, 36, string.format("Found race override for %s %s %s, applying", guid, topvar, var))
                    return raceVarResult
                end
            end
        end
        local topresult = general[topvar]
        if topresult ~= nil then
            LogI(7, 36, string.format("Found topvar settings for %s %s %s %s", configType, guid, topvar, var))
            local result = topresult[var]
            if result ~= nil then
                LogI(7, 36, string.format("Found %s override for %s %s %s, applying", configType, guid, topvar, var))
                return result
            end
        end
    end
    LogI(7, 36, string.format("Found no override for %s %s %s, applying default", configType, guid, topvar, var))
    return Defaults[topvar][var]
end

function MkSourceId(combatid)
    return "LoreCombatConfigurator_" .. combatid
end

function AddBoostsAdv(target, val, combatid)
    local sourceId = MkSourceId(combatid)
    Osi.AddBoosts(target, val, sourceId, sourceId)
end

function RemoveBoostsAdv(target, val, combatid)
    local sourceId = MkSourceId(combatid)
    Osi.RemoveBoosts(target, val, 0, sourceId, sourceId)
end

function HasSpellThorough(target, spell)
    if Osi.HasSpell(target, spell) == 1 then
        return true
    end

    LogI(5, 30, string.format("Has Spell Thorough Check spellbook for spell parent %s on %s", spell, target))

    local entity = Ext.Entity.Get(target)
    local spells = SafeGet(entity, "SpellBook", "Spells")

    if spells == nil then
        return false
    end

    for _, derivedSpell in pairs(spells) do
        local prototype = SafeGet(derivedSpell, "Id", "Prototype")
        local using = prototype

        while using ~= nil do
            local status, spellData = pcall(Ext.Stats.Get, using)
            local usingStatus, usingSpell = pcall(function() return spellData.Using end)

            LogI(7, 32, string.format("Has Spell Thorough Checking spell parent %s of %s on %s", usingSpell, using, target))

            if status and usingStatus and usingSpell ~= nil and spell == usingSpell then
                return true
            end
            using = usingSpell
        end
    end
    return false
end

function GuessIfCaster(target)
    LogI(3, 22, string.format("Guessing if caster on %s", target))
    local eeCaster = (
        Osi.HasPassive(target, "EE_Cantrips_Type_1") == 1 or
        Osi.HasPassive(target, "EE_Cantrips_Type_2") == 1 or
        Osi.HasPassive(target, "EE_Spells_Level_1") == 1 or
        Osi.HasPassive(target, "EE_Spells_Level_2") == 1 or
        Osi.HasPassive(target, "EE_Spells_Level_3") == 1 or
        Osi.HasPassive(target, "EE_Spells_Level_4") == 1 or
        Osi.HasPassive(target, "EE_Spells_Level_5") == 1 or
        Osi.HasPassive(target, "EE_Spells_Level_6") == 1
    )
    function CheckArchetype()
        LogI(3, 26, string.format("Peforming mage archetype check %s", target))
        local casterTypes = {
            mage = true,
            mage_SCL = true,
            mage_no_inventory_items = true,
            mage_smart = true,
            goblin_mage = true,
            monk_mage = true,
        }
        local entity = Ext.Entity.Get(target)
        local combatComponent = SafeGet(entity, "ServerCharacter", "Character", "Template", "CombatComponent")
        return casterTypes[SafeGet(combatComponent, "Archetype")] ~= nil
    end
    local kinds = EntityToKinds(target)
    return (
        (
            kinds ~= nil and kinds["Caster"] ~= nil
        ) or
        (IsEnemiesEnhancedLoaded() and eeCaster) or
        (VarsJson["CasterArchetypeCheck"] == 1 and CheckArchetype())
    )
end

function GuessIfBarbarian(target)
    LogI(3, 22, string.format("Guessing if barbarian on %s", target))
    local barbarianTypes = {
    }
    local kinds = EntityToKinds(target)
    return (
        (kinds ~= nil and kinds["Barbarian"] ~= nil) or
        (
            VarsJson["BarbarianArchetypeCheck"] == 1 and
            barbarianTypes[SafeGet(Ext.Entity.Get(target), "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        ) or
        (IsEnemiesEnhancedLoaded() and Osi.HasPassive(target, "EE_Barbarian_Boost") == 1)
    )
end

function GuessIfFighter(target)
    LogI(3, 22, string.format("Guessing if fighter on %s", target))
    local fighterTypes = {
        melee = true,
    }
    local kinds = EntityToKinds(target)
    return (
        (
            kinds ~= nil and kinds["Fighter"] ~= nil
        ) or
        (
            VarsJson["FighterArchetypeCheck"] == 1 and
            fighterTypes[SafeGet(Ext.Entity.Get(target), "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        ) or
        (IsEnemiesEnhancedLoaded() and Osi.HasPassive(target, "EE_Fighter_Boost") == 1)
    )
end

function GuessIfHealer(target)
    LogI(3, 22, string.format("Guessing if healer on %s", target))
    local healerTypes = {
        healer_melee = true,
        healer_ranged = true,
        melee_healer = true,
    }
    return (
        VarsJson["HealerArchetypeCheck"] == 1 and
        healerTypes[SafeGet(Ext.Entity.Get(target), "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
    )
end

function GuessIfCleric(target)
    LogI(3, 22, string.format("Guessing if cleric on %s", target))
    local clericTypes = {
    }
    local kinds = EntityToKinds(target)
    return (
        (
            kinds ~= nil and kinds["Cleric"] ~= nil
        ) or
        (
            VarsJson["ClericArchetypeCheck"] == 1 and
            clericTypes[SafeGet(Ext.Entity.Get(target), "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

function GuessIfBard(target)
    LogI(3, 22, string.format("Guessing if bard on %s", target))
    local bardTypes = {
    }
    local kinds = EntityToKinds(target)
    return (
        (
            kinds ~= nil and kinds["Bard"] ~= nil
        ) or
        (
            VarsJson["BardArchetypeCheck"] == 1 and
            bardTypes[SafeGet(Ext.Entity.Get(target), "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

function GuessIfPaladin(target)
    LogI(3, 22, string.format("Guessing if paladin on %s", target))
    local paladinTypes = {
    }
    local kinds = EntityToKinds(target)
    return (
        (
            kinds ~= nil and kinds["Paladin"] ~= nil
        ) or
        (
            VarsJson["PaladinArchetypeCheck"] == 1 and
            paladinTypes[SafeGet(Ext.Entity.Get(target), "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

function GuessIfDruid(target)
    LogI(3, 22, string.format("Guessing if druid on %s", target))
    local druidTypes = {
    }
    local kinds = EntityToKinds(target)
    return (
        (
            kinds ~= nil and kinds["Druid"] ~= nil
        ) or
        (
            VarsJson["DruidArchetypeCheck"] == 1 and
            druidTypes[SafeGet(Ext.Entity.Get(target), "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

function GuessIfMonk(target)
    LogI(3, 22, string.format("Guessing if monk on %s", target))
    local monkTypes = {
        monk_melee = true,
        monk_ranged = true,
    }
    local kinds = EntityToKinds(target)
    return (
        (
            kinds ~= nil and kinds["Monk"] ~= nil
        ) or
        (
            VarsJson["MonkArchetypeCheck"] == 1 and
            monkTypes[SafeGet(Ext.Entity.Get(target), "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        ) or
        Osi.HasPassive(target, "PsychicStrikes_Githyanki") == 1
    )
end

function GuessIfRogue(target)
    LogI(3, 22, string.format("Guessing if rogue on %s", target))
    local rogueTypes = {
    }
    local kinds = EntityToKinds(target)
    return (
        (
            kinds ~= nil and kinds["Rogue"] ~= nil
        ) or
        (
            VarsJson["RogueArchetypeCheck"] == 1 and
            rogueTypes[SafeGet(Ext.Entity.Get(target), "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

function GuessIfRanger(target)
    LogI(3, 22, string.format("Guessing if ranger on %s", target))
    local rogueTypes = {
    }
    local kinds = EntityToKinds(target)
    return (
        (
            kinds ~= nil and kinds["Ranger"] ~= nil
        ) or
        (
            VarsJson["RangerArchetypeCheck"] == 1 and
            rogueTypes[SafeGet(Ext.Entity.Get(target), "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

function GuessIfWarlock(target)
    LogI(3, 22, string.format("Guessing if warlock on %s", target))
    local warlockTypes = {
    }
    local kinds = EntityToKinds(target)
    return (
        (
            kinds ~= nil and kinds["Warlock"] ~= nil
        ) or
        (
            VarsJson["WarlockArchetypeCheck"] == 1 and
            warlockTypes[SafeGet(Ext.Entity.Get(target), "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

function ComputeNewSpells(target, configType, combatid)
    local selectedSpells = {}

    local npcLevel = tonumber(Osi.GetLevel(target))
    local npcSpellTable = {}

    local spellTables = {}

    local kinds = EntityToKinds(target) or {}
    local allClasses = {}
    for kind, _ in pairs(kinds) do
        local classes = KindMapping[kind]
        allClasses = TableCombine(classes, allClasses)
    end

    local restrictions = EntityToRestrictions(target) or {}

    local combinedClassSpells = {}
    for _, class in ipairs(allClasses) do
        local classSpells = SpellListsByClass[class].SpellsBySpellLevel or {}
        if classSpells ~= nil then
            for level, spells in pairs(classSpells) do
                if combinedClassSpells[level] == nil then
                    combinedClassSpells[level] = {}
                end
                for _, spell in ipairs(spells) do
                    local allowedByRestrictions = AllowedByRestrictions(restrictions, "Spell", spell)
                    if allowedByRestrictions and not HasSpellThorough(target, spell) then
                        combinedClassSpells[level][spell] = true
                    end
                end
            end
        end
    end

    LogI(5, 26, string.format("DBG: Found spells %s for %s", Ext.Json.Stringify(combinedClassSpells), target))
    local spellsCount = 0
    for level, spells in pairs(combinedClassSpells) do
        local spellTable = {}
        for spell, _ in pairs(spells) do
            table.insert(spellTable, spell)
            spellsCount = spellsCount + 1
        end
        table.sort(spellTable)
        spellTables[level] = spellTable
    end
    LogI(5, 26, string.format("DBG: Found spell tables %s for %s", Ext.Json.Stringify(spellTables), target))

    if spellsCount == 0 then
        LogI(2, 18, "No spell available, please check config")
        return selectedSpells
    end

    local lookupFn = function(range, ...)
        return Osi.Random(range)
    end

    if VarsJson["ConsistentHash"] == 1 and VarsJson["ConsistentHashSalt"] ~= nil then
        lookupFn = function(range, ...)
            local params = {...}
            return ConsistentHash(VarsJson["ConsistentHashSalt"], range, target, table.unpack(params))
        end
    end

    local requiredSpellLevels = LevelGate(VarsJson, "SpellsAdded", 9, npcLevel, target, configType)
    local npcSpells = ComputeSimpleIncrementalBoost("SpellsAdded", target, configType, combatid)

    table.sort(requiredSpellLevels, function (l, r) return l > r end)

    for _, level in ipairs(requiredSpellLevels) do
        local levelSpells = spellTables["Level" .. level]
        for i = npcSpells, 1, -1 do
            local spellCandidate = nil
            local attempts = 1
            while attempts <= #levelSpells and (spellCandidate == nil or selectedSpells[spellCandidate] ~= nil) do
                local rnd = lookupFn(#levelSpells, string.format("spell_%s", i), string.format("attempts_%s", attempts)) + 1
                spellCandidate = levelSpells[rnd]
                LogI(4, 26, string.format("Selected spell %s on %s with %s attempt %s", spellCandidate, target, rnd, attempts))
                attempts = attempts + 1
            end
            if spellCandidate ~= nil then
                selectedSpells[spellCandidate] = spellCandidate
            end
        end
        npcSpells = npcSpells + 1
    end

    return selectedSpells
end

function ComputeActionPointBoost(target, configType, combatid)
    local actionPoints
    local actionPointBoost = ComputeSimpleIncrementalBoost("ActionPointBoosts", target, configType, combatid)
    if (Osi.HasPassive(target, "Boost_Action") and IsEnemiesEnhancedLoaded()) and actionPointBoost > 0 then
        actionPointBoost = actionPointBoost - 1
    end

    if Osi.HasPassive(target, "ExtraAttack") and GetVar(VarsJson, "ConservativeActionPointBoosts", target, configType) == 1 and actionPointBoost > 0 then
        actionPointBoost = actionPointBoost - 1
    end
    if actionPointBoost <= 0 then
        return nil
    end

    actionPoints = "ActionResource(ActionPoint," .. tonumber(actionPointBoost) .. ",0)"

    return actionPoints
end

function ComputeBonusActionPointBoost(target, configType, combatid)
    local bonusActionPoints
    local bonusActionPointBoost = ComputeSimpleIncrementalBoost("BonusActionPointBoosts", target, configType, combatid)
    if (Osi.HasPassive(target, "Boost_BonusAction") and IsEnemiesEnhancedLoaded()) and bonusActionPointBoost > 2 then
        bonusActionPointBoost = bonusActionPointBoost - 1
    end

    bonusActionPoints = "ActionResource(BonusActionPoint," .. tonumber(bonusActionPointBoost) .. ",0)"

    return bonusActionPoints
end

function ComputeRageBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfBarbarian(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is barbarian")
        return nil
    end

    local rage

    local rageBoost = ComputeSimpleIncrementalBoost("RageBoosts", target, configType, combatid)
    rage = "ActionResource(Rage," .. rageBoost .. ",0)"

    return rage
end

function ComputeSorceryPointBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfCaster(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is caster")
        return nil
    end

    local sorceryPoints

    local sorcerPointBoost = ComputeSimpleIncrementalBoost("SorceryPointBoosts", target, configType, combatid)
    sorceryPoints = "ActionResource(SorceryPoint," .. sorcerPointBoost .. ",0)"

    return sorceryPoints
end

function ComputeTidesOfChaosBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfCaster(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is caster")
        return nil
    end

    local tidesOfChaos

    local tidesOfChaosBoost = ComputeSimpleIncrementalBoost("TidesOfChaosBoosts", target, configType, combatid)
    tidesOfChaos = "ActionResource(TidesOfChaos," .. tidesOfChaosBoost .. ",0)"

    return tidesOfChaos
end

function ComputeSuperiorityDieBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfFighter(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is fighter")
        return nil
    end

    local superiorityDie

    local superiorityDieBoost = ComputeSimpleIncrementalBoost("SuperiorityDieBoosts", target, configType, combatid)
    superiorityDie = "ActionResource(SuperiorityDie," .. superiorityDieBoost .. ",0)"

    return superiorityDie
end

function ComputeWildShapeBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfDruid(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is druid")
        return nil
    end

    local wildShape

    local wildShapeBoost = ComputeSimpleIncrementalBoost("WildShapeBoosts", target, configType, combatid)
    wildShape = "ActionResource(WildShape," .. wildShapeBoost .. ",0)"

    return wildShape
end

function ComputeNaturalRecoveryBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfDruid(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is druid")
        return nil
    end

    local naturalRecovery

    local naturalRecoveryBoost = ComputeSimpleIncrementalBoost("NaturalRecoveryBoosts", target, configType, combatid)
    naturalRecovery = "ActionResource(NaturalRecoveryPoint," .. naturalRecoveryBoost .. ",0)"

    return naturalRecovery
end

function ComputeFungalInfestationBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfDruid(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is druid")
        return nil
    end

    local fungalInfestation

    local fungalInfestationBoost = ComputeSimpleIncrementalBoost("FungalInfestationBoosts", target, configType, combatid)
    fungalInfestation = "ActionResource(FungalInfestationCharge," .. fungalInfestationBoost .. ",0)"

    return fungalInfestation
end

function ComputeLayOnHandsBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfPaladin(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is paladin")
        return nil
    end

    local layOnHands

    local layOnHandsBoost = ComputeSimpleIncrementalBoost("LayOnHandsBoosts", target, configType, combatid)
    layOnHands = "ActionResource(LayOnHandsCharge," .. layOnHandsBoost .. ",0)"

    return layOnHands
end

function ComputeChannelOathBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfPaladin(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is paladin")
        return nil
    end

    local channelOath

    local channelOathBoost = ComputeSimpleIncrementalBoost("ChannelOathBoosts", target, configType, combatid)
    channelOath = "ActionResource(ChannelOath," .. channelOathBoost .. ",0)"

    return channelOath
end

function ComputeChannelDivinityBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfCleric(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is cleric")
        return nil
    end

    local channelDivinity

    local channelDivinityBoost = ComputeSimpleIncrementalBoost("ChannelDivinityBoosts", target, configType, combatid)
    channelDivinity = "ActionResource(ChannelDivinity," .. channelDivinityBoost .. ",0)"

    return channelDivinity
end

function ComputeBardicInspirationBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfBard(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is bard")
        return nil
    end

    local bardicInspiration

    local bardicInspirationBoost = ComputeSimpleIncrementalBoost("BardicInspirationBoosts", target, configType, combatid)
    bardicInspiration = "ActionResource(BardicInspiration," .. bardicInspirationBoost .. ",0)"

    return bardicInspiration
end

function ComputeKiPointBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfMonk(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is monk")
        return nil
    end

    local kiPoints

    local kiPointBoost = ComputeSimpleIncrementalBoost("KiPointBoosts", target, configType, combatid)
    kiPoints = "ActionResource(KiPoint," .. kiPointBoost .. ",0)"

    return kiPoints
end

function ComputeDeflectMissilesBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfMonk(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is monk")
        return nil
    end

    local deflectMissilesCharges

    local deflectMissilesBoost = ComputeSimpleIncrementalBoost("DeflectMissilesBoosts", target, configType, combatid)
    deflectMissilesCharges = "ActionResource(DeflectMissiles_Charge," .. deflectMissilesBoost .. ",0)"

    return deflectMissilesCharges
end

function ComputeSneakAttackBoost(target, configType, combatid)
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not GuessIfRogue(target)
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target is rogue")
        return nil
    end

    local sneakAttackCharges

    local sneakAttackChargeBoost = ComputeSimpleIncrementalBoost("SneakAttackBoosts", target, configType, combatid)
    sneakAttackCharges = "ActionResource(SneakAttack_Charge," .. sneakAttackChargeBoost .. ",0)"

    return sneakAttackCharges
end

function ComputeHealthIncrease(target, configType, combatid)
    local hpincrease = ComputeIncrementalBoost("Health", target, configType, combatid)

    return "IncreaseMaxHP(" .. hpincrease .. ")"
end

function ComputeSimpleIncrementalBoost(stat, target, configType, combatid)
    local levelMultiplier = Osi.GetLevel(target)

    local staticBoost = tonumber(GetVarComplex(VarsJson, stat, "StaticBoost", target, configType))
    local levelIncrement = tonumber(GetVarComplex(VarsJson, stat, "LevelStepToIncrementOn", target, configType))
    local scalingLevelIncrement = tonumber(GetVarComplex(VarsJson, stat, "ValueToIncrementByOnLevel", target, configType))
    local scalingLevelBoost = scalingLevelIncrement * math.floor(levelMultiplier / levelIncrement)

    local totalBoost = staticBoost + scalingLevelBoost
    LogI(4, 8, string.format("%s Increase for %s: %s", stat, target, totalBoost))
    return totalBoost
end

function ComputeIncrementalBoost(stat, target, configType, combatid)
    local levelMultiplier = Osi.GetLevel(target)
    local statValueFns = {
        Strength = function() return Osi.GetAbility(target, "Strength") end,
        Dexterity = function() return Osi.GetAbility(target, "Dexterity") end,
        Constitution = function() return Osi.GetAbility(target, "Constitution") end,
        Wisdom = function() return Osi.GetAbility(target, "Wisdom") end,
        Intelligence = function() return Osi.GetAbility(target, "Intelligence") end,
        Charisma = function() return Osi.GetAbility(target, "Charisma") end,
        AC = function() return Ext.Entity.Get(target).Health.AC end,
        Health = function() return Ext.Entity.Get(target).Health.MaxHp end,
        Movement = function()
            local resourceGuid = ActionResources["Movement"]
            return Ext.Entity.Get(target).ActionResources.Resources[resourceGuid][1].MaxAmount
        end,
        RollBonus = function() return nil end,
        Damage = function() return nil end,
    }
    local statValueFn = statValueFns[stat]

    local statValue
    if statValueFn ~= nil then
        statValue = statValueFn()
    else
        statValue = nil
    end

    local maxPercentage = tonumber(GetVarComplex(VarsJson, stat, "MaxPercentage", target, configType))
    local scalingPercentage = tonumber(GetVarComplex(VarsJson, stat, "ScalingPercentage", target, configType))

    local staticBoost = tonumber(GetVarComplex(VarsJson, stat, "StaticBoost", target, configType))
    local levelIncrement = tonumber(GetVarComplex(VarsJson, stat, "LevelStepToIncrementOn", target, configType))
    local levelIncrementScaling = tonumber(GetVarComplex(VarsJson, stat, "ScalingLevelStepToIncrementOn", target, configType))
    local scalingLevelIncrement = tonumber(GetVarComplex(VarsJson, stat, "ValueToIncrementByOnLevel", target, configType))
    local scalingLevelBoost = scalingLevelIncrement * math.floor(levelMultiplier / levelIncrement)

    local percentageBoost
    local percentageScalingBoost
    if statValue ~= nil then
        percentageBoost = math.ceil((maxPercentage / 100) * tonumber(statValue))
        percentageScalingBoost = math.ceil((scalingPercentage / 100) * tonumber(statValue) * math.floor(levelMultiplier / levelIncrementScaling))
    else
        percentageBoost = 0
        percentageScalingBoost = 0
    end

    local totalBoost = staticBoost + percentageBoost + percentageScalingBoost + scalingLevelBoost
    LogI(4, 8, string.format("%s Increase for %s: %s", stat, target, totalBoost))
    return totalBoost
end


function ComputeMovementBoost(target, configType, combatid)
    local totalMovementBoost = ComputeIncrementalBoost("Movement", target, configType, combatid)
    local movement = "ActionResource(Movement," .. totalMovementBoost .. ",0)"
    return movement
end


function ComputeACBoost(target, configType, combatid)
    local totalACBoost = ComputeIncrementalBoost("AC", target, configType, combatid)
    local ac = "AC(" .. totalACBoost .. ")"
    return ac
end

function ComputeStrengthBoost(target, configType, combatid)
    local totalStrengthBoost = ComputeIncrementalBoost("Strength", target, configType, combatid)
    local strength = "Ability(Strength,+" .. totalStrengthBoost .. ")"
    return strength
end

function ComputeDexterityBoost(target, configType, combatid)
    local totalDexterityBoost = ComputeIncrementalBoost("Dexterity", target, configType, combatid)
    local dexterity = "Ability(Dexterity,+" .. totalDexterityBoost .. ")"
    return dexterity
end


function ComputeConstitutionBoost(target, configType, combatid)
    local totalConstitutionBoost = ComputeIncrementalBoost("Constitution", target, configType, combatid)
    local constitution = "Ability(Constitution,+" .. totalConstitutionBoost .. ")"
    return constitution
end

function ComputeIntelligenceBoost(target, configType, combatid)
    local totalIntelligenceBoost = ComputeIncrementalBoost("Intelligence", target, configType, combatid)
    local intelligence = "Ability(Intelligence,+" .. totalIntelligenceBoost .. ")"
    return intelligence
end

function ComputeWisdomBoost(target, configType, combatid)
    local totalWisdomBoost = ComputeIncrementalBoost("Wisdom", target, configType, combatid)
    local wisdom = "Ability(Wisdom,+" .. totalWisdomBoost .. ")"
    return wisdom
end

function ComputeCharismaBoost(target, configType, combatid)
    local totalCharismaBoost = ComputeIncrementalBoost("Charisma", target, configType, combatid)
    local charisma = "Ability(Charisma,+" .. totalCharismaBoost .. ")"
    return charisma
end

function ComputeRollBonusBoost(target, configType, combatid)
    local totalRollBonus = ComputeIncrementalBoost("RollBonus", target, configType, combatid)
    local rollBonus = "RollBonus(Attack," .. totalRollBonus .. ")"
    return rollBonus
end



function ComputeDamageBoost(target, configType, combatid)
    local totalDamageBoost = ComputeIncrementalBoost("Damage", target, configType, combatid)
    local damageBonus = "DamageBonus(" .. totalDamageBoost .. ")"
    return damageBonus
end

function ComputeSpellSlotBoosts(target, configType, combatid)
    local slots = {}
    if (
        tonumber(VarsJson["Lore"]) == 1 and
        not (
            GuessIfCaster(target) or
            GuessIfDruid(target) or
            GuessIfCleric(target) or
            GuessIfBard(target) or
            GuessIfWarlock(target) or
            GuessIfRanger(target) or
            GuessIfPaladin(target)
        )
    ) then
        LogI(1, 22, "Lore on, couldnt guess if target needs spell slots")
        return slots
    end

    local spellSlotBoost = ComputeSimpleIncrementalBoost("SpellSlotBoosts", target, configType, combatid)

    local npcLevel = tonumber(Osi.GetLevel(target))
    local requiredSpellLevels = LevelGate(VarsJson, "SpellsAdded", 9, npcLevel, target, configType)

    table.sort(requiredSpellLevels, function (l, r) return l > r end)

    for _, level in ipairs(requiredSpellLevels) do
        LogI(4, 10, string.format("SpellSlotBoost Increase for %s: %s at level %s", target, spellSlotBoost, level))

        local spellSlot = "ActionResource(SpellSlot," .. spellSlotBoost .. "," .. level .. ")"

        slots[level] = spellSlot

        spellSlotBoost = spellSlotBoost + 1
    end
    return slots
end

function CalculateLists()
    OverrideBlacklistedAbilities= VarsJson["BlacklistedAbilities"]
    OverrideBlacklistedPassives = VarsJson["BlacklistedPassives"]
    OverrideBlacklistedAbilitiesByClass = VarsJson["BlacklistedAbilitiesByClass"]
    OverrideBlacklistedPassivesByClass = VarsJson["BlacklistedPassivesByClass"]
    OverrideBlacklistedLists = VarsJson["BlacklistedLists"]

    local blacklistedAbilitiesByClass
    local blacklistedPassivesByClass
    local blacklistedAbilities
    local blacklistedPassives
    local blacklistedLists

    if OverrideBlacklistedAbilitiesByClass ~= nil and OverrideBlacklistedAbilitiesByClass ~= {} then
        blacklistedAbilitiesByClass = OverrideBlacklistedAbilitiesByClass
    else
        blacklistedAbilitiesByClass = BlacklistedAbilitiesByClass
    end

    if OverrideBlacklistedPassivesByClass ~= nil and OverrideBlacklistedPassivesByClass ~= {} then
        blacklistedPassivesByClass = OverrideBlacklistedPassivesByClass
    else
        blacklistedPassivesByClass = BlacklistedPassivesByClass
    end

    if OverrideBlacklistedAbilities ~= nil and OverrideBlacklistedAbilities ~= {} then
        blacklistedAbilities = OverrideBlacklistedAbilities
    else
        blacklistedAbilities = BlacklistedAbilities
    end

    if OverrideBlacklistedPassives ~= nil and OverrideBlacklistedPassives ~= {} then
        blacklistedPassives = OverrideBlacklistedPassives
    else
        blacklistedPassives = BlacklistedPassives
    end

    if OverrideBlacklistedLists ~= nil and OverrideBlacklistedLists ~= {} then
        blacklistedLists = OverrideBlacklistedLists
    else
        blacklistedLists = BlacklistedLists
    end

    SpellListsByClass = GenerateSpellLists(blacklistedAbilitiesByClass, blacklistedAbilities, blacklistedLists, FindRootClasses())
    PassiveListsByClass = GeneratePassiveLists(blacklistedPassivesByClass, blacklistedPassives, blacklistedLists, FindRootClasses())

    SpellData = {}
    for _, spells in pairs(SpellListsByClass) do
        for spellName, classSpell in pairs(spells.Spells) do
            SpellData[spellName] = classSpell.Spell
        end
    end

end

BlacklistedLists = {
}

BlacklistedAbilitiesByClass = {
    ArcaneArcher5e = true,
    ArcaneTrickster = true,
    EldritchKnight = true,
}

BlacklistedPassivesByClass = {
}

BlacklistedAbilities = {
    Target_Goodberry = true,
    Target_EnhanceAbility = true,
    Shout_SpeakWithAnimals = true,
}

BlacklistedPassives = {
    ArcanaAdd = true,
    Arcane_Archer_Lore = true,
    BMCommandingPresence = true,
    BMCommandingPresence_2 = true,
    BardSpellcasting = true,
    BardicInspiration = true,
    BardicInspiration_12 = true,
    BardicInspiration_d10 = true,
    BardicInspiration_d8 = true,
    ClericsVOA = true,
    ClericsVOA2 = true,
    ClericsVOA3 = true,
    ClericsVOA4 = true,
    ClericsVOA5 = true,
    ClericsVOA6 = true,
    FeralInstict = true,
    MageHandLegerdemain = true,
    MoonDomainCastCheckFaerieFire = true,
    MoonDomainCastCheckFogCloud = true,
    MoonDomainCastCheckGaseousForm = true,
    MoonDomainCastCheckHypnoticPattern = true,
    MoonDomainCastCheckInvisibility = true,
    MoonDomainCastCheckInvisibility_Greater = true,
    MoonDomainCastCheckMoonbeam = true,
    MoonDomainCastCheckPlanarBinding = true,
    MoonDomainCastCheckPolymorph = true,
    MoonDomainCastCheckSeeming = true,
    MoonDomain_Toggle_6 = true,
    MoonDomain_Toggle_7 = true,
    MoonDomain_Toggle_9 = true,
    NaturalExplorer_UrbanTracker = true,
    Oath_Ancients_Tenents = true,
    Oath_Devotion_Tenents = true,
    Oath_Vengeance_Tenents = true,
    Rage_Armour_Message = true,
    Rage_NoHeavyArmour_VFX = true,
    SanguineRecallRecoveryPointAddition = true,
    SanguineRecallRecoveryPointAddition10 = true,
    SanguineRecallRecoveryPointAddition12 = true,
    SanguineRecallRecoveryPointAddition14 = true,
    SanguineRecallRecoveryPointAddition16 = true,
    SanguineRecallRecoveryPointAddition18 = true,
    SanguineRecallRecoveryPointAddition20 = true,
    SanguineRecallRecoveryPointAddition8 = true,
    UnlockedSpellSlotLevel1 = true,
    UnlockedSpellSlotLevel2 = true,
    UnlockedSpellSlotLevel3 = true,
    UnlockedSpellSlotLevel4 = true,
    UnlockedSpellSlotLevel5 = true,
    UnlockedSpellSlotLevel6 = true,
    WuxiaWeapon_Melee_Battleaxes = true,
    WuxiaWeapon_Melee_Clubs = true,
    WuxiaWeapon_Melee_Daggers = true,
    WuxiaWeapon_Melee_Flails = true,
    WuxiaWeapon_Melee_Handaxes = true,
    WuxiaWeapon_Melee_Javelins = true,
    WuxiaWeapon_Melee_LightHammers = true,
    WuxiaWeapon_Melee_Longswords = true,
    WuxiaWeapon_Melee_Maces = true,
    WuxiaWeapon_Melee_Morningstars = true,
    WuxiaWeapon_Melee_Quarterstaffs = true,
    WuxiaWeapon_Melee_Rapiers = true,
    WuxiaWeapon_Melee_Scimitars = true,
    WuxiaWeapon_Melee_Shortswords = true,
    WuxiaWeapon_Melee_Sickles = true,
    WuxiaWeapon_Melee_Spears = true,
    WuxiaWeapon_Melee_Tridents = true,
    WuxiaWeapon_Melee_Warhammers = true,
    WuxiaWeapon_Melee_Warpicks = true,
    WuxiaWeapon_Ranged_Darts = true,
    WuxiaWeapon_Ranged_HandCrossbows = true,
    WuxiaWeapon_Ranged_LightCrossbows = true,
    WuxiaWeapon_Ranged_Longbows = true,
    WuxiaWeapon_Ranged_Shortbows = true,
    WuxiaWeapon_Ranged_Slings = true,
    ["4"] = true,
}

ExcludedNPCs = {
    "S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323",
    "S_GOB_DrowCommander_25721313-0c15-4935-8176-9f134385451b",
    "S_Player_Astarion_c7c13742-bacd-460a-8f65-f864fe41f255",
    "S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604",
    "S_Player_Jaheira_91b6b200-7d00-4d62-8dc9-99e8339dfa1a",
    "S_Player_Karlach_2c76687d-93a2-477b-8b18-8a14b549304c",
    "S_Player_Laezel_58a69333-40bf-8358-1d17-fff240d7fb12",
    "S_Player_Minsc_0de603c5-42e2-4811-9dad-f652de080eba",
    "S_Player_ShadowHeart_3ed74f06-3c60-42dc-83f6-f034cb47c679",
    "S_Player_Wyll_c774d764-4a17-48dc-b470-32ace9ce447d",
}

AiHints = {
    AI_HINT_CASTER = "45a231e4-e94f-4b0e-a941-2daf1adf44b5", -- found on mage and healer_range
    AI_HINT_RANGER = "3cae4ff5-e9c0-485b-b695-f8830961a781", -- found on ranged
    AI_HINT_EMPTY = "f76e60e1-2957-470b-8a25-efdf32475ce0", -- first found paired with melee
    AI_HINT_UNIQUE = "1902723d-dd16-4e7a-87d6-7b07f63add79", -- found on hag_green
}

Archetypes = {
    "healer_ranged",
    "ranged",
    "melee",
    "mage",
    "hag_green",
}

function Log(level, str)
    if (tonumber(VarsJson["Verbosity"]) or 0) >= level then
        print(string.format("LoreCombatConfigurator: %s", str))
    end
end

function LogI(level, indent, str)
    local spaces = string.rep(" ", indent)
    Log(level, string.format("%s%s", spaces, str))
end

Defaults = {
    -- Makes Action Point boosting more conservative when boosting a character with ExtraAttack to prevent insanity
    ConservativeActionPointBoosts = 1,
    -- Controls How many max level spells will be added. Scales with level if wanted. Each lower level added will have 1 more spell, incrementally.
    SpellsAdded = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
        -- Controls the minimum level the character must be to get spells of the specified level
        LevelGate = {
            MinCharLevelForLevel1 = 13,
            MinCharLevelForLevel2 = 13,
            MinCharLevelForLevel3 = 13,
            MinCharLevelForLevel4 = 13,
            MinCharLevelForLevel5 = 13,
            MinCharLevelForLevel6 = 13,
            MinCharLevelForLevel7 = 13,
            MinCharLevelForLevel8 = 13,
            MinCharLevelForLevel9 = 13,
        },
    },
    -- Controls How many class specific passives will be added with `Lore = 1`. Scales with level if wanted
    PassivesAdded = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
        -- Controls the minimum level the character must be to get class specific passives of the specified level with `Lore = 1`
        LevelGate = {
            MinCharLevelForLevel1 = 13,
            MinCharLevelForLevel2 = 13,
            MinCharLevelForLevel3 = 13,
            MinCharLevelForLevel4 = 13,
            MinCharLevelForLevel5 = 13,
            MinCharLevelForLevel6 = 13,
            MinCharLevelForLevel7 = 13,
            MinCharLevelForLevel8 = 13,
            MinCharLevelForLevel9 = 13,
            MinCharLevelForLevel10 = 13,
            MinCharLevelForLevel11 = 13,
            MinCharLevelForLevel12 = 13,
            MinCharLevelForLevel13 = 13,
            MinCharLevelForLevel14 = 13,
            MinCharLevelForLevel15 = 13,
            MinCharLevelForLevel16 = 13,
            MinCharLevelForLevel17 = 13,
            MinCharLevelForLevel18 = 13,
            MinCharLevelForLevel19 = 13,
            MinCharLevelForLevel20 = 13,
        },
    },
    -- Controls How many non spell abilities will be added. Scales with level if wanted
    AbilitiesAdded = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
        -- Controls the minimum level the character must be to get class specific abiltiies (isSpell = False) of the specified level with `Lore = 1`
        LevelGate = {
            MinCharLevelForLevel1 = 13,
            MinCharLevelForLevel2 = 13,
            MinCharLevelForLevel3 = 13,
            MinCharLevelForLevel4 = 13,
            MinCharLevelForLevel5 = 13,
            MinCharLevelForLevel6 = 13,
            MinCharLevelForLevel7 = 13,
            MinCharLevelForLevel8 = 13,
            MinCharLevelForLevel9 = 13,
            MinCharLevelForLevel10 = 13,
            MinCharLevelForLevel11 = 13,
            MinCharLevelForLevel12 = 13,
            MinCharLevelForLevel13 = 13,
            MinCharLevelForLevel14 = 13,
            MinCharLevelForLevel15 = 13,
            MinCharLevelForLevel16 = 13,
            MinCharLevelForLevel17 = 13,
            MinCharLevelForLevel18 = 13,
            MinCharLevelForLevel19 = 13,
            MinCharLevelForLevel20 = 13,
        },
    },
    -- Controls How many max spell slots will be added (to casters with `Lore = 1`). Scales with level if wanted. Each lower level added will have 1 more spell slot, incrementally.
    SpellSlotBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many action points will be added. Scales with level if wanted (affected by `ConservativeActionPointBoosts`)
    ActionPointBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many action points will be added. Scales with level if wanted
    BonusActionPointBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many rage charges will be added (to barbarians with `Lore = 1`). Scales with level if wanted
    RageBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many sorcery points will be added (to casters with `Lore = 1`). Scales with level if wanted
    SorceryPointBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many tides of chaos will be added (to casters with `Lore = 1`). Scales with level if wanted
    TidesOfChaosBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many superiority die will be added (to fighters with `Lore = 1`). Scales with level if wanted
    SuperiorityDieBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many wild shape charges will be added (to druids with `Lore = 1`). Scales with level if wanted
    WildShapeBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many natural recovery points will be added (to druids with `Lore = 1`). Scales with level if wanted
    NaturalRecoveryBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many fungal infestation charges will be added (to druids with `Lore = 1`). Scales with level if wanted
    FungalInfestationBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many lay on hands charges will be added (to paladins with `Lore = 1`). Scales with level if wanted
    LayOnHandsBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many channel oath charges will be added (to paladins with `Lore = 1`). Scales with level if wanted
    ChannelOathBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many channel divinty charges will be added (to clerics with `Lore = 1`). Scales with level if wanted
    ChannelDivinityBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many ki points will be added (to monks with `Lore = 1`). Scales with level if wanted
    KiPointBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many deflect missiles charges will be added (to monks with `Lore = 1`). Scales with level if wanted
    DeflectMissilesBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many sneak attack charges will be added (to rogues with `Lore = 1`). Scales with level if wanted
    SneakAttackBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much health to add to the character. Scales with level if wanted, additionally can scale with max health
    Health = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much dexterity to add to the character. Scales with level if wanted, additionally can scale with base dexterity
    Dexterity = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much strength to add to the character. Scales with level if wanted, additionally can scale with base strength
    Strength = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much constitution to add to the character. Scales with level if wanted, additionally can scale with base constitution
    Constitution = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much intelligence to add to the character. Scales with level if wanted, additionally can scale with base intelligence
    Intelligence = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much charisma to add to the character. Scales with level if wanted, additionally can scale with base charisma
    Charisma = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much wisdom to add to the character. Scales with level if wanted, additionally can scale with base wisdom
    Wisdom = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much bonus to give to the characters hit dice rolls. Scales with level if wanted, additionally can scale with base bonus
    RollBonus = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much damage bonus to give to the characters dice rolls. Scales with level if wanted, additionally can scale with base bonus
    Damage = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much armor class bonus to give to the characters. Scales with level if wanted, additionally can scale with base armor class
    AC = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much movement bonus to give to the characters. Scales with level if wanted, additionally can scale with base movement
    Movement = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
}


local function OnSessionLoaded()
    VarsJson = {}

    Log(0, "0.9.0.0")
    ConfigFailed = 0
    ActionResources = {}
    Tags = {}

    SpellsAdded = {}
    PassivesAdded = {}
    ImplicatedGuids = {}

    for _, resourceGuid in pairs(Ext.StaticData.GetAll("ActionResource")) do
        local resource = Ext.StaticData.Get(resourceGuid, "ActionResource")
        ActionResources[resource.Name] = resourceGuid
    end

    for _, tagGuid in pairs(Ext.StaticData.GetAll("Tag")) do
        local tag = Ext.StaticData.Get(tagGuid, "Tag")
        Tags[tag.Name] = tagGuid
    end

    function ResetConfigJson()
        ConfigFailed = 0
        local defaultConfig = {
            -- The following control whether we are allowing the mod to affect these types
            -- Bog Standard Enemies
            EnemiesEnabled = 0,
            -- Enemies Classified as Bosses
            BossesEnabled = 0,
            -- Characters that are Allied with us
            AlliesEnabled = 0,
            -- Characters that are following us
            FollowersEnabled = 0,
            -- Characters that are following us that are Classified as Bosses
            FollowersBossesEnabled = 0,
            -- Characters that we have summoned
            SummonsEnabled = 0,
            -- This toggle attempts to be more lore friendly.
            -- It enables many checks and guards such as:
            -- - Apply class specific resources additions and ability / passive additions by inspecting the inferred class of the target
            -- - Only add spells that the inferred class could theoretically have in their spell lists
            -- The classes inferred may be overridden by the `Kinds` top level key. The Key is the `stats` object in the `stats` chain for the character in question
            -- There are also archetype checks that may be turned on or off with the .+ArchetypeCheck keys. These inspect the Stats.Archetype value for the character in question
            Lore = 0,
            CasterArchetypeCheck = 0,
            HealerArchetypeCheck = 0,
            FighterArchetypeCheck = 0,
            MonkArchetypeCheck = 0,
            RogueArchetypeCheck = 0,
            RangerArchetypeCheck = 0,
            WarlockArchetypeCheck = 0,
            ClericArchetypeCheck = 0,
            DruidArchetypeCheck = 0,
            BarbarianArchetypeCheck = 0,
            BardArchetypeCheck = 0,
            PaladinArchetypeCheck = 0,
            -- This changes the selection function from random to a consistent hash based on primarilly the target guid
            ConsistentHash = 0,
            -- Integer that allows the salt for the consistent hash to be modified to allow for different results
            ConsistentHashSalt = nil,
            -- Disables detection of EnhancedEnemies mod and its Passives for Lore inference when set to `1`
            DebugDisableEE = 0,
            -- Controls the verbosity of logging for debugging
            Verbosity = 0,
            -- Allows overriding the inferred classes or kinds of characters by inspecting their `stats` chain
            Kinds = {
                Dragonborn_Cleric = {"Cleric"},
            },
            BlacklistedAbilities = {},
            BlacklistedPassives = {},
            BlacklistedAbilitiesByClass = {},
            BlacklistedPassivesByClass = {},
            -- The following configures the boosts that will be added to normal enemies
            Enemies = Defaults,
            -- The following configures the boosts that will be added to bosses
            Bosses = Defaults,
            -- The following configures the boosts that will be added to ally characters
            Allies = Defaults,
            -- The following configures the boosts that will be added to followers
            Followers = Defaults,
            -- The following configures the boosts that will be added to boss followers
            FollowersBosses = Defaults,
            -- The following configures the boosts that will be added to summons
            Summons = Defaults,
            -- Any guid may be fully overridden with a custom config
            ["S_UND_LoneDuergar_BoatGuard_New_001_28b78823-c846-4492-bdb4-14034f3bfced"] = {
                ActionPointBoosts = {
                    StaticBoost = 0,
                    LevelStepToIncrementOn = 1,
                    ValueToIncrementByOnLevel = 0,
                },
            },
        }
        local opts = {
            Beautify = true,
            StringifyInternalTypes = true,
            IterateUserdata = true,
            AvoidRecursion = true
        }
        Ext.IO.SaveFile("LoreCombatConfigurator.json", Ext.Json.Stringify(defaultConfig, opts))
        GetVarsJson()
    end

    function GetVarsJson()
        ConfigStr = Ext.IO.LoadFile("LoreCombatConfigurator.json")
        if (ConfigStr == nil) then
            Log(0, "Creating configuration file.")
            ResetConfigJson()
        end
        VarsJson = Ext.Json.Parse(ConfigStr)
        if VarsJson["ConsistentHash"] ~= nil and VarsJson["ConsistentHash"] == 1 and VarsJson["ConsistentHashSalt"] == nil then
            VarsJson["ConsistentHashSalt"] = Ext.Math.Random()
        end
        Log(1, string.format("Json Loaded %s\n", Ext.Json.Stringify(VarsJson)))

        -- Updated Closed Over Vars that need Config Vars here
        EntityToKinds = function(target) return _EntityToKinds(VarsJson, Kinds, target) end
        EntityToRestrictions = function(target) return _EntityToRestrictions(VarsJson, Restrictions, target) end

        CalculateLists()
    end

    GetVarsJson()

    function GiveNewSpells(target, configType, combatid)
        local spells = ComputeNewSpells(target, configType, combatid)
        for _, spell in pairs(spells) do
            LogI(3, 24, string.format("Adding spell %s to %s", spell, target))
            Osi.AddSpell(target, spell)
        end
        SpellsAdded[combatid][target] = TableCombine(Keys(spells), SpellsAdded[combatid][target])
    end

    function GiveNewPassives(target, configType, combatid)
        local passives = ComputeClassSpecificPassives(target, configType, combatid)
        for _, passive in pairs(passives) do
            LogI(3, 24, string.format("Adding passive %s to %s", passive, target))
            Osi.AddPassive(target, passive)
        end
        PassivesAdded[combatid][target] = TableCombine(Keys(passives), PassivesAdded[combatid][target])
    end

    function GiveNewAbilities(target, configType, combatid)
        local abilities = ComputeClassSpecificAbilities(target, configType, combatid)
        for _, ability in pairs(abilities) do
            LogI(3, 24, string.format("Adding ability %s to %s", ability, target))
            Osi.AddSpell(target, ability)
        end
        SpellsAdded[combatid][target] = TableCombine(Keys(abilities), SpellsAdded[combatid][target])
    end

    function GiveComputedBoost(boostFn, target, configType, combatid)
        local boostRes = boostFn(target, configType, combatid)

        if boostRes ~= nil then
            local boosts = nil

            if type(boostRes) ~= "table" then
                boosts = {boostRes}
            else
                boosts = boostRes
            end

            for _, boost in ipairs(boosts) do

                table.insert(ImplicatedGuids[combatid][target], boost)

                AddBoostsAdv(target, boost, combatid)
            end
        end
    end

    function GiveBoosts(guid, configType, combatid)
        LogI(1, 4, string.format("%s applying for Guid: %s\n", configType, guid))
        GiveNewSpells(guid, configType, combatid)

        GiveNewPassives(guid, configType, combatid)

        GiveNewAbilities(guid, configType, combatid)

        local boosts = {
            ComputeHealthIncrease,
            ComputeActionPointBoost,
            ComputeBonusActionPointBoost,
            ComputeRageBoost,
            ComputeSorceryPointBoost,
            ComputeTidesOfChaosBoost,
            ComputeSuperiorityDieBoost,
            ComputeWildShapeBoost,
            ComputeNaturalRecoveryBoost,
            ComputeFungalInfestationBoost,
            ComputeLayOnHandsBoost,
            ComputeChannelOathBoost,
            ComputeChannelDivinityBoost,
            ComputeBardicInspirationBoost,
            ComputeKiPointBoost,
            ComputeDeflectMissilesBoost,
            ComputeSneakAttackBoost,
            ComputeMovementBoost,
            ComputeACBoost,
            ComputeStrengthBoost,
            ComputeDexterityBoost,
            ComputeConstitutionBoost,
            ComputeIntelligenceBoost,
            ComputeWisdomBoost,
            ComputeCharismaBoost,
            ComputeRollBonusBoost,
            ComputeDamageBoost,
            ComputeSpellSlotBoosts,
        }

        for _, boostFn in ipairs(boosts) do
            GiveComputedBoost(boostFn, guid, configType, combatid)
        end

        Osi.ApplyStatus(guid, "LCC_MODIFIED", -1)
    end

    Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", function(guid, combatid)
            Log(1, string.format("Give: Guid: %s", guid))

            local isCharacter = Osi.IsCharacter(guid) == 1
            if not isCharacter then
                Log(4, string.format("Give: Skipping non character: Guid: %s", guid))
                return
            end

            local firstEntity = false
            if ImplicatedGuids[combatid] == nil then
                ImplicatedGuids[combatid] = {}
                firstEntity = true
            end
            if SpellsAdded[combatid] == nil then
                SpellsAdded[combatid] = {}
                firstEntity = true
            end
            if PassivesAdded[combatid] == nil then
                PassivesAdded[combatid] = {}
                firstEntity = true
            end
            -- This is a small hack. Some mods load their spells later than session loaded.
            -- Without loading the lists late enough, you will get different consistent hash
            -- spell results after reloading the game.
            if firstEntity then
                Log(1, "Recomputing lists")
                CalculateLists()
            end

            SpellsAdded[combatid][guid] = {}
            PassivesAdded[combatid][guid] = {}

            ImplicatedGuids[combatid][guid] = {}

            local isPartyMember = CheckIfParty(guid) == 1
            local isPartyFollower = Osi.IsPartyFollower(guid) == 1
            local isEnemy = Osi.IsEnemy(guid, Osi.GetHostCharacter()) == 1
            local isOrigin = CheckIfOrigin(guid) == 1
            local isBoss = Osi.IsBoss(guid) == 1
            local isOurSummon = CheckIfOurSummon(guid) == 1

            local entity = Ext.Entity.Get(guid)
            local CombatComponent = SafeGet(entity, "ServerCharacter", "Character", "Template", "CombatComponent")
            local rawAIHint = SafeGet(CombatComponent, "AiHint")
            local mappedAIHint = SafeGet(AiHints, SafeGet(CombatComponent, "AiHint"))
            local rawArchetype = SafeGet(CombatComponent, "Archetype")
            local alreadyModified = Osi.HasAppliedStatus(guid, "LCC_MODIFIED") == 1

            local kinds = EntityToKinds(guid) or {}
            local allClasses = {}
            for kind, _ in pairs(kinds) do
                local classes = KindMapping[kind]
                allClasses = TableCombine(classes, allClasses)
            end

            local restrictions = EntityToRestrictions(guid) or {}

            Log(1, string.format("Give: Guid: %s; Modified?: %s; Party?: %s; Follower?: %s; Enemy?: %s; Origin?: %s; Boss?: %s; OurSummon?: %s\n", guid, alreadyModified, isPartyMember, isPartyFollower, isEnemy, isOrigin, isBoss, isOurSummon))
            Log(1, string.format("Give: Guid: %s; Combatid: %s: %s\n", guid, combatid, entity))
            Log(1, string.format("Give: AiHint: %s (%s) Archetype: %s\n", rawAIHint, mappedAIHint, rawArchetype))
            Log(1, string.format("Give: Kinds: %s; Classes: %s; Restrictions %s\n", Ext.Json.Stringify(kinds), Ext.Json.Stringify(allClasses), Ext.Json.Stringify(restrictions)))

            if VarsJson["EnemiesEnabled"] == 1 then
                if not alreadyModified and (not isPartyMember and isEnemy and not isBoss and not isOrigin) then
                    GiveBoosts(guid, "Enemies", combatid)
                end
            end
            if VarsJson["BossesEnabled"] == 1 then
                if not alreadyModified and (not isPartyMember and isEnemy and isBoss and not isOrigin) then
                    GiveBoosts(guid, "Bosses", combatid)
                end
            end
            if VarsJson["AlliesEnabled"] == 1 then
                if not alreadyModified and (not isPartyMember and not isEnemy and not isOrigin and not isBoss) then
                    GiveBoosts(guid, "Allies", combatid)
                end
            end
            if VarsJson["FollowersEnabled"] == 1 then
                if not alreadyModified and (not isEnemy and not isOrigin and isPartyFollower and not isBoss) then
                    GiveBoosts(guid, "Followers", combatid)
                end
            end
            if VarsJson["FollowersBossesEnabled"] == 1 then
                if not alreadyModified and (not isEnemy and not isOrigin and isPartyFollower and isBoss) then
                    GiveBoosts(guid, "FollowersBosses", combatid)
                end
            end
            if VarsJson["SummonsEnabled"] == 1 then
                if not alreadyModified and (isPartyMember and isOurSummon) then
                    GiveBoosts(guid, "Summons", combatid)
                end
            end
        end
    )
    Ext.Osiris.RegisterListener("CombatEnded",1,"after",function(combatid)
            Log(1, string.format("CombatEnded: combatid: %s\n", combatid))
            local currentCombatBoosts = ImplicatedGuids[combatid]
            Log(1, string.format("CombatEnded: currentCombatBoosts: %s\n", currentCombatBoosts))
            if (currentCombatBoosts ~= nil) then
                for guid, boosts in pairs(currentCombatBoosts) do
                    Log(1, string.format("Remove Boosts: Guid: %s; Char?: %s; Party?: %s; Follower?: %s; Enemy?: %s; Origin?: %s; Boss?: %s\n", guid, Osi.IsCharacter(guid), CheckIfParty(guid), Osi.IsPartyFollower(guid), Osi.IsEnemy(guid, Osi.GetHostCharacter()), CheckIfOrigin(guid), Osi.IsBoss(guid)))
                    Log(1, string.format("Remove Boosts: Guid: %s; %s\n", guid, Ext.Entity.Get(guid)))

                    for _, boost in ipairs(boosts) do
                        Log(1, string.format("Remove Boost: Guid: %s; combatid: %s; boost: %s\n", guid, combatid, boost))
                        RemoveBoostsAdv(guid, boost, combatid)
                    end
                end
                ImplicatedGuids[combatid] = {}
            end
            local currentCombatSpellsAdded = SpellsAdded[combatid]
            Log(1, string.format("CombatEnded: currentCombat: %s\n", currentCombatSpellsAdded))
            if (currentCombatSpellsAdded ~= nil) then
                for guid, spells in pairs(currentCombatSpellsAdded) do
                    Log(1, string.format("Remove Spells Added: Guid: %s; Char?: %s; Party?: %s; Follower?: %s; Enemy?: %s; Origin?: %s; Boss?: %s\n", guid, Osi.IsCharacter(guid), CheckIfParty(guid), Osi.IsPartyFollower(guid), Osi.IsEnemy(guid, Osi.GetHostCharacter()), CheckIfOrigin(guid), Osi.IsBoss(guid)))
                    Log(1, string.format("Remove Spells Added: Guid: %s; %s\n", guid, Ext.Entity.Get(guid)))

                    for _, spell in ipairs(spells) do
                        Log(1, string.format("Remove Spell: Guid: %s; combatid: %s; boost: %s\n", guid, combatid, spell))
                        Osi.RemoveSpell(guid, spell, 1)
                    end
                end
                SpellsAdded[combatid] = {}
            end
            local currentCombatPassivesAdded = PassivesAdded[combatid]
            Log(1, string.format("CombatEnded: currentCombat: %s\n", currentCombatPassivesAdded))
            if (currentCombatPassivesAdded ~= nil) then
                for guid, passives in pairs(currentCombatPassivesAdded) do
                    Log(1, string.format("Remove Passives Added: Guid: %s; Char?: %s; Party?: %s; Follower?: %s; Enemy?: %s; Origin?: %s; Boss?: %s\n", guid, Osi.IsCharacter(guid), CheckIfParty(guid), Osi.IsPartyFollower(guid), Osi.IsEnemy(guid, Osi.GetHostCharacter()), CheckIfOrigin(guid), Osi.IsBoss(guid)))
                    Log(1, string.format("Remove Passives Added: Guid: %s; %s\n", guid, Ext.Entity.Get(guid)))

                    for _, passive in ipairs(passives) do
                        Log(1, string.format("Remove Passive: Guid: %s; combatid: %s; boost: %s\n", guid, combatid, passive))
                        Osi.RemovePassive(guid, passive)
                    end
                end
                PassivesAdded[combatid] = {}
            end
        end
    )
    Ext.Osiris.RegisterListener("PingRequested",1,"after",function(_)
        Log(1, "Applying current config.")
        GetVarsJson()
    end)

end

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)
