ModName = "LoreCombatConfigurator"
-- IMPORTANT: When the config is changed internally in a way that wont be reflected in its text by a user
-- (defaults, inheritance, fallbacks), This value must be changed.
CONFIG_HASH_SALT = 1234

NULL_GUID = "00000000-0000-0000-0000-000000000000"

-- Courtesy to @Buns on Discord
--- @generic T
--- @param object table<string, any> | nil
--- @param ... string
--- @return T | nil, nil | string
function SafeGet(object, ...)
    local result = object
    local error = "SafeGet: object"
    if not result then
        error = error .. " is nil"
        return nil, error
    end
    local arg = {...}
    for _, v in ipairs(arg) do

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

--- @generic T
--- @param default T
--- @param object table<string, any>
--- @param ... string
--- @return T
function SafeGetWithDefault(default, object, ...)
    local result, error = SafeGet(object, ...)
    if error ~= nil then
        return default
    else
        return result
    end
end

---Copies an object deeply
--- @generic T : any
---@param original T
---@return T
function DeepCopy(original)
    local originalType = type(original)
    local copy = nil
    if originalType == 'table' then
        copy = {}
        for originalKey, originalValue in next, original, nil do
            copy[DeepCopy(originalKey)] = DeepCopy(originalValue)
        end
    else
        copy = original
    end
    return copy
end

-- Courtesy to @Eralyne on Discord
---Delay a function call by the given time
---@param ms integer
---@param func function
function DelayedCall(ms, func)
    local Time = 0
    local handler
    handler = Ext.Events.Tick:Subscribe(function(e)
        Time = Time + e.Time.DeltaTime * 1000
        if (Time >= ms) then
            func()
            Ext.Events.Tick:Unsubscribe(handler)
        end
    end)
end

---Delay a function call to wait to run once when the predicate holds true
---@param pred function
---@param func function
function DelayedCallUntil(pred, func)
    local handler
    handler = Ext.Events.Tick:Subscribe(function(_)
        if (pred()) then
            func()
            Ext.Events.Tick:Unsubscribe(handler)
        end
    end)
end

---Delay a function call to run continuously until the predicate holds true
---@param pred function
---@param func function
function DelayedCallWhile(pred, func)
    local handler
    handler = Ext.Events.Tick:Subscribe(function(_)
        func()
        if (pred()) then
            Ext.Events.Tick:Unsubscribe(handler)
        end
    end)
end

---Delay a function call to wait to run once when the predicate holds true
-- but only after the time delay
---@param ms integer
---@param pred function
---@param func function
function DelayedCallUntilWithAtLeastTime(ms, pred, func)
    local Time = 0
    local handler
    handler = Ext.Events.Tick:Subscribe(function(e)
        Time = Time + e.Time.DeltaTime * 1000
        if (Time >= ms) then
            if (pred()) then
                func()
                Ext.Events.Tick:Unsubscribe(handler)
            end
        end
    end)
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

--- @generic A, V, T
--- @param fn fun(result:A, val: V): A
--- @param acc A
--- @param listlike V[]
--- @return A
function Fold(fn, acc, listlike)
    local result = acc
    for _, val in ipairs(listlike) do
        result = fn(result, val)
    end
    return result
end

--- @generic K, V, T
--- @param fn fun(val: V): K, T
--- @param listlike V[]
--- @return table<K, T>
function ListToTable(fn, listlike)
    local result = {}
    local fn1 = function(acc, val)
        local key, value = fn(val)
        acc[key] = value
        return acc
    end
    return Fold(fn1, result, listlike)
end

--- @generic V, T
--- @param fn fun(val: V): T
--- @param listlike V[]
--- @return T[]
function Map(fn, listlike)
    local result = {}
    for _, val in ipairs(listlike) do
        table.insert(result, fn(val))
    end
    return result
end

--- @generic V
--- @param fn fun(val: V): boolean
--- @param listlike V[]
--- @return V[]
function Filter(fn, listlike)
    local result = {}
    for _, val in ipairs(listlike) do
        if fn(val) then
            table.insert(result, val)
        end
    end
    return result
end

--- @generic K, V, T
--- @param fn fun(val: V): T
--- @param tablelike table<K, V>
--- @return table<K, T>
function MapTableValues(fn, tablelike)
    local result = {}
    for key, val in pairs(tablelike) do
        result[key] = fn(val)
    end
    return result
end

--- @generic K, V, T
--- @param fn fun(key: K, val: V): T
--- @param tablelike table<K, V>
--- @return table<K, T>
function MapTable(fn, tablelike)
    local result = {}
    for key, val in pairs(tablelike) do
        result[key] = fn(key, val)
    end
    return result
end

--- @generic K, V
--- @param fn fun(key: K, val: V): boolean
--- @param tablelike table<K, V>
--- @return table<K, V>
function FilterTable(fn, tablelike)
    local result = {}
    for key, val in pairs(tablelike) do
        if fn(key, val) then
            result[key] = val
        end
    end
    return result
end

function NestedCompareTables(table1, table2)
    local keySet1 = ToSet(Keys(table1))
    local keySet2 = ToSet(Keys(table2))

    for e1, _ in pairs(keySet1) do
        if not keySet2[e1] then
            return false
        end
    end
    for e2, _ in pairs(keySet2) do
        if not keySet1[e2] then
            return false
        end
    end
    if IsList(table1) then
        for i, _ in ipairs(table1) do
            if table1[i] ~= table2[i] then
                return false
            end
        end
    else
        for key, val in pairs(table1) do
            if type(val) == "table" then
                if type(table2[key]) ~= "table" then
                    return false
                end
                if not NestedCompareTables(val, table2[key]) then
                    return false
                end
            else
                if val ~= table2[key] then
                    return false
                end
            end
        end
    end
    return true
end

function NestedVisitTable(table1, visitor, reducer)
    if IsList(table1) then
        local results = {}
        for i, _ in ipairs(table1) do
            table.insert(results, visitor(table1[i]))
        end
        return reducer(results)
    else
        local results = {}
        for key, val in pairs(table1) do
            if type(val) == "table" then
                return NestedVisitTable(val, visitor, reducer)
            else
                results[key] = visitor(val)
            end
        end
        return reducer(Values(results))
    end
end

--- @generic T
--- @param list T[]
--- @return table<T, boolean>
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

--- @generic T, V
--- @param t1 V[]
--- @param t2 T[]
--- @return (V | T)[] t2
function TableCombine(t1, t2)
    return table.move(t1, 1, #t1, #t2 + 1, t2)
end

function IndexOf(array, selector, value)
    for i, v in ipairs(array) do
        if selector(v) == value then
            return i
        end
    end
    return nil
end

function IsList(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

function ArrayToList(array)
    local list = {}
    for _, elem in pairs(array) do
        table.insert(list, elem)
    end
    return list
end

function Reverse(listlike)
    local result = DeepCopy(listlike)
    for i = 1, #listlike//2, 1 do
        result[i], result[#listlike-i+1] = listlike[#listlike-i+1], listlike[i]
    end
    return result
end

function Flatten(listOfLists)
    local flatterList = {}
    for _, list in pairs(listOfLists) do
        flatterList = TableCombine(list, flatterList)
    end
    return flatterList
end

--- @generic K, V
--- @param tab table<K, V>
--- @return V[]
function Values(tab)
    local list = {}
    for _, elem in pairs(tab) do
        table.insert(list, elem)
    end
    return list
end

--- @generic K, V
--- @param tab table<K, V>
--- @return K[]
function Keys(tab)
    local list = {}
    for key, _ in pairs(tab) do
        table.insert(list, key)
    end
    return list
end

--- @generic K, V
--- @param tab table<K, V>
--- @return table<V, K>
function InvertTable(tab)
    local newtab = {}
    for key, elem in pairs(tab) do
        newtab[elem] = key
    end
    return newtab
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

function J(any)
    local opts = {
        Beautify = true,
        StringifyInternalTypes = true,
        IterateUserdata = true,
        AvoidRecursion = true
    }
    return Ext.Json.Stringify(any, opts)
end

function CharacterGetStats(target)
    local entity = Ext.Entity.Get(target)
    local _, statName = pcall(function () return entity["ServerCharacter"]["Character"]["Template"]["Stats"] end)
    if statName ~= nil then
        return GetStatsChain(statName)
    else
        return {}
    end
end

--- @param statName string
--- @return string[]
function GetStatsChain(statName)
    local stats = {}
    local stat = Ext.Stats.Get(statName)
    while stat ~= nil do
        table.insert(stats, stat.Name)
        local _, nextStatName = pcall(function() return stat.Using end)
        if nextStatName ~= nil then
            stat = Ext.Stats.Get(nextStatName)
        else
            stat = nil
        end
    end
    return stats
end

--- @param boost Boost
--- @param candidateBoost BoostParams
--- @return boolean
function CompareBoost(boost, candidateBoost)
    if boost.BoostInfo.Cause.Cause ~= ModName then
        return false
    end

    if boost.BoostInfo.Params.Boost ~= candidateBoost.Boost then
        return false
    end

    if boost.BoostInfo.Params.Boost == "ActionResource" and candidateBoost.Boost == "ActionResource" then
        local paramsList = Split(boost.BoostInfo.Params.Params, ",")
        local candidateParamsList = Split(candidateBoost.Params, ",")
        if paramsList[1] ~= candidateParamsList[1] then
            return false
        end

        if paramsList[1] == "SpellSlot" then
            if paramsList[3] == candidateParamsList[3] then
                return true
            else
                return false
            end
        end
        return true
    end

    if boost.BoostInfo.Params.Boost == "Ability" and candidateBoost.Boost == "Ability" then
        local paramsList = Split(boost.BoostInfo.Params.Params, ",")
        local candidateParamsList = Split(candidateBoost.Params, ",")
        if paramsList[1] == candidateParamsList[1] then
            return true
        else
            return false
        end
    end

    if boost.BoostInfo.Params.Boost == "UnlockSpell" and candidateBoost.Boost == "UnlockSpell" then
        return boost.BoostInfo.Params.Params == candidateBoost.Params
    end

    return true
end

Restrictions = {
    Cambion = {
        Spell = {
            DamageType = {
                Exclusive = {
                    "Fire",
                },
            },
        },
    },
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
    HAG_AuntieEthel = {
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
    Imp = {
        Spell = {
            DamageType = {
                Exclusive = {
                    "Fire",
                },
            },
        },
    },
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
    TWN_Brewer_Imp_Acid = {
        Spell = {
            DamageType = {
                Exclusive = {
                    "Acid",
                },
            },
        },
    },
    TWN_Brewer_Imp_Cold = {
        Spell = {
            DamageType = {
                Exclusive = {
                    "Cold",
                },
            },
        },
    },
    TWN_Brewer_Imp_Fire = {
        Spell = {
            DamageType = {
                Exclusive = {
                    "Fire",
                },
            },
        },
    },
    TWN_Brewer_Imp_Lightning = {
        Spell = {
            DamageType = {
                Exclusive = {
                    "Lightning",
                },
            },
        },
    },
    TWN_Brewer_Imp_Poison = {
        Spell = {
            DamageType = {
                Exclusive = {
                    "Poison",
                },
            },
        },
    },
    _Devil = {},
    _Fiend = {},
    _Fey = {
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
    Cambion = {"Caster", "Fighter"},
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
    HAG_AuntieEthel = {"Druid", "Ranger"},
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
    Imp = {"Caster", "Fighter"},
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
    RedCap = {"Fighter"},
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
    TUT_CambionCommander = {"Fighter"},
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

--- @param sessionContext SessionContext
function _EntityToKinds(sessionContext, kinds, target)
    local stats = CharacterGetStats(target)
    for _, stat in ipairs(stats) do
        local overrideKinds = SafeGet(sessionContext.VarsJson, "Kinds", stat)
        if overrideKinds ~= nil then
            return ToSet(overrideKinds)
        end
        if kinds[stat] ~= nil then
            return ToSet(kinds[stat])
        end
    end
    return nil
end

--- @param sessionContext SessionContext
function _EntityToRestrictions(sessionContext, restrictions, target)
    local stats = CharacterGetStats(target)
    for _, stat in ipairs(stats) do
        local overrideRestrictions = SafeGet(sessionContext.VarsJson, "Restrictions", stat)
        if overrideRestrictions ~= nil then
            return overrideRestrictions
        end
        if restrictions[stat] ~= nil then
            return restrictions[stat]
        end
    end
    return nil
end

--- @param sessionContext SessionContext
function AllowedByRestrictions(sessionContext, restrictionsDefinition, restrictionType, candidate)
    local restrictions = restrictionsDefinition[restrictionType]
    if restrictions == nil then
        return true
    end
    local spellData = sessionContext.SpellData[candidate]
    if spellData == nil then
        sessionContext.LogI(2, 18, string.format("Spell %s not found in SpellData", candidate))
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
    if restrictions.DamageType ~= nil then
        local exclusiveDamageTypeRestrictions = restrictions.DamageType.Exclusive
        if exclusiveDamageTypeRestrictions == nil then
            return true
        end

        if exclusiveDamageTypeRestrictions == {} then
            -- No schools allowed
            return false
        end

        local allowed = false
        for _, exclusiveDamageTypeRestriction in ipairs(exclusiveDamageTypeRestrictions or {}) do
            if spellData.DamageType == exclusiveDamageTypeRestriction then
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

--- @param sessionContext SessionContext
--- @return table<Guid, table<string, Spell>>
--- @diagnostic disable-next-line: unused-local
function SpellListsToSpells(sessionContext)
    local allSpellLists = Ext.Definition.GetAll("SpellList")
    local spellListToSpells = {}

    for _, p in ipairs(allSpellLists) do
        spellListToSpells[p] = {}
        local spellList = Ext.Definition.Get(p, "SpellList")
        local spellsIterable = Ext.Types.Serialize(spellList.Spells)
        for _, spell in ipairs(spellsIterable) do
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

            local parsedRechargeValues = Split(spellData.RechargeValues, "-")
            --- @type Range | nil
            local rechargeValues
            if #parsedRechargeValues == 2 then
                rechargeValues = {
                    Min = tonumber(parsedRechargeValues[1]),
                    Max = tonumber(parsedRechargeValues[2]),
                }
            elseif #parsedRechargeValues == 1 then
                rechargeValues = {
                    Min = tonumber(parsedRechargeValues[1]),
                    Max = tonumber(parsedRechargeValues[1]),
                }
            else
                rechargeValues = nil
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
                DamageType = spellData.DamageType,
                RechargeValues = rechargeValues,
            }
        end
    end

    return spellListToSpells
end

--- @param sessionContext SessionContext
--- @diagnostic disable-next-line: unused-local
function PassiveListsToPassives(sessionContext)
    local allPassiveLists = Ext.Definition.GetAll("PassiveList")
    local passiveListToPassives = {}

    for _, p in ipairs(allPassiveLists) do
        local passiveList = Ext.Definition.Get(p, "PassiveList")
        passiveListToPassives[p] = Ext.Types.Serialize(passiveList.Passives)
    end

    return passiveListToPassives
end

--- @param sessionContext SessionContext
--- @return table<Guid, table<integer, Progression>>
function ProgressionsByTable(sessionContext)
    local spellListToSpells = SpellListsToSpells(sessionContext)
    local passiveListToPassives = PassiveListsToPassives(sessionContext)

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

--- @param sessionContext SessionContext
--- @return table<string, Class>
function FindRootClasses(sessionContext)
    local progressionsByTable = ProgressionsByTable(sessionContext)

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

--- @param sessionContext SessionContext
--- @return table<string, ClassSpells>
function GenerateSpellLists(sessionContext, blacklistedAbilitiesByClass, blacklistedAbilities, blaclistedLists, rootClasses)
    local classToSpellLists = {}
    for _, class in pairs(rootClasses) do
        local spells, spellsBySpellLevel, abilitiesByLevel = GenerateClassSpellLists(sessionContext, blacklistedAbilitiesByClass, blacklistedAbilities, blaclistedLists, class)
        classToSpellLists[class.Name] = {
            Spells = spells,
            SpellsBySpellLevel = spellsBySpellLevel,
            AbilitiesByLevel = abilitiesByLevel,
        }
    end
    return classToSpellLists
end

--- @param sessionContext SessionContext
--- @return table<string, ClassSpell>, table<string, string[]>, table<string, string[]>
--- @diagnostic disable-next-line: unused-local
function GenerateClassSpellLists(sessionContext, blacklistedAbilitiesByClass, blacklistedAbilities, blacklistedLists, class)
    local spells = {}
    for level, progression in pairs(class.Progression) do
        if not blacklistedAbilitiesByClass[progression.Name] then
            for _, selector in ipairs(progression.AddSpells) do
                for _, spell in pairs(selector.Spells) do
                    if not blacklistedAbilities[spell.Name] then
                        spells[spell.Name] = {
                            Spell = spell,
                            ClassLevel = level,
                        }
                    end
                end
            end
            for _, selector in ipairs(progression.SelectSpells) do
                for _, spell in pairs(selector.Spells) do
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
    for _, subclass in pairs(class.Subclasses) do
        if subclass.Progression == nil then
            sessionContext.LogI(2, 18, string.format("Subclass %s of class %s has no progression", subclass.Name, class.Name))
        else
            for level, progression in pairs(subclass.Progression) do
                if not blacklistedAbilitiesByClass[progression.Name] then
                    for _, selector in ipairs(progression.AddSpells) do
                        for _, spell in pairs(selector.Spells) do
                            if not blacklistedAbilities[spell.Name] then
                                spells[spell.Name] = {
                                    Spell = spell,
                                    ClassLevel = level,
                                }
                            end
                        end
                    end
                    for _, selector in ipairs(progression.SelectSpells) do
                        for _, spell in pairs(selector.Spells) do
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
    for _, levelSpells in pairs(spellsBySpellLevel) do
        table.sort(levelSpells)
    end
    for _, abilities in pairs(abiltiiesByLevel) do
        table.sort(abilities)
    end
    return spells, spellsBySpellLevel, abiltiiesByLevel
end

--- @param sessionContext SessionContext
--- @return table<string, ClassPassives>
function GeneratePassiveLists(sessionContext, blacklistedPassivesByClass, blacklistedPassives, blacklistedLists, rootClasses)
    local classToPassiveLists = {}
    for _, class in pairs(rootClasses) do
        local passives, passivesByLevel = GenerateClassPassiveLists(sessionContext, blacklistedPassivesByClass, blacklistedPassives, blacklistedLists, class)
        classToPassiveLists[class.Name] = {
            Passives = passives,
            PassivesByLevel = passivesByLevel,
        }
    end
    return classToPassiveLists
end

--- @param sessionContext SessionContext
--- @return table<string, boolean>, table<string, string[]>
--- @diagnostic disable-next-line: unused-local
function GenerateClassPassiveLists(sessionContext, blacklistedPassivesByClass, blacklistedPassives, blacklistedLists, class)
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
    for _, subclass in pairs(class.Subclasses) do
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
    for level, levelPassives in pairs(passivesByLevel) do
        local passivesList = Keys(levelPassives)
        table.sort(passivesList)
        passivesByLevelLists[level] = passivesList
    end

    return passives, passivesByLevelLists
end

--- @param sessionContext SessionContext
--- @return ItemLists
--- @diagnostic disable-next-line: unused-local
function GenerateItemLists(sessionContext)
    local itemsByUseType = {
        Consumable = {},
        Armor = {},
        Weapon = {},
    }
    for _, name in ipairs(Ext.Stats.GetStats("Object")) do
        local stat = Ext.Stats.Get(name)
        if stat ~= nil and stat.ItemUseType ~= nil and stat.RootTemplate ~= nil and stat.RootTemplate ~= "" then
            local useCosts = Split(stat.UseCosts, ";")
            local objectCategory = Split(stat.ObjectCategory, ";")
            local useConditions = stat.UseConditions

            if itemsByUseType["Consumable"][stat.ItemUseType] == nil then
                itemsByUseType["Consumable"][stat.ItemUseType] = {}
            end
            itemsByUseType["Consumable"][stat.ItemUseType][name] = {
                Name = name,
                Using = stat.Using,
                ItemUseType = stat.ItemUseType,
                UseCosts = useCosts,
                RootTemplate = stat.RootTemplate,
                ObjectCategory = objectCategory,
                UseConditions = useConditions,
            }
        end
    end
    for _, name in ipairs(Ext.Stats.GetStats("Armor")) do
        local stat = Ext.Stats.Get(name)
        if stat ~= nil and stat.Slot ~= nil and stat.RootTemplate ~= nil and stat.RootTemplate ~= "" then
            local boosts = Split(stat.Boosts, ";")
            local passivesOnEquip = Split(stat.PassivesOnEquip, ";")
            local statusOnEquip = Split(stat.StatusOnEquip, ";")

            if itemsByUseType["Armor"][stat.Slot] == nil then
                itemsByUseType["Armor"][stat.Slot] = {}
            end
            itemsByUseType["Armor"][stat.Slot][name] = {
                Name = name,
                Using = stat.Using,
                Slot = stat.Slot,
                Boosts = boosts,
                RootTemplate = stat.RootTemplate,
                PassivesOnEquip = passivesOnEquip,
                StatusOnEquip = statusOnEquip,
                Unique = stat.Unique,
                ProficiencyGroup = stat["Proficiency Group"],
            }
        end
    end
    for _, name in ipairs(Ext.Stats.GetStats("Weapon")) do
        local stat = Ext.Stats.Get(name)
        if stat ~= nil and stat.Slot ~= nil and stat.RootTemplate ~= nil and stat.RootTemplate ~= "" then
            local boosts = Split(stat.Boosts, ";")
            local boostsOnEquipMainHand = Split(stat.BoostsOnEquipMainHand, ";")
            local boostsOnEquipOffHand = Split(stat.BoostsOnEquipOffHand, ";")
            local defaultBoosts = Split(stat.DefaultBoosts, ";")
            local passivesOnEquip = Split(stat.PassivesOnEquip, ";")
            local statusOnEquip = Split(stat.StatusOnEquip, ";")
            local personalStatusImmunities = Split(stat.PersonalStatusImmunities, ";")
            local useConditions = stat.UseConditions
            -- stat.WeaponFunctors

            if itemsByUseType["Weapon"][stat.Slot] == nil then
                itemsByUseType["Weapon"][stat.Slot] = {}
            end
            itemsByUseType["Weapon"][stat.Slot][name] = {
                Name = name,
                Using = stat.Using,
                Slot = stat.Slot,
                Boosts = boosts,
                BoostsOnEquipMainHand = boostsOnEquipMainHand,
                BoostsOnEquipOffHand = boostsOnEquipOffHand,
                DefaultBoosts = defaultBoosts,
                RootTemplate = stat.RootTemplate,
                PassivesOnEquip = passivesOnEquip,
                StatusOnEquip = statusOnEquip,
                Unique = stat.Unique,
                ProficiencyGroup = stat["Proficiency Group"],
                UseConditions = useConditions,
                PersonalStatusImmunities = personalStatusImmunities,
                WeaponProperties = stat["Weapon Properties"],
                WeaponGroup = stat["Weapon Group"],
                DamageType = stat["Damage Type"],
            }
        end
    end
    return itemsByUseType
end

--- @param sessionContext SessionContext
function LevelGate(sessionContext, varSection, min, max, npcLevel, target, configType)
    local minLevels = {}
    local requiredLevelsChoices = {}
    local gates = GetVarComplex(sessionContext, varSection, "LevelGate", target, configType) or {}
    for i = min, max, 1 do
        local gateForLevel = SafeGet(gates, string.format("MinCharLevelForLevel%s", i))
        minLevels[i] = tonumber(gateForLevel or 13)

        local requireLevelAtLevel = {}
        for j = 0, i, 1 do
            table.insert(requireLevelAtLevel, j)
        end
        requiredLevelsChoices[i] = requireLevelAtLevel
    end

    local requiredLevels
    for i = max, min, -1 do
        if npcLevel >= minLevels[i] then
            requiredLevels = requiredLevelsChoices[i]
            break
        end
    end
    return requiredLevels or {}
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @param configType string
--- @return table<string, string>
function ComputeClassLevelAdditions(sessionContext, sourceTables, deps, var, presenceCheckFn, entity, configType)
    local shortGuid = entity.ShortGuid
    local toAdd = {}
    local requiredLevels = LevelGate(sessionContext, var, 1, 20, Osi.GetLevel(shortGuid), shortGuid, configType)

    sessionContext.LogI(7, 26, string.format("DBG: Required levels %s for %s", Ext.Json.Stringify(requiredLevels), shortGuid))
    local npcPresenceTable = {}
    for _, level in ipairs(requiredLevels) do
        local levels = sourceTables["Level" .. level]

        if levels then
            for _, addition in pairs(levels) do
                npcPresenceTable[addition] = presenceCheckFn(shortGuid, addition) == 0
            end
        end
    end
    sessionContext.LogI(7, 26, string.format("DBG: Found %s additions presence table for %s", Ext.Json.Stringify(npcPresenceTable), shortGuid))
    local npcTable = Keys(FilterTable(function(_, val) return val end, npcPresenceTable))
    table.sort(npcTable)

    sessionContext.LogI(7, 26, string.format("DBG: Found %s %s additions table for %s", #npcTable, Ext.Json.Stringify(npcTable), shortGuid))
--- @diagnostic disable-next-line: unused-vararg
    local lookupFn = function(range, ...)
        return Osi.Random(range)
    end

    if sessionContext.VarsJson["ConsistentHash"] and sessionContext.VarsJson["ConsistentHashSalt"] ~= nil then
        sessionContext.LogI(7, 26, string.format("DBG: Using consistent hash for %s wiht salt %s", shortGuid, sessionContext.VarsJson["ConsistentHashSalt"]))
        lookupFn = function(range, ...)
            local params = {...}
            return ConsistentHash(sessionContext.VarsJson["ConsistentHashSalt"], range, shortGuid, table.unpack(params))
        end
    end

    if #npcTable > 0 then
        local npcs = ComputeSimpleIncrementalBoost(sessionContext, var, entity, configType)
        for i = npcs, 1, -1 do
            local additionCandidate = nil
            local attempts = 1
            while attempts <= #npcTable and (additionCandidate == nil or toAdd[additionCandidate] ~= nil) do
                local rnd = lookupFn(#npcTable, string.format("addition_%s", i), string.format("attempts_%s", attempts)) + 1
                additionCandidate = npcTable[rnd]
                sessionContext.LogI(4, 26, string.format("Selected %s on %s with %s attempt %s", additionCandidate, shortGuid, rnd, attempts))
                attempts = attempts + 1
            end
            if additionCandidate ~= nil then
                toAdd[additionCandidate] = additionCandidate
            end
        end
    end

    local finalToAdd = {}
    for candidateName, candidateData in pairs(toAdd) do
        finalToAdd[candidateName] = candidateData
        for _, depCandidate in ipairs(deps[candidateName] or {}) do
            if toAdd[depCandidate] == nil and presenceCheckFn(shortGuid, depCandidate) == 0 then
                finalToAdd[depCandidate] = depCandidate
            end
        end
    end
    return finalToAdd
end


--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @return table<string, string[]>, integer
function PreparePassivesTables(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    local passiveTables = {}

    local kinds = entity.Kinds
    local allClasses = {}
    for kind, _ in pairs(kinds) do
        local classes = KindMapping[kind]
        allClasses = TableCombine(classes, allClasses)
    end
    sessionContext.LogI(7, 26, string.format("DBG: In passives Found classes %s for %s", Ext.Json.Stringify(allClasses), shortGuid))

    local combinedClassPassives = {}
    for _, class in ipairs(allClasses) do
        local classPassives = sessionContext.PassiveListsByClass[class].PassivesByLevel or {}
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
    sessionContext.LogI(7, 26, string.format("DBG: Found passives %s for %s", Ext.Json.Stringify(combinedClassPassives), shortGuid))
    local seenPassives = {}
    for level=1, 20, 1 do
        local combinedPassivesForLevel = combinedClassPassives["Level" .. level]
        if combinedPassivesForLevel ~= nil then
            for passive, _ in pairs(combinedPassivesForLevel) do
                if not seenPassives[passive] then
                    seenPassives[passive] = true
                else
                    combinedPassivesForLevel[passive] = nil
                end
            end
        end
    end
    sessionContext.LogI(7, 26, string.format("DBG: Found filtered passives %s for %s", Ext.Json.Stringify(combinedClassPassives), shortGuid))

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
    return passiveTables, passivesCount
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @param configType string
--- @return table<string, string>
function ComputeClassSpecificPassives(sessionContext, entity, configType)
    local passivesToAdd = {}
    local passiveTables, passivesCount = PreparePassivesTables(sessionContext, entity)

    if passivesCount == 0 then
        sessionContext.LogI(2, 18, "No passives available, please check config")
        return passivesToAdd
    end
    sessionContext.LogI(7, 26, string.format("DBG: Found passive tables %s for %s", Ext.Json.Stringify(passiveTables), entity.ShortGuid))

    return ComputeClassLevelAdditions(sessionContext, passiveTables, sessionContext.PassiveDependencies, "PassivesAdded", Osi.HasPassive, entity, configType)
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @return table<string, string[]>, integer
function PrepareAbilityTables(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    local abilityTables = {}

    local kinds = entity.Kinds
    local allClasses = {}
    for kind, _ in pairs(kinds) do
        local classes = KindMapping[kind]
        allClasses = TableCombine(classes, allClasses)
    end
    local restrictions = entity.Restrictions

    sessionContext.LogI(7, 26, string.format("DBG: In abilities Found classes %s for %s", Ext.Json.Stringify(allClasses), shortGuid))

    local combinedClassAbilities = {}
    for _, class in ipairs(allClasses) do
        local classPassives = sessionContext.SpellListsByClass[class].AbilitiesByLevel or {}
        if classPassives ~= nil then
            for level, abilities in pairs(classPassives) do
                if combinedClassAbilities[level] == nil then
                    combinedClassAbilities[level] = {}
                end
                for _, ability in ipairs(abilities) do

                    local allowedByRestrictions = AllowedByRestrictions(sessionContext, restrictions, "Ability", ability)
                    if allowedByRestrictions and not HasSpellThorough(sessionContext, shortGuid, ability) then
                        combinedClassAbilities[level][ability] = true
                    end
                end
            end
        end
    end
    sessionContext.LogI(7, 26, string.format("DBG: Found abilities %s for %s", Ext.Json.Stringify(combinedClassAbilities), shortGuid))

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
    return abilityTables, abilitiesCount
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @param configType string
--- @return table<string, string>
function ComputeClassSpecificAbilities(sessionContext, entity, configType)
    local shortGuid
    local abiltiesToAdd = {}
    local abilityTables, abilitiesCount = PrepareAbilityTables(sessionContext, entity)

    if abilitiesCount == 0 then
        sessionContext.LogI(2, 18, "No abilities available, please check config")
        return abiltiesToAdd
    end
    sessionContext.LogI(7, 26, string.format("DBG: Found ability tables %s for %s", Ext.Json.Stringify(abilityTables), shortGuid))

    return MapTableValues(
        function(abilityVal) return string.format("UnlockSpell(%s)", abilityVal) end,
        ComputeClassLevelAdditions(
            sessionContext,
            abilityTables,
            sessionContext.AbilityDependencies,
            "AbilitiesAdded",
            Osi.HasSpell,
            entity,
            configType
        )
    )
end

--- @param entity EnrichedEntity
--- @return boolean
function CheckIfOrigin(entity)
    local shortGuid = entity.ShortGuid
    local name = SafeGet(entity.Entity, "ServerCharacter", "Template", "Name")
    if name ~= nil then
        local fullGuid = string.format("%s_%s", name, shortGuid)
        for i=#ExcludedNPCs,1,-1 do
            if (ExcludedNPCs[i] == fullGuid) then
                return true
            end
        end
        return false
    else
        for i=#ExcludedNPCs,1,-1 do
            if (string.sub(ExcludedNPCs[i], -36) == shortGuid) then
                return true
            end
        end
        return false
    end
end

--- @param entity EnrichedEntity
--- @return boolean
function HasPlayerData(entity)
    -- TODO: Can remove Character after v13
    local playerData = SafeGet(entity.Entity, "ServerCharacter", "Character", "PlayerData")
    return playerData ~= nil
end

--- @param entity EnrichedEntity
--- @return boolean
function IsPlayer(entity)
    -- TODO: Can remove Character after v13
    local playerData = SafeGet(entity.Entity, "ServerCharacter", "Character", "IsPlayer")
    return playerData ~= nil and playerData
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

--- @param sessionContext SessionContext
function IsEnemiesEnhancedLoaded(sessionContext)
    local eeDisabled = sessionContext.VarsJson["DebugDisableEE"] or false
    return eeDisabled and Ext.Mod.IsModLoaded("7deea48e-8b9d-45e4-8685-5acfd0ce39ad")
end

function IsCriticalMissLoaded()
    return Ext.Mod.IsModLoaded("17c00eba-2727-474e-a914-652cc5f85b59")
end

ADDITIONAL_ENEMIES_GUID = "49a94025-c3e4-461f-bc08-2de6a629666c"

function IsAdditionalEnemiesLoaded()
    return Ext.Mod.IsModLoaded(ADDITIONAL_ENEMIES_GUID)
end

--- @param entity EnrichedEntity
--- @return boolean
function CheckIfParty(entity)
    if (Osi.IsPartyMember(entity.ShortGuid,1) == 1) then
        return true
    else return false
    end
end

--- @param entity EnrichedEntity
--- @return boolean
function CheckIfOurSummon(entity)
    local us = Ext.Entity.Get(entity.ShortGuid)["IsSummon"]
    if us ~= nil then
        return CheckIfParty(entity)
    end
    return false
end

--- @param guid Guid
--- @return string | nil
function UuidToLocalizedName(guid)
    local handle = Ext.Entity.UuidToHandle(guid)
    local localizedName = nil
    if handle ~= nil then
        localizedName = Ext.Loca.GetTranslatedString(handle.DisplayName.NameKey.Handle.Handle)
    end
    return localizedName
end

--- @param sessionContext SessionContext
function GetVar(sessionContext, var, guid, configType)
    local race = Osi.GetRace(guid, 0)
    local vars = sessionContext.VarsJson
    local localizedName = UuidToLocalizedName(guid)
    local specific = vars[guid] or (localizedName ~= nil and vars[localizedName]) or nil
    if specific ~= nil then
        local result = specific[var]
        if result ~= nil then
            sessionContext.LogI(8, 36, string.format("Found specific override for %s %s, applying", guid, var))
            return result
        end
    end
    local general = vars[configType]
    if general ~= nil then
        local raceResult = general[race]
        if raceResult ~= nil then
            local raceVarResult = raceResult[var]
            if raceVarResult ~= nil then
                sessionContext.LogI(8, 36, string.format("Found race override for %s %s, applying", guid, var))
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

--- @param sessionContext SessionContext
function GetVarComplex(sessionContext, topvar, var, guid, configType)
    local race = Osi.GetRace(guid, 0)
    local vars = sessionContext.VarsJson
    local localizedName = UuidToLocalizedName(guid)
    local specific = vars[guid] or (localizedName ~= nil and vars[localizedName]) or nil
    if specific ~= nil then
        local topresult = specific[topvar]
        if topresult ~= nil then
            local result = topresult[var]
            if result ~= nil then
                sessionContext.LogI(8, 36, string.format("Found specific override for %s %s %s, applying", guid, topvar, var))
                return result
            end
        end
    end
    local general = vars[configType]
    if general ~= nil then
        sessionContext.LogI(8, 36, string.format("Found settings for %s %s %s %s", configType, guid, topvar, var))
        local raceResult = general[race]
        if raceResult ~= nil then
            sessionContext.LogI(8, 36, string.format("Found race settings for %s %s %s %s %s", configType, race, guid, topvar, var))
            local topRaceVarResult = raceResult[topvar]
            if topRaceVarResult ~= nil then
                sessionContext.LogI(8, 36, string.format("Found topvar race settings for %s %s %s %s %s", configType, race, guid, topvar, var))
                local raceVarResult = topRaceVarResult[var]
                if raceVarResult ~= nil then
                    sessionContext.LogI(8, 36, string.format("Found race override for %s %s %s, applying", guid, topvar, var))
                    return raceVarResult
                end
            end
        end
        local topresult = general[topvar]
        if topresult ~= nil then
            sessionContext.LogI(8, 36, string.format("Found topvar settings for %s %s %s %s", configType, guid, topvar, var))
            local result = topresult[var]
            if result ~= nil then
                sessionContext.LogI(8, 36, string.format("Found %s override for %s %s %s, applying", configType, guid, topvar, var))
                return result
            end
        end
    end
    sessionContext.LogI(8, 36, string.format("Found no override for %s %s %s, applying default", configType, guid, topvar, var))
    return Defaults[topvar][var]
end

function AddBoostsAdv(target, val)
    Osi.AddBoosts(target, val, ModName, ModName)
end

function FormatBoost(boostEntity)
    local params = {}
    if boostEntity.BoostInfo.Params.Params ~= "" then
        table.insert(params, boostEntity.BoostInfo.Params.Params)
    end
    if boostEntity.BoostInfo.Params.Params2 ~= "" then
        table.insert(params, boostEntity.BoostInfo.Params.Params2)
    end
    return string.format("%s(%s)", boostEntity.BoostInfo.Params.Boost, table.concat(params, ","))
end

--- @diagnostic disable-next-line: unused-local
function RemoveBoostsAdv(sessionContext, target, boostEntity)
    if boostEntity.BoostInfo.Cause.Cause == ModName then
        local boost = FormatBoost(boostEntity)
        Osi.RemoveBoosts(target, boost, 0, ModName, ModName)
    end
end

--- @param sessionContext SessionContext
function PrepareSpellBookRoots(sessionContext, target)
    local spellRoots = {}
    local entity = Ext.Entity.Get(target)
    local spells = SafeGet(entity, "SpellBook", "Spells")

    if spells == nil then
        return false
    end

    for _, derivedSpell in pairs(spells) do
        local prototype = SafeGet(derivedSpell, "Id", "Prototype")
        local using = prototype

        while using ~= nil do
            local spellData = Ext.Stats.Get(using)


            if spellData.RootSpellID ~= nil and spellData.RootSpellID ~= "" then
                sessionContext.LogI(6, 32, string.format("Found entity spell rootId to cache of %s of parent %s on %s", spellData.RootSpellID, using, target))
                spellRoots[spellData.RootSpellID] = true
                using = nil
            else
                using = spellData.Using
            end
        end
    end
    sessionContext.EntityCache[target].SpellRoots = spellRoots
end

--- @param sessionContext SessionContext
function HasSpellThorough(sessionContext, target, spell)
    if Osi.HasSpell(target, spell) == 1 then
        return true
    end

    sessionContext.LogI(5, 30, string.format("Has Spell Thorough Check spellbook root cache for spell %s on %s", spell, target))

    if sessionContext.EntityCache[target][spell] then
        sessionContext.LogI(6, 30, string.format("Has Spell Thorough Check found spellbook root cache for spell %s on %s", spell, target))
        return true
    end
    return false
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfCaster(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if caster on %s", shortGuid))
    local eeCaster = (
        Osi.HasPassive(shortGuid, "EE_Cantrips_Type_1") == 1 or
        Osi.HasPassive(shortGuid, "EE_Cantrips_Type_2") == 1 or
        Osi.HasPassive(shortGuid, "EE_Spells_Level_1") == 1 or
        Osi.HasPassive(shortGuid, "EE_Spells_Level_2") == 1 or
        Osi.HasPassive(shortGuid, "EE_Spells_Level_3") == 1 or
        Osi.HasPassive(shortGuid, "EE_Spells_Level_4") == 1 or
        Osi.HasPassive(shortGuid, "EE_Spells_Level_5") == 1 or
        Osi.HasPassive(shortGuid, "EE_Spells_Level_6") == 1
    )
    function CheckArchetype()
        sessionContext.LogI(3, 26, string.format("Peforming mage archetype check %s", shortGuid))
        local casterTypes = {
            mage = true,
            mage_SCL = true,
            mage_no_inventory_items = true,
            mage_smart = true,
            goblin_mage = true,
            monk_mage = true,
        }
        local combatComponent = SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent")
        return casterTypes[SafeGet(combatComponent, "Archetype")] ~= nil
    end
    local kinds = entity.Kinds
    return (
        (
            kinds ~= nil and kinds["Caster"] ~= nil
        ) or
        (IsEnemiesEnhancedLoaded(sessionContext) and eeCaster) or
        (sessionContext.VarsJson["CasterArchetypeCheck"] and CheckArchetype())
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @return boolean
function GuessIfCanCast(sessionContext, entity)
    return (
        GuessIfCaster(sessionContext, entity) or
        GuessIfDruid(sessionContext, entity) or
        GuessIfCleric(sessionContext, entity) or
        GuessIfBard(sessionContext, entity) or
        GuessIfWarlock(sessionContext, entity) or
        GuessIfRanger(sessionContext, entity) or
        GuessIfPaladin(sessionContext, entity)
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfBarbarian(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if barbarian on %s", shortGuid))
    local barbarianTypes = {
    }
    local kinds = entity.Kinds
    return (
        (kinds ~= nil and kinds["Barbarian"] ~= nil) or
        (
            sessionContext.VarsJson["BarbarianArchetypeCheck"] and
            barbarianTypes[SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        ) or
        (IsEnemiesEnhancedLoaded(sessionContext) and Osi.HasPassive(shortGuid, "EE_Barbarian_Boost") == 1)
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfFighter(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if fighter on %s", shortGuid))
    local fighterTypes = {
        melee = true,
    }
    local kinds = entity.Kinds
    return (
        (
            kinds ~= nil and kinds["Fighter"] ~= nil
        ) or
        (
            sessionContext.VarsJson["FighterArchetypeCheck"] and
            fighterTypes[SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        ) or
        (IsEnemiesEnhancedLoaded(sessionContext) and Osi.HasPassive(shortGuid, "EE_Fighter_Boost") == 1)
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfHealer(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if healer on %s", shortGuid))
    local healerTypes = {
        healer_melee = true,
        healer_ranged = true,
        melee_healer = true,
    }
    return (
        sessionContext.VarsJson["HealerArchetypeCheck"] and
        healerTypes[SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfCleric(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if cleric on %s", shortGuid))
    local clericTypes = {
    }
    local kinds = entity.Kinds
    return (
        (
            kinds ~= nil and kinds["Cleric"] ~= nil
        ) or
        (
            sessionContext.VarsJson["ClericArchetypeCheck"] and
            clericTypes[SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfBard(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if bard on %s", shortGuid))
    local bardTypes = {
    }
    local kinds = entity.Kinds
    return (
        (
            kinds ~= nil and kinds["Bard"] ~= nil
        ) or
        (
            sessionContext.VarsJson["BardArchetypeCheck"] and
            bardTypes[SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfPaladin(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if paladin on %s", shortGuid))
    local paladinTypes = {
    }
    local kinds = entity.Kinds
    return (
        (
            kinds ~= nil and kinds["Paladin"] ~= nil
        ) or
        (
            sessionContext.VarsJson["PaladinArchetypeCheck"] and
            paladinTypes[SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfDruid(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if druid on %s", shortGuid))
    local druidTypes = {
    }
    local kinds = entity.Kinds
    return (
        (
            kinds ~= nil and kinds["Druid"] ~= nil
        ) or
        (
            sessionContext.VarsJson["DruidArchetypeCheck"] and
            druidTypes[SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfMonk(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if monk on %s", shortGuid))
    local monkTypes = {
        monk_melee = true,
        monk_ranged = true,
    }
    local kinds = entity.Kinds
    return (
        (
            kinds ~= nil and kinds["Monk"] ~= nil
        ) or
        (
            sessionContext.VarsJson["MonkArchetypeCheck"] and
            monkTypes[SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        ) or
        Osi.HasPassive(shortGuid, "PsychicStrikes_Githyanki") == 1
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfRogue(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if rogue on %s", shortGuid))
    local rogueTypes = {
    }
    local kinds = entity.Kinds
    return (
        (
            kinds ~= nil and kinds["Rogue"] ~= nil
        ) or
        (
            sessionContext.VarsJson["RogueArchetypeCheck"] and
            rogueTypes[SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfRanger(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if ranger on %s", shortGuid))
    local rogueTypes = {
    }
    local kinds = entity.Kinds
    return (
        (
            kinds ~= nil and kinds["Ranger"] ~= nil
        ) or
        (
            sessionContext.VarsJson["RangerArchetypeCheck"] and
            rogueTypes[SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function GuessIfWarlock(sessionContext, entity)
    local shortGuid = entity.ShortGuid
    sessionContext.LogI(3, 22, string.format("Guessing if warlock on %s", shortGuid))
    local warlockTypes = {
    }
    local kinds = entity.Kinds
    return (
        (
            kinds ~= nil and kinds["Warlock"] ~= nil
        ) or
        (
            sessionContext.VarsJson["WarlockArchetypeCheck"] and
            warlockTypes[SafeGet(entity.Entity, "ServerCharacter", "Character", "Template", "CombatComponent", "Archetype")] ~= nil
        )
    )
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @param configType string
--- @return table<string, string>
function ComputeNewSpells(sessionContext, entity, configType)
    local selectedSpells = {}

    local shortGuid = entity.ShortGuid
    local npcLevel = tonumber(Osi.GetLevel(shortGuid))
    local spellCastingAbility = entity.Entity.Stats.SpellCastingAbility

    local spellTables = {}

    local kinds = entity.Kinds
    local allClasses = {}
    for kind, _ in pairs(kinds) do
        local classes = KindMapping[kind]
        allClasses = TableCombine(classes, allClasses)
    end

    local restrictions = entity.Restrictions

    local combinedClassSpells = {}
    for _, class in ipairs(allClasses) do
        local classSpells = sessionContext.SpellListsByClass[class].SpellsBySpellLevel or {}
        if classSpells ~= nil then
            for level, spells in pairs(classSpells) do
                if combinedClassSpells[level] == nil then
                    combinedClassSpells[level] = {}
                end
                for _, spell in ipairs(spells) do
                    local allowedByRestrictions = AllowedByRestrictions(sessionContext, restrictions, "Spell", spell)
                    if allowedByRestrictions and not HasSpellThorough(sessionContext, shortGuid, spell) then
                        combinedClassSpells[level][spell] = true
                    end
                end
            end
        end
    end

    sessionContext.LogI(7, 26, string.format("DBG: Found spells %s for %s", Ext.Json.Stringify(combinedClassSpells), shortGuid))
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
    sessionContext.LogI(7, 26, string.format("DBG: Found spell tables %s for %s", Ext.Json.Stringify(spellTables), shortGuid))

    if spellsCount == 0 then
        sessionContext.LogI(2, 18, "No spell available, please check config")
        return selectedSpells
    end

--- @diagnostic disable-next-line: unused-vararg
    local lookupFn = function(range, ...)
        return Osi.Random(range)
    end

    if sessionContext.VarsJson["ConsistentHash"] and sessionContext.VarsJson["ConsistentHashSalt"] ~= nil then
        lookupFn = function(range, ...)
            local params = {...}
            return ConsistentHash(sessionContext.VarsJson["ConsistentHashSalt"], range, shortGuid, table.unpack(params))
        end
    end

    local requiredSpellLevels = LevelGate(sessionContext, "SpellsAdded", 0, 9, npcLevel, shortGuid, configType)
    local npcSpells = ComputeSimpleIncrementalBoost(sessionContext, "SpellsAdded", entity, configType)

    table.sort(requiredSpellLevels, function (l, r) return l > r end)

    for _, level in ipairs(requiredSpellLevels) do
        local levelName = SpellLevelToName[level + 1]
        local levelSpells = spellTables[levelName]
        if levelSpells ~= nil then
            for i = npcSpells, 1, -1 do
                local spellCandidate = nil
                local attempts = 1
                while attempts <= #levelSpells and (spellCandidate == nil or selectedSpells[spellCandidate] ~= nil) do
                    local rnd = lookupFn(#levelSpells, string.format("spell_%s", i), string.format("attempts_%s", attempts)) + 1
                    spellCandidate = levelSpells[rnd]
                    sessionContext.LogI(4, 26, string.format("Selected spell %s on %s with %s attempt %s", spellCandidate, shortGuid, rnd, attempts))
                    attempts = attempts + 1
                end
                if spellCandidate ~= nil then
                    selectedSpells[spellCandidate] = spellCandidate
                end
            end
            npcSpells = npcSpells + 1
        end
    end

    local finalSelectedSpells = {}
    for spellName, spellData in pairs(selectedSpells) do
        finalSelectedSpells[spellName] = spellData
        for _, depSpell in ipairs(sessionContext.AbilityDependencies[spellName] or {}) do
            if selectedSpells[depSpell] == nil and not HasSpellThorough(sessionContext, shortGuid, depSpell) then
                finalSelectedSpells[depSpell] = depSpell
            end
        end
    end
    return MapTableValues(function(spellVal) return string.format("UnlockSpell(%s,,%s,,%s)", spellVal, sessionContext.ActionResources["SpellSlot"], spellCastingAbility) end, finalSelectedSpells)
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeActionPointBoost(sessionContext, entity, configType)
    local shortGuid = entity.ShortGuid
    local actionPointBoost = ComputeSimpleIncrementalBoost(sessionContext, "ActionPointBoosts", entity, configType)
    if (Osi.HasPassive(shortGuid, "Boost_Action") and IsEnemiesEnhancedLoaded(sessionContext)) and actionPointBoost > 0 then
        actionPointBoost = actionPointBoost - 1
    end

    if Osi.HasPassive(shortGuid, "ExtraAttack") and GetVar(sessionContext, "ConservativeActionPointBoosts", shortGuid, configType) and actionPointBoost > 0 then
        actionPointBoost = actionPointBoost - 1
    end
    if actionPointBoost > 0 then
        return "ActionResource(ActionPoint," .. tonumber(actionPointBoost) .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeBonusActionPointBoost(sessionContext, entity, configType)
    local shortGuid = entity.ShortGuid
    local bonusActionPointBoost = ComputeSimpleIncrementalBoost(sessionContext, "BonusActionPointBoosts", entity, configType)
    if (Osi.HasPassive(shortGuid, "Boost_BonusAction") and IsEnemiesEnhancedLoaded(sessionContext)) and bonusActionPointBoost > 2 then
        bonusActionPointBoost = bonusActionPointBoost - 1
    end

    if bonusActionPointBoost > 0 then
        return "ActionResource(BonusActionPoint," .. tonumber(bonusActionPointBoost) .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeRageBoost(sessionContext, entity, configType)
    if (
        not GuessIfBarbarian(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Rage, couldnt guess if target is barbarian")
        return nil
    end

    local rageBoost = ComputeSimpleIncrementalBoost(sessionContext, "RageBoosts", entity, configType)
    if rageBoost > 0 then
        return "ActionResource(Rage," .. rageBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeSorceryPointBoost(sessionContext, entity, configType)
    if (
        not GuessIfCaster(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Sorcery Points, couldnt guess if target is caster")
        return nil
    end

    local sorcerPointBoost = ComputeSimpleIncrementalBoost(sessionContext, "SorceryPointBoosts", entity, configType)
    if sorcerPointBoost > 0 then
        return "ActionResource(SorceryPoint," .. sorcerPointBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeTidesOfChaosBoost(sessionContext, entity, configType)
    if (
        not GuessIfCaster(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Tides Of Chaos, couldnt guess if target is caster")
        return nil
    end

    local tidesOfChaosBoost = ComputeSimpleIncrementalBoost(sessionContext, "TidesOfChaosBoosts", entity, configType)
    if tidesOfChaosBoost > 0 then
        return "ActionResource(TidesOfChaos," .. tidesOfChaosBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeSuperiorityDieBoost(sessionContext, entity, configType)
    if (
        not GuessIfFighter(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Superiority Die, couldnt guess if target is fighter")
        return nil
    end

    local superiorityDieBoost = ComputeSimpleIncrementalBoost(sessionContext, "SuperiorityDieBoosts", entity, configType)
    if superiorityDieBoost > 0 then
        return "ActionResource(SuperiorityDie," .. superiorityDieBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeWildShapeBoost(sessionContext, entity, configType)
    if (
        not GuessIfDruid(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Wild Shape, couldnt guess if target is druid")
        return nil
    end

    local wildShapeBoost = ComputeSimpleIncrementalBoost(sessionContext, "WildShapeBoosts", entity, configType)
    if wildShapeBoost > 0 then
        return "ActionResource(WildShape," .. wildShapeBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeNaturalRecoveryBoost(sessionContext, entity, configType)
    if (
        not GuessIfDruid(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Natural Recovery, couldnt guess if target is druid")
        return nil
    end

    local naturalRecoveryBoost = ComputeSimpleIncrementalBoost(sessionContext, "NaturalRecoveryBoosts", entity, configType)
    if naturalRecoveryBoost > 0 then
        return "ActionResource(NaturalRecoveryPoint," .. naturalRecoveryBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeFungalInfestationBoost(sessionContext, entity, configType)
    if (
        not GuessIfDruid(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Fungal Infestation, couldnt guess if target is druid")
        return nil
    end

    local fungalInfestationBoost = ComputeSimpleIncrementalBoost(sessionContext, "FungalInfestationBoosts", entity, configType)
    if fungalInfestationBoost > 0 then
        return "ActionResource(FungalInfestationCharge," .. fungalInfestationBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeLayOnHandsBoost(sessionContext, entity, configType)
    if (
        not GuessIfPaladin(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Lay On Hands, couldnt guess if target is paladin")
        return nil
    end

    local layOnHandsBoost = ComputeSimpleIncrementalBoost(sessionContext, "LayOnHandsBoosts", entity, configType)
    if layOnHandsBoost > 0 then
        return "ActionResource(LayOnHandsCharge," .. layOnHandsBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeChannelOathBoost(sessionContext, entity, configType)
    if (
        not GuessIfPaladin(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Channel Oath, couldnt guess if target is paladin")
        return nil
    end

    local channelOathBoost = ComputeSimpleIncrementalBoost(sessionContext, "ChannelOathBoosts", entity, configType)
    if channelOathBoost > 0 then
        return "ActionResource(ChannelOath," .. channelOathBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeChannelDivinityBoost(sessionContext, entity, configType)
    if (
        not GuessIfCleric(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Channel Divinity, couldnt guess if target is cleric")
        return nil
    end

    local channelDivinityBoost = ComputeSimpleIncrementalBoost(sessionContext, "ChannelDivinityBoosts", entity, configType)
    if channelDivinityBoost > 0 then
        return "ActionResource(ChannelDivinity," .. channelDivinityBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeBardicInspirationBoost(sessionContext, entity, configType)
    if (
        not GuessIfBard(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Bardic Inspiration, couldnt guess if target is bard")
        return nil
    end

    local bardicInspirationBoost = ComputeSimpleIncrementalBoost(sessionContext, "BardicInspirationBoosts", entity, configType)
    if bardicInspirationBoost > 0 then
        return "ActionResource(BardicInspiration," .. bardicInspirationBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeKiPointBoost(sessionContext, entity, configType)
    if (
        not GuessIfMonk(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Ki Point, couldnt guess if target is monk")
        return nil
    end

    local kiPointBoost = ComputeSimpleIncrementalBoost(sessionContext, "KiPointBoosts", entity, configType)
    if kiPointBoost > 0 then
        return "ActionResource(KiPoint," .. kiPointBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeDeflectMissilesBoost(sessionContext, entity, configType)
    if (
        not GuessIfMonk(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Deflect Missiles, couldnt guess if target is monk")
        return nil
    end

    local deflectMissilesBoost = ComputeSimpleIncrementalBoost(sessionContext, "DeflectMissilesBoosts", entity, configType)
    if deflectMissilesBoost > 0 then
        return "ActionResource(DeflectMissiles_Charge," .. deflectMissilesBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeSneakAttackBoost(sessionContext, entity, configType)
    if (
        not GuessIfRogue(sessionContext, entity)
    ) then
        sessionContext.LogI(2, 22, "Computing Sneak Attack, couldnt guess if target is rogue")
        return nil
    end

    local sneakAttackChargeBoost = ComputeSimpleIncrementalBoost(sessionContext, "SneakAttackBoosts", entity, configType)
    if sneakAttackChargeBoost > 0 then
        return "ActionResource(SneakAttack_Charge," .. sneakAttackChargeBoost .. ",0)"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeHealthIncrease(sessionContext, entity, configType)
    local hpincrease = ComputeIncrementalBoost(sessionContext, "Health", entity, configType)

    if hpincrease > 0 then
        return "IncreaseMaxHP(" .. hpincrease .. ")"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeSimpleIncrementalBoost(sessionContext, stat, entity, configType)
    local shortGuid = entity.ShortGuid
    local levelMultiplier = Osi.GetLevel(shortGuid)

    local staticBoost = tonumber(GetVarComplex(sessionContext, stat, "StaticBoost", shortGuid, configType))
    local levelIncrement = tonumber(GetVarComplex(sessionContext, stat, "LevelStepToIncrementOn", shortGuid, configType))
    local scalingLevelIncrement = tonumber(GetVarComplex(sessionContext, stat, "ValueToIncrementByOnLevel", shortGuid, configType))
    local scalingLevelBoost = scalingLevelIncrement * math.floor(levelMultiplier / levelIncrement)

    local totalBoost = staticBoost + scalingLevelBoost
    sessionContext.LogI(4, 8, string.format("%s Increase for %s: %s", stat, shortGuid, totalBoost))
    return totalBoost
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeIncrementalBoost(sessionContext, stat, entity, configType)
    local shortGuid = entity.ShortGuid
    local levelMultiplier = Osi.GetLevel(shortGuid)
    local statValueFns = {
        Strength = function() return Osi.GetAbility(shortGuid, "Strength") end,
        Dexterity = function() return Osi.GetAbility(shortGuid, "Dexterity") end,
        Constitution = function() return Osi.GetAbility(shortGuid, "Constitution") end,
        Wisdom = function() return Osi.GetAbility(shortGuid, "Wisdom") end,
        Intelligence = function() return Osi.GetAbility(shortGuid, "Intelligence") end,
        Charisma = function() return Osi.GetAbility(shortGuid, "Charisma") end,
        AC = function() return entity.Entity.Health.AC end,
        Health = function() return entity.Entity.Health.MaxHp end,
        Movement = function()
            local resourceGuid = sessionContext.ActionResources["Movement"]
            local movementActionResource = entity.Entity.ActionResources.Resources[resourceGuid]
            if movementActionResource ~= nil and #movementActionResource > 0 then
                return movementActionResource[1].MaxAmount
            else
                return nil
            end
        end,
        RollBonusAttack = function() return nil end,
        RollBonusMeleeWeaponAttack = function() return nil end,
        RollBonusRangedWeaponAttack = function() return nil end,
        RollBonusMeleeSpellAttack = function() return nil end,
        RollBonusRangedSpellAttack = function() return nil end,
        RollBonusMeleeUnarmedAttack = function() return nil end,
        RollBonusRangedUnarmedAttack = function() return nil end,
        RollBonusSavingThrow = function() return nil end,
        SpellSaveDC = function() return nil end,
        Damage = function() return nil end,
        Initiative = function() return entity.Entity.Stats.InitiativeBonus end,
    }
    local statValueFn = statValueFns[stat]

    local statValue
    if statValueFn ~= nil then
        statValue = statValueFn()
    else
        statValue = nil
    end

    local maxPercentage = tonumber(GetVarComplex(sessionContext, stat, "MaxPercentage", shortGuid, configType))
    local scalingPercentage = tonumber(GetVarComplex(sessionContext, stat, "ScalingPercentage", shortGuid, configType))

    local staticBoost = tonumber(GetVarComplex(sessionContext, stat, "StaticBoost", shortGuid, configType))
    local levelIncrement = tonumber(GetVarComplex(sessionContext, stat, "LevelStepToIncrementOn", shortGuid, configType))
    local levelIncrementScaling = tonumber(GetVarComplex(sessionContext, stat, "ScalingLevelStepToIncrementOn", shortGuid, configType))
    local scalingLevelIncrement = tonumber(GetVarComplex(sessionContext, stat, "ValueToIncrementByOnLevel", shortGuid, configType))
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
    sessionContext.LogI(4, 8, string.format("%s Increase for %s: %s", stat, shortGuid, totalBoost))
    return totalBoost
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeInitiativeBoost(sessionContext, entity, configType)
    local totalInitiativeBoost = ComputeIncrementalBoost(sessionContext, "Initiative", entity, configType)
    if totalInitiativeBoost > 0 then
        return "Initiative(" .. totalInitiativeBoost .. ")"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeMovementBoost(sessionContext, entity, configType)
    local totalMovementBoost = ComputeIncrementalBoost(sessionContext, "Movement", entity, configType)
    if totalMovementBoost > 0 then
        return "ActionResource(Movement," .. totalMovementBoost .. ",0)"
    else
        return nil
    end
end


--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeACBoost(sessionContext, entity, configType)
    local totalACBoost = ComputeIncrementalBoost(sessionContext, "AC", entity, configType)
    if totalACBoost > 0 then
        return "AC(" .. totalACBoost .. ")"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeStrengthBoost(sessionContext, entity, configType)
    local totalStrengthBoost = ComputeIncrementalBoost(sessionContext, "Strength", entity, configType)
    if totalStrengthBoost > 0 then
        return "Ability(Strength,+" .. totalStrengthBoost .. ")"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeDexterityBoost(sessionContext, entity, configType)
    local totalDexterityBoost = ComputeIncrementalBoost(sessionContext, "Dexterity", entity, configType)
    if totalDexterityBoost > 0 then
        return "Ability(Dexterity,+" .. totalDexterityBoost .. ")"
    else
        return nil
    end
end


--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeConstitutionBoost(sessionContext, entity, configType)
    local totalConstitutionBoost = ComputeIncrementalBoost(sessionContext, "Constitution", entity, configType)
    if totalConstitutionBoost > 0 then
        return "Ability(Constitution,+" .. totalConstitutionBoost .. ")"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeIntelligenceBoost(sessionContext, entity, configType)
    local totalIntelligenceBoost = ComputeIncrementalBoost(sessionContext, "Intelligence", entity, configType)
    if totalIntelligenceBoost > 0 then
        return "Ability(Intelligence,+" .. totalIntelligenceBoost .. ")"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeWisdomBoost(sessionContext, entity, configType)
    local totalWisdomBoost = ComputeIncrementalBoost(sessionContext, "Wisdom", entity, configType)
    if totalWisdomBoost > 0 then
        return "Ability(Wisdom,+" .. totalWisdomBoost .. ")"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeCharismaBoost(sessionContext, entity, configType)
    local totalCharismaBoost = ComputeIncrementalBoost(sessionContext, "Charisma", entity, configType)
    if totalCharismaBoost > 0 then
        return "Ability(Charisma,+" .. totalCharismaBoost .. ")"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeRollBonusAttackBoost(sessionContext, entity, configType)
    local attackTypes = {
        MeleeWeaponAttack = {
            Melee = true,
        },
        RangedWeaponAttack = {
            Ranged = true,
        },
        MeleeSpellAttack = {
            Caster = true,
        },
        RangedSpellAttack = {
            Caster = true,
        },
        MeleeUnarmedAttack = {
            Unarmed = true
        },
        RangedUnarmedAttack = {
            Unarmed = true
        },
    }

    local isCaster = GuessIfCanCast(sessionContext, entity)
    local isMelee = (
        GuessIfBarbarian(sessionContext, entity) or
        GuessIfFighter(sessionContext, entity) or
        GuessIfPaladin(sessionContext, entity) or
        GuessIfRanger(sessionContext, entity) or
        GuessIfRogue(sessionContext, entity) or
        GuessIfDruid(sessionContext, entity)
    )
    local isRanged = (
        GuessIfRanger(sessionContext, entity) or
        GuessIfRogue(sessionContext, entity) or
        GuessIfFighter(sessionContext, entity)
    )
    local isUnarmed = (
        GuessIfMonk(sessionContext, entity) or
        GuessIfDruid(sessionContext, entity)
    )

    local nonSpecificAttackTypes = {"Attack"}
    --- @type string[]
    local specificAttackTypes = {}
    for attackType, checkAttackType in pairs(attackTypes) do
        if (
            (checkAttackType.Melee and isMelee) or
            (checkAttackType.Ranged and isRanged) or
            (checkAttackType.Caster and isCaster) or
            (checkAttackType.Unarmed and isUnarmed)
        ) then
            table.insert(specificAttackTypes, attackType)
        end
    end

    local computeAttackTypeBoosts = function(chosenAttackTypes)
        return Filter(
            function(boostVal)
                return boostVal ~= nil
            end,
            Map(
                function(attackType)
                    sessionContext.LogI(4, 10, string.format("RollBonusAttack Increase for %s: %s", entity.ShortGuid, attackType))
                    return ComputeRollBonusBoost(sessionContext, attackType, entity, configType)
                end,
                chosenAttackTypes
            )
        )
    end

    local specificBoosts = computeAttackTypeBoosts(specificAttackTypes)

    local stackAttackRolls = GetVar(sessionContext, "SpecificAttackRollsStack", entity.ShortGuid, configType)
    if (#specificBoosts > 0 and stackAttackRolls ~= nil and stackAttackRolls) or #specificBoosts == 0 then
        local nonSpecificBoosts = computeAttackTypeBoosts(nonSpecificAttackTypes)
        specificBoosts = TableCombine(nonSpecificBoosts, specificBoosts)
    end
    return specificBoosts
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeRollBonusSavingThrowBoost(sessionContext, entity, configType)
    return ComputeRollBonusBoost(sessionContext, "SavingThrow", entity, configType)
end

--- @param sessionContext SessionContext
--- @param rollType string
--- @param entity EnrichedEntity
function ComputeRollBonusBoost(sessionContext, rollType, entity, configType)
    local totalRollBonus = ComputeIncrementalBoost(sessionContext, string.format("RollBonus%s", rollType), entity, configType)
    if totalRollBonus > 0 then
        return "RollBonus(".. rollType .. "," .. totalRollBonus .. ")"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeSpellSaveDCBoost(sessionContext, entity, configType)
    local totalRollBonus = ComputeIncrementalBoost(sessionContext, "SpellSaveDC", entity, configType)
    if totalRollBonus > 0 then
        return "SpellSaveDC(" .. totalRollBonus .. ")"
    else
        return nil
    end
end


--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeDamageBoost(sessionContext, entity, configType)
    local totalDamageBoost = ComputeIncrementalBoost(sessionContext, "Damage", entity, configType)
    if totalDamageBoost > 0 then
        return "DamageBonus(" .. totalDamageBoost .. ")"
    else
        return nil
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
function ComputeSpellSlotBoosts(sessionContext, entity, configType)
    local shortGuid = entity.ShortGuid
    local slots = {}
    if (
        not (
            GuessIfCanCast(sessionContext, entity)
        )
    ) then
        sessionContext.LogI(2, 22, "Computing Spell Slot, couldnt guess if target needs spell slots")
        return slots
    end

    local spellSlotBoost = ComputeSimpleIncrementalBoost(sessionContext, "SpellSlotBoosts", entity, configType)

    local npcLevel = tonumber(Osi.GetLevel(shortGuid))
    local requiredSpellLevels = LevelGate(sessionContext, "SpellsAdded", 1, 9, npcLevel, shortGuid, configType)

    table.sort(requiredSpellLevels, function (l, r) return l > r end)

    for _, level in ipairs(requiredSpellLevels) do
        sessionContext.LogI(4, 10, string.format("SpellSlotBoost Increase for %s: %s at level %s", shortGuid, spellSlotBoost, level))

        if spellSlotBoost > 0 then
            slots[level] = "ActionResource(SpellSlot," .. spellSlotBoost .. "," .. level .. ")"
        end

        spellSlotBoost = spellSlotBoost + 1
    end
    return slots
end

--- @param sessionContext SessionContext
function CalculateLists(sessionContext)
    local overrideBlacklistedAbilities= sessionContext.VarsJson["BlacklistedAbilities"]
    local overrideBlacklistedPassives = sessionContext.VarsJson["BlacklistedPassives"]
    local overrideBlacklistedAbilitiesByClass = sessionContext.VarsJson["BlacklistedAbilitiesByClass"]
    local overrideBlacklistedPassivesByClass = sessionContext.VarsJson["BlacklistedPassivesByClass"]
    local overrideBlacklistedLists = sessionContext.VarsJson["BlacklistedLists"]
    local overrideAbilityDependencies = sessionContext.VarsJson["AbilityDependencies"]
    local overridePassiveDependencies = sessionContext.VarsJson["PassiveDependencies"]

    local blacklistedAbilitiesByClass
    local blacklistedPassivesByClass
    local blacklistedAbilities
    local blacklistedPassives
    local blacklistedLists
    local abilityDependencies
    local passiveDependencies

    if overrideBlacklistedAbilitiesByClass ~= nil and overrideBlacklistedAbilitiesByClass ~= {} then
        blacklistedAbilitiesByClass = overrideBlacklistedAbilitiesByClass
    else
        blacklistedAbilitiesByClass = BlacklistedAbilitiesByClass
    end

    if overrideBlacklistedPassivesByClass ~= nil and overrideBlacklistedPassivesByClass ~= {} then
        blacklistedPassivesByClass = overrideBlacklistedPassivesByClass
    else
        blacklistedPassivesByClass = BlacklistedPassivesByClass
    end

    if overrideBlacklistedAbilities ~= nil and overrideBlacklistedAbilities ~= {} then
        blacklistedAbilities = overrideBlacklistedAbilities
    else
        blacklistedAbilities = BlacklistedAbilities
    end

    if overrideBlacklistedPassives ~= nil and overrideBlacklistedPassives ~= {} then
        blacklistedPassives = overrideBlacklistedPassives
    else
        blacklistedPassives = BlacklistedPassives
    end

    if overrideBlacklistedLists ~= nil and overrideBlacklistedLists ~= {} then
        blacklistedLists = overrideBlacklistedLists
    else
        blacklistedLists = BlacklistedLists
    end

    if overrideAbilityDependencies ~= nil and overrideAbilityDependencies ~= {} then
        abilityDependencies = overrideAbilityDependencies
    else
        abilityDependencies = AbilityDependencies
    end

    if overridePassiveDependencies ~= nil and overridePassiveDependencies ~= {} then
        passiveDependencies = overridePassiveDependencies
    else
        passiveDependencies = PassiveDependencies
    end

    sessionContext.SpellListsByClass = GenerateSpellLists(sessionContext, blacklistedAbilitiesByClass, blacklistedAbilities, blacklistedLists, FindRootClasses(sessionContext))
    sessionContext.PassiveListsByClass = GeneratePassiveLists(sessionContext, blacklistedPassivesByClass, blacklistedPassives, blacklistedLists, FindRootClasses(sessionContext))

    sessionContext.SpellData = {}
    for _, spells in pairs(sessionContext.SpellListsByClass) do
        for spellName, classSpell in pairs(spells.Spells) do
            sessionContext.SpellData[spellName] = classSpell.Spell
        end
    end

    sessionContext.ItemLists  = GenerateItemLists(sessionContext)
    sessionContext.AbilityDependencies = abilityDependencies
    sessionContext.PassiveDependencies = passiveDependencies
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
    EchoAvatar = true, -- TODO: never adds, goes infinite
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

ProtectedPassives = {}

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

AbilityDependencies = {
    Target_Jump = {
        "Projectile_Jump",
    },
}

PassiveDependencies = {
}

--- @param sessionContext SessionContext
function _Log(sessionContext, level, str)
    if (tonumber(sessionContext.VarsJson["Verbosity"]) or 0) >= level then
        print(string.format("%s: %s", ModName, str))
    end
end

--- @param sessionContext SessionContext
function _LogI(sessionContext, level, indent, str)
    local spaces = string.rep(" ", indent)
    _Log(sessionContext, level, string.format("%s%s", spaces, str))
end

--- @type EntityConfig
Defaults = {
    -- Makes Action Point boosting more conservative when boosting a character with ExtraAttack to prevent insanity
    ConservativeActionPointBoosts = true,
    -- When calculating class sepcific RollBonus Attack, also  add the default Attack. This will cause it to stack with other RollBonus Attack boosts.
    SpecificAttackRollsStack = true,
    -- Controls How many max level spells will be added. Scales with level if wanted. Each lower level added will have 1 more spell, incrementally.
    SpellsAdded = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
        -- Controls the minimum level the character must be to get spells of the specified level
        LevelGate = {
            MinCharLevelForLevel0 = 13,
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
    -- Controls How many class specific passives will be added. Scales with level if wanted
    PassivesAdded = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
        -- Controls the minimum level the character must be to get class specific passives of the specified level
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
        -- Controls the minimum level the character must be to get class specific abiltiies (isSpell = False) of the specified level
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
    -- Controls How many max spell slots will be added (to caster likes). Scales with level if wanted. Each lower level added will have 1 more spell slot, incrementally.
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
    -- Controls How many rage charges will be added (to barbarians). Scales with level if wanted
    RageBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many sorcery points will be added (to casters). Scales with level if wanted
    SorceryPointBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many tides of chaos will be added (to casters). Scales with level if wanted
    TidesOfChaosBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many superiority die will be added (to fighters). Scales with level if wanted
    SuperiorityDieBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many wild shape charges will be added (to druids). Scales with level if wanted
    WildShapeBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many natural recovery points will be added (to druids). Scales with level if wanted
    NaturalRecoveryBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many fungal infestation charges will be added (to druids). Scales with level if wanted
    FungalInfestationBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many lay on hands charges will be added (to paladins). Scales with level if wanted
    LayOnHandsBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many channel oath charges will be added (to paladins). Scales with level if wanted
    ChannelOathBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many channel divinty charges will be added (to clerics). Scales with level if wanted
    ChannelDivinityBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many ki points will be added (to monks). Scales with level if wanted
    KiPointBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many deflect missiles charges will be added (to monks). Scales with level if wanted
    DeflectMissilesBoosts = {
        StaticBoost = 0,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls How many sneak attack charges will be added (to rogues). Scales with level if wanted
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
    RollBonusAttack = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much bonus to give to the characters melee weapon hit dice rolls. Scales with level if wanted, additionally can scale with base bonus
    RollBonusMeleeWeaponAttack = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much bonus to give to the characters ranged weapon hit dice rolls. Scales with level if wanted, additionally can scale with base bonus
    RollBonusRangedWeaponAttack = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much bonus to give to the characters melee spell hit dice rolls. Scales with level if wanted, additionally can scale with base bonus
    RollBonusMeleeSpellAttack = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much bonus to give to the characters ranged spell hit dice rolls. Scales with level if wanted, additionally can scale with base bonus
    RollBonusRangedSpellAttack = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much bonus to give to the characters melee unarmed hit dice rolls. Scales with level if wanted, additionally can scale with base bonus
    RollBonusMeleeUnarmedAttack = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much bonus to give to the characters ranged unarmed hit dice rolls. Scales with level if wanted, additionally can scale with base bonus
    RollBonusRangedUnarmedAttack = {
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
    -- Controls how much bonus to give to the characters saving throw dice rolls. Scales with level if wanted, additionally can scale with base bonus
    RollBonusSavingThrow = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much bonus to give to the characters spell save dc. Scales with level if wanted, additionally can scale with base bonus
    SpellSaveDC = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
    -- Controls how much initiative bonus to give to the characters. Scales with level if wanted, additionally can scale with base bonus
    Initiative = {
        StaticBoost = 0,
        MaxPercentage = 0,
        ScalingPercentage = 0,
        ScalingLevelStepToIncrementOn = 1,
        LevelStepToIncrementOn = 1,
        ValueToIncrementByOnLevel = 0,
    },
}

--- @param sessionContext SessionContext
function ResetConfigJson(sessionContext)
    sessionContext.ConfigFailed = 0
    --- @type Config
    local defaultConfig = {
        -- The following control whether we are allowing the mod to affect these types
        -- Bog Standard Enemies
        EnemiesEnabled = false,
        -- Enemies Classified as Bosses
        BossesEnabled = false,
        -- Characters that are Allied with us
        AlliesEnabled = false,
        -- Characters that are following us
        FollowersEnabled = false,
        -- Characters that are following us that are Classified as Bosses
        FollowersBossesEnabled = false,
        -- Characters that we have summoned
        SummonsEnabled = false,
        CasterArchetypeCheck = true,
        HealerArchetypeCheck = true,
        FighterArchetypeCheck = true,
        MonkArchetypeCheck = true,
        RogueArchetypeCheck = true,
        RangerArchetypeCheck = true,
        WarlockArchetypeCheck = true,
        ClericArchetypeCheck = true,
        DruidArchetypeCheck = true,
        BarbarianArchetypeCheck = true,
        BardArchetypeCheck = true,
        PaladinArchetypeCheck = true,
        -- This changes the selection function from random to a consistent hash based on primarilly the target guid
        -- - Note that disabling this will cause some strange behaviour in the mod due to reloading the enemy state on game load. Use at your own risk
        ConsistentHash = true,
        -- Integer that allows the salt for the consistent hash to be modified to allow for different results
        ConsistentHashSalt = 0,
        -- Disables detection of EnhancedEnemies mod and its Passives for Lore inference when set to `1`
        DebugDisableEE = false,
        -- Controls the verbosity of logging for debugging
        Verbosity = 0,
        DebugMode = {
            Enabled = false,
            AddSpells = false,
            MovementSpeedMultiplier = 1,
        },
        -- Allows overriding the inferred classes or kinds of characters by inspecting their `stats` chain
        Kinds = {
            Dragonborn_Cleric = {"Cleric"},
        },
        -- Allows overriding the types of abilities / spells given to inferred classes or kinds of characters by inspecting their `stats` chain
        Restrictions = {
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
        },
        BlacklistedAbilities = {},
        BlacklistedPassives = {},
        BlacklistedAbilitiesByClass = {},
        BlacklistedPassivesByClass = {},
        BlacklistedLists = {},
        AbilityDependencies = {},
        PassiveDependencies = {},
        -- The following configures the boosts that will be fallan back to during inheritance if
        -- no inherits block is configured
        Defaults = Defaults,
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
        --- @diagnostic disable-next-line: missing-fields
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
        AvoidRecursion = false,
    }
    Ext.IO.SaveFile(string.format("%s.json", ModName), Ext.Json.Stringify(defaultConfig, opts))
    GetVarsJson(sessionContext)
end

function ComputeConfigHash(sessionContext)
    local opts = {
        Beautify = false,
        StringifyInternalTypes = true,
        IterateUserdata = true,
        AvoidRecursion = false,
    }
    local stringifiedConfig = Ext.Json.Stringify(FilterTable(function(k, _) return k ~= "DebugMode" and k ~= "Verbosity" end, sessionContext.VarsJson), opts)
    return ConsistentHash(CONFIG_HASH_SALT, #stringifiedConfig * 256, stringifiedConfig)
end

--- @param sessionContext SessionContext
--- @return Config
function PopulateInherits(sessionContext)
    local originalConfig = sessionContext.VarsJson

    if originalConfig["Defaults"] ~= nil and originalConfig["Defaults"]["Inherits"] ~= nil then
        sessionContext.Log(0, "Defaults should not \"Inherits\" from  anything. Please remove \"Defaults > Inherits\" key. Ignoring for now.")
        originalConfig["Defaults"]["Inherits"] = nil
    end

    local legalConfigs = ToSet({"Enemies", "Bosses", "Allies", "Followers", "FollowersBosses", "Summons"})

    for config, _ in pairs(legalConfigs) do
        local seen = {config = true}
        local targetConfig = SafeGet(originalConfig, config)
        while targetConfig ~= nil do
            local inherits = SafeGet(targetConfig, "Inherits")
            if inherits ~= nil then
                local inheritsTargetConfig = SafeGet(originalConfig, inherits)
                if legalConfigs[inherits] == nil and inherits == "Defaults" then
                    sessionContext.Log(0, string.format("Please do not directly \"Inherits\" Defaults. Ignoring. Found in %s", inherits, config))
                elseif legalConfigs[inherits] == nil then
                    sessionContext.Log(0, string.format("Illegal inheritance value for %s in %s", inherits, config))
                    return originalConfig
                end
                if seen[inherits] then
                    sessionContext.Log(0, string.format("Inheritance loop detected for %s in %s", inherits, config))
                    return originalConfig
                end
                if inheritsTargetConfig == nil then
                    sessionContext.Log(0, string.format("Inheritance target %s not found for %s", inherits, config))
                    return originalConfig
                end
                seen[inherits] = true
                targetConfig = inheritsTargetConfig
            end
            targetConfig = nil
        end
    end

    local newConfig = {}
    for key, value in pairs(originalConfig) do
        if legalConfigs[key] == nil then
            newConfig[key] = DeepCopy(value)
        else
            local targetConfig = value
            local configOrder = {key}
            while targetConfig ~= nil do
                local inherits = targetConfig["Inherits"]
                if inherits ~= nil then
                    table.insert(configOrder, inherits)
                    targetConfig = originalConfig[inherits]
                elseif key ~= "Defaults" and inherits == nil then
                    table.insert(configOrder, "Defaults")
                    targetConfig = nil
                else
                    targetConfig = nil
                end
            end
            local bottomUpOrder = Reverse(configOrder)
            local mergedConfig = {}
            local accumConfig = {}
            for _, config in ipairs(bottomUpOrder) do
                local bottomUpTargetConfig =  originalConfig[config] or {}
                for bkey, bval in pairs(bottomUpTargetConfig) do
                    if mergedConfig[bkey] == nil then
                        mergedConfig[bkey] = DeepCopy(bval)
                    end
                end
                for okey, oval in pairs(value) do
                    mergedConfig[okey] = DeepCopy(oval)
                end
                accumConfig[key] = DeepCopy(mergedConfig)
            end
            for akey, avalue in pairs(accumConfig) do
                newConfig[akey] = avalue
            end
        end
    end

    return newConfig
end

--- @param sessionContext SessionContext
function GetVarsJson(sessionContext)
    local configStr = Ext.IO.LoadFile(string.format("%s.json", ModName))
    if (configStr == nil) then
        sessionContext.Log(0, "Creating configuration file.")
        ResetConfigJson(sessionContext)
        return
    end
    local varsJson = Ext.Json.Parse(configStr)
    if varsJson["ConsistentHash"] ~= nil and varsJson["ConsistentHash"] and varsJson["ConsistentHashSalt"] == nil then
        varsJson["ConsistentHashSalt"] = Ext.Math.Random()
    end
    sessionContext.Log(1, string.format("Json Loaded %s\n", Ext.Json.Stringify(varsJson)))
    sessionContext.VarsJson = varsJson
    sessionContext.VarsJson = PopulateInherits(sessionContext)
    sessionContext.Log(1, string.format("Inherits Populated %s\n", Ext.Json.Stringify(sessionContext.VarsJson)))

    -- Updated Closed Over Vars that need Config Vars here
    sessionContext.EntityToKinds = function(target) return _EntityToKinds(sessionContext, Kinds, target) end
    sessionContext.EntityToRestrictions = function(target) return _EntityToRestrictions(sessionContext, Restrictions, target) end

    CalculateLists(sessionContext)
    local newDebugMode = SafeGetWithDefault(false, SessionContext.VarsJson, "DebugMode", "Enabled")
    if  newDebugMode then
        for _, guid in ipairs(Flatten(Osi.DB_PartyMembers:Get(nil))) do
            DebugMode(SessionContext, guid)
        end
    else
        for _, guid in ipairs(Flatten(Osi.DB_PartyMembers:Get(nil))) do
            UnDebugMode(SessionContext, guid)
        end
    end
    sessionContext.ConfigHash = ComputeConfigHash(sessionContext)
    sessionContext.Log(1, string.format("Config Hash %s\n", sessionContext.ConfigHash))
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @param configType string
--- @return table<string, string>
function GiveNewPassives(sessionContext, entity, configType)
    local passives = ComputeClassSpecificPassives(sessionContext, entity, configType)
    for _, passive in pairs(passives) do
        sessionContext.LogI(3, 24, string.format("Adding passive %s to %s", passive, entity.ShortGuid))
        Osi.AddPassive(entity.ShortGuid, passive)
    end
    entity.Entity.Vars.LCC_PassivesAdded = passives
    return passives
end

--- @param boostFn fun(sessionContext: SessionContext, entity: EnrichedEntity, configType: string) : string[] | string | nil
--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @param configType string
--- @return string[]
function ComputedBoost(boostFn, sessionContext, entity, configType)
    local boostRes = boostFn(sessionContext, entity, configType)

    if boostRes ~= nil then
        local boosts = nil

        if type(boostRes) ~= "table" then
            boosts = {boostRes}
        else
            boosts = boostRes
        end

        return boosts
    end
    return {}
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @param configType string
function GiveBoosts(sessionContext, entity, configType)
    sessionContext.LogI(1, 4, string.format("%s applying for Guid: %s\n", configType, entity.ShortGuid))

    GiveNewPassives(sessionContext, entity, configType)

    --- @type string[]
    local allBoosts = {}
    allBoosts = TableCombine(Values(ComputeNewSpells(sessionContext, entity, configType)), allBoosts)

    allBoosts = TableCombine(Values(ComputeClassSpecificAbilities(sessionContext, entity, configType)), allBoosts)

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
        ComputeRollBonusAttackBoost,
        ComputeDamageBoost,
        ComputeSpellSlotBoosts,
        ComputeRollBonusSavingThrowBoost,
        ComputeSpellSaveDCBoost,
        ComputeInitiativeBoost,
    }

    for _, boostFn in ipairs(boosts) do
        allBoosts = TableCombine(ComputedBoost(boostFn, sessionContext, entity, configType), allBoosts)
    end

    for _, boost in ipairs(allBoosts) do
        sessionContext.LogI(3, 24, string.format("Adding boost %s to %s", boost, entity.ShortGuid))
        AddBoostsAdv(entity.ShortGuid, boost)
    end

    entity.Entity.Vars.LCC_Boosted = {General = true}
    entity.Entity.Vars.LCC_BoostedWithHash = {Hash = sessionContext.ConfigHash}
    entity.Entity.Vars.LCC_BoostedWithClassification = {Classification = configType}
    entity.Entity.Vars.LCC_BoostsAdded = allBoosts
end


---@param sessionContext SessionContext
---@param entity EnrichedEntity
function PerformBoosting(sessionContext, entity)
    entity:Refresh(sessionContext)

    local shortGuid = entity.ShortGuid

    sessionContext.Log(1, string.format("Give: Guid: %s", shortGuid))

    local isCharacter = entity.IsCharacter
    if not isCharacter then
        sessionContext.Log(4, string.format("Give: Skipping non character: Guid: %s", shortGuid))
        return
    end

    if entity.Entity.Vars.LCC_Boosted == nil then
        entity.Entity.Vars.LCC_Boosted = {
            General = false,
        }
    end
    if entity.Entity.Vars.LCC_BoostedWithHash == nil then
        entity.Entity.Vars.LCC_BoostedWithHash = {
            Hash = nil,
        }
    end

    local isPartyMember = entity.IsPartyMember
    local isPartyFollower = entity.IsPartyFollower
    local isOurSummon = entity.IsOurSummon
    local isEnemy = entity.IsEnemy
    local isOrigin = entity.IsOrigin
    local isBoss = entity.IsBoss
    local hasPlayerData = entity.HasPlayerData
    local isPlayer = entity.IsPlayer
    local alreadyModified = entity.AlreadyModified
    local sameHash = entity.SameHash
    local rawAIHint = entity.RawAIHint
    local mappedAIHint = entity.MappedAIHint
    local rawArchetype = entity.RawArchetype
    local kinds = entity.Kinds
    local allClasses = entity.AllClasses
    local restrictions = entity.Restrictions
    local statsChain = entity.StatsChain
    -- Special case check, AdditionalEnemies mod adds certain enemies that are marked boss but not hostile for some reason
    local isAdditionalEnemiesSpecialBoss = entity.IsAdditionalEnemiesSpecialBoss

    sessionContext.Log(1, string.format("Give: Guid: %s; Modified?: %s; Party?: %s; Follower?: %s; Enemy?: %s; Origin?: %s; Boss?: %s; OurSummon?: %s; HasPlayerData?: %s; IsPlayer?: %s; isAdditionalEnemiesSpecialBoss?: %s; sameHash?: %s\n", shortGuid, alreadyModified, isPartyMember, isPartyFollower, isEnemy, isOrigin, isBoss, isOurSummon, hasPlayerData, isPlayer, isAdditionalEnemiesSpecialBoss, sameHash))

    if not isPartyMember and not isPartyFollower and not isOurSummon and not isEnemy and not isOrigin and not isBoss then
        local res, component = pcall(function() return entity.Entity.ServerCharacter end)
        if not res and component == nil then
            sessionContext.Log(4, string.format("Give: Skipping degenerate character: Guid: %s", shortGuid))
            return
        end
    end

    if isPartyMember and not isPartyFollower and not isOurSummon and not isEnemy then
        sessionContext.Log(4, string.format("Give: Skipping explicit party member: Guid: %s", shortGuid))
        return
    end

    if isPlayer or hasPlayerData then
        sessionContext.Log(4, string.format("Give: Skipping playerlike(isPlayer %s, hasPlayerData %s): Guid: %s", isPlayer, hasPlayerData, shortGuid))
        return
    end

    if alreadyModified and not sameHash then
        sessionContext.Log(0, string.format("Give: Skipping because something went wrong its already boosted but with a different hash: Guid: %s", shortGuid))
        return
    end

    if sessionContext.EntityCache == nil then
        sessionContext.EntityCache = {}
    end

    sessionContext.EntityCache[shortGuid] = {
        SpellRoots = {},
    }

    PrepareSpellBookRoots(sessionContext, shortGuid)

    sessionContext.Log(2, string.format("Give: AiHint: %s (%s) Archetype: %s\n", rawAIHint, mappedAIHint, rawArchetype))
    sessionContext.Log(2, string.format("Give: Kinds: %s; Classes: %s; Restrictions %s; StatsChain: %s\n", Ext.Json.Stringify(kinds), Ext.Json.Stringify(allClasses), Ext.Json.Stringify(restrictions), Ext.Json.Stringify(statsChain)))

    local shouldTryToModify = not alreadyModified and not sameHash
    local classification = entity:GetConfigClassification(sessionContext)

    if shouldTryToModify and classification ~= nil then
        GiveBoosts(sessionContext, entity, classification)
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @param force boolean
function RemoveBoosts(sessionContext, entity, force)
    local guid = string.sub(entity.Entity.Uuid.EntityUuid, -36)
    local modified = entity.Entity.Vars.LCC_Boosted.General
    if force or modified then
        sessionContext.Log(2, string.format("Removing Boosts for Guid: %s because User Variable set", guid))
        sessionContext.Log(3, string.format("Our Boosts: %s", J(OurBoosts(guid))))
        for _, boostEntities in pairs(entity.Entity.BoostsContainer.Boosts) do
            for _, boostEntity in ipairs(boostEntities) do
                RemoveBoostsAdv(sessionContext, guid, boostEntity)
            end
        end
        entity.Entity.Vars.LCC_BoostsAdded = {}
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @param combat table<Guid, boolean> | nil
--- @param force boolean
function RemovePassives(sessionContext, entity, combat, force)
    local guid = string.sub(entity.Entity.Uuid.EntityUuid, -36)
    local modified = entity.Entity.Vars.LCC_Boosted.General
    if force or (modified and (combat == nil or (combat ~= nil and combat[guid]))) then
        sessionContext.Log(2, string.format("Removing Passives for Guid: %s because combatants %s", guid, combat))
        sessionContext.Log(3, string.format("Passives: %s", Ext.Json.Stringify(Map(function (p) return p.Passive.PassiveId end, entity.Entity.PassiveContainer.Passives))))
        local ourPassives = Keys(entity.Entity.Vars.LCC_PassivesAdded)
        for _, passive in ipairs(ourPassives) do
            sessionContext.Log(3, string.format("Removing Passive: %s from %s", passive, guid))
            Osi.RemovePassive(guid, passive)
        end
        entity.Entity.Vars.LCC_PassivesAdded = {}
    end
end

--- @param sessionContext SessionContext
--- @param entity EnrichedEntity
--- @param force boolean
function RemoveAllFromEntity(sessionContext, entity, force)
    if entity.Entity.Vars.LCC_Boosted == nil then
        entity.Entity.Vars.LCC_Boosted = {
            General = false,
        }
    end
    if entity.Entity.Vars.LCC_BoostedWithHash == nil then
        entity.Entity.Vars.LCC_BoostedWithHash = {
            Hash = nil,
        }
    end

    local shortGuid = string.sub(entity.Entity.Uuid.EntityUuid, -36)
    sessionContext.Log(2, string.format("Removing All(%s) for Guid: %s", force, shortGuid))

    sessionContext.Log(3, string.format("Removing boost(%s) for Guid: %s", force, shortGuid))
    RemoveBoosts(sessionContext, entity, force)

    sessionContext.Log(3, string.format("Removing passives(%s) for Guid: %s", force, shortGuid))
    RemovePassives(sessionContext, entity, nil, force)

    sessionContext.EntityCache[string.sub(entity.Entity.Uuid.EntityUuid, -36)] = nil
    entity.Entity.Vars.LCC_Boosted = {General = false}
    entity.Entity.Vars.LCC_BoostedWithHash = {Hash = nil}
    entity.Entity.Vars.LCC_BoostedWithClassification = {Classification = nil}
end

--- @param sessionContext SessionContext
--- @param entities EnrichedEntity[]
--- @diagnostic disable-next-line: unused-local
function SetupUserVars(sessionContext, entities)
    for _, entity in ipairs(entities) do
        if entity.Entity.Vars.LCC_Boosted == nil then
            entity.Entity.Vars.LCC_Boosted = {
                General = false,
            }
        end
        if entity.Entity.Vars.LCC_BoostedWithHash == nil then
            entity.Entity.Vars.LCC_BoostedWithHash = {
                Hash = nil,
            }
        end
        if entity.Entity.Vars.LCC_BoostedWithClassification == nil then
            entity.Entity.Vars.LCC_BoostedWithClassification = {
                Classification = nil,
            }
        end
        if entity.Entity.Vars.LCC_PassivesAdded == nil then
            entity.Entity.Vars.LCC_PassivesAdded = {}
        end
        if entity.Entity.Vars.LCC_BoostsAdded == nil then
            entity.Entity.Vars.LCC_BoostsAdded = {}
        end
    end
end

--- @param sessionContext SessionContext
--- @param entities EnrichedEntity[]
--- @param force boolean
--- @return EnrichedEntity[], EnrichedEntity[], EnrichedEntity[]
function RemoveBoostingMany(sessionContext, entities, force)
    sessionContext.Log(1, "Attempting Removing Many Boosting")

    local affectedEntities = {}
    local unAffectedEntities = {}
    local unBoostedEntities = {}
    for _, entity in ipairs(entities) do
        local generallyBoosted = entity.Entity.Vars.LCC_Boosted.General
        local hashMismatch = entity.Entity.Vars.LCC_BoostedWithHash.Hash ~= SessionContext.ConfigHash
        local classificationMismatch = entity.Entity.Vars.LCC_BoostedWithClassification.Classification ~= entity:GetConfigClassification(sessionContext)
        if force or generallyBoosted then
            sessionContext.Log(2, string.format("Attempting Removing Boosts for Guid: %s because generally boosted or forced", entity.ShortGuid))
            if (
                force or
                hashMismatch or
                classificationMismatch
            ) then
                sessionContext.Log(
                    3,
                    string.format(
                        "Removing Boosts for Guid: %s because hash mismatch(%s, %s, %s) or classification mismatch(%s, %s, %s)",
                        entity.ShortGuid,
                        hashMismatch,
                        entity.Entity.Vars.LCC_BoostedWithHash.Hash,
                        SessionContext.ConfigHash,
                        classificationMismatch,
                        entity.Entity.Vars.LCC_BoostedWithClassification.Classification,
                        entity:GetConfigClassification(sessionContext)
                    )
                )
                RemoveAllFromEntity(sessionContext, entity, force)
                table.insert(affectedEntities, entity)
            else
                table.insert(unAffectedEntities, entity)
            end
        else
            table.insert(unBoostedEntities, entity)
        end
    end
    return affectedEntities, unAffectedEntities, unBoostedEntities
end

--- @param sessionContext SessionContext
--- @param entities EnrichedEntity[]
--- @return boolean
function WaitRemoveBoostingMany(sessionContext, entities)
    sessionContext.Log(
        3,
        string.format(
            "Waiting for all boosts to be gone on: %s entities (%s)",
            #entities,
            J(Map(function(entity) return entity.ShortGuid end, entities))
        )
    )
    local allGone = true
    for _, entity in ipairs(entities) do
        local boosts = OurBoosts(nil, entity.Entity)
        sessionContext.Log(3, string.format("Waiting for all boosts to be gone: %s %s %s", entity.Entity.Uuid.EntityUuid, #boosts, allGone))
        if #boosts > 0 then
            allGone = false
            break
        end
    end
    return allGone
end

--- @param sessionContext SessionContext
--- @param entities EnrichedEntity[]
function PerformBoostingMany(sessionContext, entities)
    sessionContext.Log(1, string.format("Performing Many Boosting: %s", J(Map(function(entity) return entity.ShortGuid end, entities))))

    for _, entity in ipairs(entities) do
        PerformBoosting(sessionContext, entity)
    end
end

--- @param sessionContext SessionContext
--- @param entities Entity[]
--- @param onlyCharacters boolean
--- @return EnrichedEntity[]
function EnrichEntities(sessionContext, entities, onlyCharacters)
    local enriched = Map(
        function(entity)
            --- @type EnrichedEntity
            local ee = EnrichedEntity:New()
            return ee:EnrichEntity(sessionContext, entity)
        end,
        Filter(
            function(entity)
                return entity ~= nil
            end,
            entities
        )
    )
    if onlyCharacters then
        return Filter(
            function(entity)
                return entity.IsCharacter
            end,
            enriched
        )
    else
        return enriched
    end
end

--- @param entity Entity
--- @return string | nil
function GetEntityName(entity)
    if entity.ServerCharacter ~= nil then
        -- Remove on v13
        if entity.ServerCharacter.Character ~= nil then
            return entity.ServerCharacter.Character.Template.Name
        end
        if entity.ServerCharacter.Template ~= nil then
            return entity.ServerCharacter.Template.Name
        end
    end
    if entity.ServerItem ~= nil then
        return entity.ServerItem.Template.Name
    end
    return nil
end

--- @class EnrichedEntity
EnrichedEntity = {}

--- @param sessionContext SessionContext
--- @param entity Entity
--- @return EnrichedEntity
function EnrichedEntity:EnrichEntity(sessionContext, entity)
    local guid = entity.Uuid.EntityUuid
    local shortGuid = string.sub(guid, -36)
    local entityName = GetEntityName(entity)
    local fullGuid
    if entityName ~= nil then
        fullGuid = string.format("%s_%s", entityName, shortGuid)
    else
        fullGuid = string.format("%s", shortGuid)
    end

    self.Entity = entity

    SetupUserVars(sessionContext, {self})

    self.Guid = guid
    self.ShortGuid = shortGuid
    self.FullGuid = fullGuid

    local isCharacter = Osi.IsCharacter(guid) == 1
    local isPartyFollower = Osi.IsPartyFollower(guid) == 1
    local isEnemy = Osi.IsEnemy(guid, Osi.GetHostCharacter()) == 1
    local isBoss = Osi.IsBoss(guid) == 1

    local isOrigin = CheckIfOrigin(self)
    local isOurSummon = CheckIfOurSummon(self)
    local isPartyMember = CheckIfParty(self)
    local hasPlayerData = HasPlayerData(self)
    local isPlayer = IsPlayer(self)

    local alreadyModified = entity.Vars.LCC_Boosted.General
    local sameHash = entity.Vars.LCC_BoostedWithHash.Hash == sessionContext.ConfigHash

    -- Special case check, AdditionalEnemies mod adds certain enemies that are marked boss but not hostile for some reason
    local isAdditionalEnemiesSpecialBoss = false
    if IsAdditionalEnemiesLoaded() and isBoss then
        for _, statName in ipairs(CharacterGetStats(guid)) do
            if Ext.Stats.Get(statName).ModId == ADDITIONAL_ENEMIES_GUID then
                isAdditionalEnemiesSpecialBoss = true
            end
        end
    end
    local combatComponent = SafeGet(entity, "ServerCharacter", "Character", "Template", "CombatComponent")
    local rawAIHint = SafeGet(combatComponent, "AiHint")
    local mappedAIHint = SafeGet(AiHints, SafeGet(combatComponent, "AiHint"))
    local rawArchetype = SafeGet(combatComponent, "Archetype")

    local kinds = sessionContext.EntityToKinds(shortGuid) or {}
    local allClasses = {}
    for kind, _ in pairs(kinds) do
        local classes = KindMapping[kind]
        allClasses = TableCombine(classes, allClasses)
    end

    local restrictions = sessionContext.EntityToRestrictions(shortGuid) or {}

    self.IsCharacter = isCharacter
    self.IsPartyMember = isPartyMember
    self.IsPartyFollower = isPartyFollower
    self.IsOurSummon = isOurSummon
    self.IsEnemy = isEnemy
    self.IsOrigin = isOrigin
    self.IsBoss = isBoss
    self.HasPlayerData = hasPlayerData
    self.IsPlayer = isPlayer
    self.AlreadyModified = alreadyModified
    self.SameHash = sameHash
    self.IsAdditionalEnemiesSpecialBoss = isAdditionalEnemiesSpecialBoss
    self.ConfigHash = sessionContext.ConfigHash
    self.RawAIHint = rawAIHint
    self.MappedAIHint = mappedAIHint
    self.RawArchetype = rawArchetype
    self.Kinds = kinds
    self.AllClasses = allClasses
    self.Restrictions = restrictions
    self.StatsChain = CharacterGetStats(shortGuid)
    return self
end

--- @param o table | nil
--- @return EnrichedEntity
function EnrichedEntity:New(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

--- @param sessionContext SessionContext
--- @return EnrichedEntity
function EnrichedEntity:Refresh(sessionContext)
    local entity = Ext.Entity.Get(self.ShortGuid)
    return self:EnrichEntity(sessionContext, entity)
end

--- @return boolean
function EnrichedEntity:IsClassifiedEnemy()
    return not self.IsPartyMember and self.IsEnemy and not self.IsBoss and not self.IsOrigin
end

--- @return boolean
function EnrichedEntity:IsClassifiedBoss()
    return not self.IsPartyMember and (self.IsEnemy or self.IsAdditionalEnemiesSpecialBoss) and self.IsBoss and not self.IsOrigin
end

--- @return boolean
function EnrichedEntity:IsClassifiedAlly()
    return not self.IsPartyMember and not self.IsEnemy and not self.IsOrigin and not self.IsBoss
end

--- @return boolean
function EnrichedEntity:IsClassifiedFollower()
    return not self.IsEnemy and not self.IsOrigin and self.IsPartyFollower and not self.IsBoss
end

--- @return boolean
function EnrichedEntity:IsClassifiedFollowerBoss()
    return not self.IsEnemy and not self.IsOrigin and self.IsPartyFollower and self.IsBoss
end

--- @return boolean
function EnrichedEntity:IsClassifiedSummon()
    return self.IsPartyMember and self.IsOurSummon
end

--- @param sessionContext SessionContext
--- @return string | nil
function EnrichedEntity:GetConfigClassification(sessionContext)
    if sessionContext.VarsJson["EnemiesEnabled"] and self:IsClassifiedEnemy() then
        return "Enemies"
    end
    if sessionContext.VarsJson["BossesEnabled"] and self:IsClassifiedBoss() then
        return "Bosses"
    end
    if sessionContext.VarsJson["AlliesEnabled"] and self:IsClassifiedAlly() then
        return "Allies"
    end
    if sessionContext.VarsJson["FollowersEnabled"] and self:IsClassifiedFollower() then
        return "Followers"
    end
    if sessionContext.VarsJson["FollowersBossesEnabled"] and self:IsClassifiedFollowerBoss() then
        return "FollowersBosses"
    end
    if sessionContext.VarsJson["SummonsEnabled"] and self:IsClassifiedSummon() then
        return "Summons"
    end
    return nil
end

--- @return SessionContext
function CreateSessionContext()
    local sessionContext = {
        VarsJson = {},
        SpellsAdded = {},
        PassivesAdded = {},
        ImplicatedGuids = {},
        EntityCache = {},
        ActionResources = {},
        Tags = {},
        Races = {},
        Archetypes = {},
        AIHints = {},
        CombatGroups = {},
        ConfigFailed = 0,
    }
    sessionContext.Log = function(level, str) _Log(sessionContext, level, str) end
    sessionContext.LogI = function(level, indent, str) _LogI(sessionContext, level, indent, str) end


    for _, resourceGuid in pairs(Ext.StaticData.GetAll("ActionResource")) do
        local resource = Ext.StaticData.Get(resourceGuid, "ActionResource")
        sessionContext.ActionResources[resource.Name] = resourceGuid
    end

    for _, tagGuid in pairs(Ext.StaticData.GetAll("Tag")) do
        local tag = Ext.StaticData.Get(tagGuid, "Tag")
        sessionContext.Tags[tag.Name] = tagGuid
    end

    for _, raceGuid in pairs(Ext.StaticData.GetAll("Race")) do
        local race = Ext.StaticData.Get(raceGuid, "Race")
        sessionContext.Races[race.Name] = raceGuid
    end

    local rootTemplates = Ext.Template.GetAllRootTemplates()
    for _, template in pairs(rootTemplates) do
        if ({item = true, character = true})[template.TemplateType] then

            if (
                template.TemplateType == "character" and
                template.CombatComponent ~= nil
            ) then
                sessionContext.Archetypes[template.CombatComponent.Archetype] = true
                if (
                    template.CombatComponent.CombatGroupID ~= nil and
                    template.CombatComponent.CombatGroupID ~= ""
                ) then
                    if sessionContext.CombatGroups[template.CombatComponent.CombatGroupID] == nil then
                        sessionContext.CombatGroups[template.CombatComponent.CombatGroupID] = {}
                    end
                    table.insert(sessionContext.CombatGroups[template.CombatComponent.CombatGroupID], Ext.Types.Serialize(template))
                end
                if (
                    template.CombatComponent.AiHint ~= nil and
                    template.CombatComponent.AiHint ~= "" and
                    template.CombatComponent.AiHint ~= NULL_GUID
                ) then
                    sessionContext.AIHints[template.CombatComponent.AiHint] = true
                end
            end
        end
    end

    local stats = Ext.Stats.GetStats("StatusData")
    for _, statName in pairs(stats) do
        local stat = Ext.Stats.Get(statName)
        if ({BOOST = true, POLYMORPHED = true})[stat.StatusType] then
            local val = string.match(stat.Boosts, "AiArchetypeOverride[(](.-),[0-9]+[)]")
            if val ~= nil then
                sessionContext.Archetypes[val] = true
            end
        end
    end
    return sessionContext
end

--- @return SessionContext
function DummySessionContext()
    local verbosity = 0
    if Ext.Debug.IsDeveloperMode() then
        verbosity = 2
    end
    return {
        VarsJson = {
            Verbosity = verbosity,
        },
    }
end

local function OnSessionLoaded()
    _Log(DummySessionContext(), 0, "0.9.8.1")

    if IsCriticalMissLoaded() then
        ProtectedPassives["Passive_CriticalMiss"] = true
    end

    --- @type SessionContext
    if rawget(_G, SessionContext) == nil then
        SessionContext = CreateSessionContext()
    end

    --- @diagnostic disable-next-line: unused-local
    Ext.Osiris.RegisterListener("LevelLoaded", 1, "before", function(level)
            _Log(DummySessionContext(), 2, "LevelLoaded: Before")

            SessionContext.EntityCache = {}
            GetVarsJson(SessionContext)

        end
    )

    --- @diagnostic disable-next-line: unused-local
    Ext.Osiris.RegisterListener("LevelLoaded", 1, "after", function(level)
            _Log(DummySessionContext(), 2, "LevelLoaded: After")
        end
    )

    --- @diagnostic disable-next-line: unused-local
    Ext.Osiris.RegisterListener("EnteredLevel", 3, "before", function(guid, _objectRootTemplate, level)
            _Log(DummySessionContext(), 2, string.format("EnteredLevel: Guid: %s", guid))
            SessionContext.Log(1, string.format("EnteredLevel: Guid: %s", guid))
            local shortGuid = string.sub(guid, -36)
            local entity = Ext.Entity.Get(shortGuid)
            --- @cast entity Entity

            local entities = {entity}

            local enrichedEntities = EnrichEntities(SessionContext, entities, true)

            SetupUserVars(SessionContext, enrichedEntities)

            --- @diagnostic disable-next-line: unused-local
            local affectedEntities, unAffectedEntities, unBooostedEntities = RemoveBoostingMany(SessionContext, enrichedEntities, false)

            local entitiesNeedingBoosts = {}
            entitiesNeedingBoosts = TableCombine(unBooostedEntities, TableCombine(affectedEntities, entitiesNeedingBoosts))

            DelayedCallUntilWithAtLeastTime(
                500,
                function() return WaitRemoveBoostingMany(SessionContext, affectedEntities) end,
                function()
                    PerformBoostingMany(SessionContext, entitiesNeedingBoosts)
                end
            )
        end
    )
    Ext.Osiris.RegisterListener("EnteredCombat", 2, "after", function(guid, combatid)
            _Log(DummySessionContext(), 2, string.format("EnteredCombat: Guid: %s; combatid: %s", guid, combatid))
            SessionContext.Log(1, string.format("EnteredCombat: Guid: %s; combatid: %s", guid, combatid))
            local shortGuid = string.sub(guid, -36)
            local entity = Ext.Entity.Get(shortGuid)
            --- @cast entity Entity

            local entities = {entity}

            local enrichedEntities = EnrichEntities(SessionContext, entities, true)

            SetupUserVars(SessionContext, enrichedEntities)

            --- @diagnostic disable-next-line: unused-local
            local affectedEntities, unAffectedEntities, unBooostedEntities = RemoveBoostingMany(SessionContext, enrichedEntities, false)

            local entitiesNeedingBoosts = {}
            entitiesNeedingBoosts = TableCombine(unBooostedEntities, TableCombine(affectedEntities, entitiesNeedingBoosts))

            DelayedCallUntilWithAtLeastTime(
                300,
                function() return WaitRemoveBoostingMany(SessionContext, affectedEntities) end,
                function()
                    PerformBoostingMany(SessionContext, entitiesNeedingBoosts)
                end
            )
        end
    )

    Ext.Osiris.RegisterListener("CombatEnded",1,"after",function(combatid)
            _Log(DummySessionContext(), 1, string.format("CombatEnded: combatid: %s\n", combatid))
            SessionContext.Log(1, string.format("CombatEnded: combatid: %s\n", combatid))
        end
    )


    Ext.Osiris.RegisterListener("PingRequested",1,"after",function(_)
            _Log(DummySessionContext(), 1, "PingRequested")
            SessionContext.Log(1, "PingRequested: Removing Current Boosts")

            SessionContext.EntityCache = {}
            GetVarsJson(SessionContext)

            local entities = Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")
            --- @cast entities Entity[]

            local enrichedEntities = EnrichEntities(SessionContext, entities, true)

            SetupUserVars(SessionContext, enrichedEntities)

            --- @diagnostic disable-next-line: unused-local
            local affectedEntities, unAffectedEntities, unBooostedEntities = RemoveBoostingMany(SessionContext, enrichedEntities, false)

            local entitiesNeedingBoosts = {}
            entitiesNeedingBoosts = TableCombine(unBooostedEntities, TableCombine(affectedEntities, entitiesNeedingBoosts))

            -- After removing passives, it takes some time for them to actually disappear
            DelayedCallUntilWithAtLeastTime(
                500,
                function() return WaitRemoveBoostingMany(SessionContext, entitiesNeedingBoosts) end,
                function()
                    PerformBoostingMany(SessionContext, entitiesNeedingBoosts)
                end
            )
        end
    )

    --- @diagnostic disable-next-line: unused-local
    Ext.Osiris.RegisterListener("TimerFinished",1,"after",function(event)
        end
    )
    Ext.Osiris.RegisterListener("LevelGameplayStarted",2,"after",function(_,_)
            _Log(DummySessionContext(), 1, "LevelGameplayStarted")
            SessionContext.Log(1, string.format("LevelGameplayStarted: Computing Lists"))

            SessionContext.EntityCache = {}
            GetVarsJson(SessionContext)

            local entities = Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")
            --- @cast entities Entity[]

            local enrichedEntities = EnrichEntities(SessionContext, entities, true)

            SetupUserVars(SessionContext, enrichedEntities)

            if SafeGetWithDefault(false, SessionContext.VarsJson, "DebugMode", "DisableLevelGameplayStart") then
                return
            end

            --- @diagnostic disable-next-line: unused-local
            local affectedEntities, unAffectedEntities, unBooostedEntities = RemoveBoostingMany(SessionContext, enrichedEntities, false)

            local entitiesNeedingBoosts = {}
            entitiesNeedingBoosts = TableCombine(unBooostedEntities, TableCombine(affectedEntities, entitiesNeedingBoosts))

            -- After removing passives, it takes some time for them to actually disappear
            DelayedCallUntilWithAtLeastTime(
                500,
                function() return WaitRemoveBoostingMany(SessionContext, entitiesNeedingBoosts) end,
                function()
                    PerformBoostingMany(SessionContext, entitiesNeedingBoosts)
                end
            )
        end
    )
    Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(character)
            if SafeGetWithDefault(false, SessionContext.VarsJson, "DebugMode", "Enabled") then
                DebugMode(SessionContext, character)
            end
        end
    )
    Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(target, statusID, _, _)
            if not SafeGetWithDefault(false, SessionContext.VarsJson, "DebugMode", "Enabled") then
                return
            end

            -- Courtesy to claravel's DebugSpells mod for this
            if statusID == "LCC_INFO" then
                local shortGuid = string.sub(target, -36)
                local x, y, z = Osi.GetPosition(shortGuid)
                SessionContext.Log(
                    0,
                    string.format(
                        "FullGuid: %s; ShortGuid: %s: LocalizedName %s Template: %s Pos: (%s,%s,%s)",
                        target,
                        shortGuid,
                        UuidToLocalizedName(shortGuid),
                        Osi.GetTemplate(shortGuid),
                        x,
                        y,
                        z
                    )
                )
            end

            if statusID == "LCC_RELOAD_CONFIG" then
                SessionContext.Log(0, "Reloading LoreCombatConfigurator.json")

                SessionContext.EntityCache = {}
                GetVarsJson(SessionContext)
            end

            if statusID == "LCC_REBOOST" then
                local entity = Ext.Entity.Get(string.sub(target, -36))
                --- @cast entity Entity

                local entities = {entity}

                local enrichedEntities = EnrichEntities(SessionContext, entities, true)

                SetupUserVars(SessionContext, enrichedEntities)

                --- @diagnostic disable-next-line: unused-local
                local affectedEntities, unAffectedEntities, unBooostedEntities = RemoveBoostingMany(SessionContext, enrichedEntities, true)

                local entitiesNeedingBoosts = {}
                entitiesNeedingBoosts = TableCombine(unBooostedEntities, TableCombine(affectedEntities, entitiesNeedingBoosts))

                -- After removing passives, it takes some time for them to actually disappear
                DelayedCallUntil(
                    function() return WaitRemoveBoostingMany(SessionContext, entitiesNeedingBoosts) end,
                    function()
                        PerformBoostingMany(SessionContext, entitiesNeedingBoosts)
                    end
                )
            end

            if statusID == "LCC_UNBOOST" then
                local entity = Ext.Entity.Get(string.sub(target, -36))
                --- @cast entity Entity

                local entities = {entity}

                local enrichedEntities = EnrichEntities(SessionContext, entities, true)

                SetupUserVars(SessionContext, enrichedEntities)

                RemoveBoostingMany(SessionContext, enrichedEntities, true)
            end

            if statusID == "LCC_BOOST" then
                local entity = Ext.Entity.Get(string.sub(target, -36))
                --- @cast entity Entity

                local entities = {entity}

                local enrichedEntities = EnrichEntities(SessionContext, entities, true)

                SetupUserVars(SessionContext, enrichedEntities)

                PerformBoostingMany(SessionContext, enrichedEntities)
            end


            if statusID == "LCC_ALL_REBOOST" then
                local entities = Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")
                --- @cast entities Entity[]

                local enrichedEntities = EnrichEntities(SessionContext, entities, true)

                SetupUserVars(SessionContext, enrichedEntities)

                --- @diagnostic disable-next-line: unused-local
                local affectedEntities, unAffectedEntities, unBooostedEntities = RemoveBoostingMany(SessionContext, enrichedEntities, true)

                local entitiesNeedingBoosts = {}
                entitiesNeedingBoosts = TableCombine(unBooostedEntities, TableCombine(affectedEntities, entitiesNeedingBoosts))

                -- After removing passives, it takes some time for them to actually disappear
                DelayedCallUntil(
                    function() return WaitRemoveBoostingMany(SessionContext, entitiesNeedingBoosts) end,
                    function()
                        PerformBoostingMany(SessionContext, entitiesNeedingBoosts)
                    end
                )
            end

            if statusID == "LCC_ALL_UNBOOST" then
                local entities = Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")
                --- @cast entities Entity[]

                local enrichedEntities = EnrichEntities(SessionContext, entities, true)

                SetupUserVars(SessionContext, enrichedEntities)

                RemoveBoostingMany(SessionContext, enrichedEntities, true)
            end

            if statusID == "LCC_ALL_BOOST" then
                local entities = Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")
                --- @cast entities Entity[]

                local enrichedEntities = EnrichEntities(SessionContext, entities, true)

                SetupUserVars(SessionContext, enrichedEntities)

                PerformBoostingMany(SessionContext, enrichedEntities)
            end
        end
    )
end

DEVELOPMENT_SPELLS_CONTAINER = "Target_LCC_DeveloperContainer"
function AddDeveloperSpells(target)
    if Osi.HasSpell(target, DEVELOPMENT_SPELLS_CONTAINER) == 0 then
        Osi.AddSpell(target, DEVELOPMENT_SPELLS_CONTAINER, 1, 1)
    end
end

function RemoveDeveloperSpells(target)
    if Osi.HasSpell(target, DEVELOPMENT_SPELLS_CONTAINER) == 1 then
        Osi.RemoveSpell(target, DEVELOPMENT_SPELLS_CONTAINER, 1)
    end
end

--- @diagnostic disable-next-line: unused-local
function DebugMode(sessionContext, characterGuid)
    local shortGuid = string.sub(characterGuid, -36)
    local entity = Ext.Entity.Get(shortGuid)
    if entity.Vars.LCC_DebugMode_RestoreSettings == nil then
        entity.Vars.LCC_DebugMode_RestoreSettings = {
            OriginalMovementSpeed = nil,
            SpellsAdded = nil,
        }
    end

    local movementSpeedMultiplier = SafeGet(SessionContext.VarsJson, "DebugMode", "MovementSpeedMultiplier")
    if movementSpeedMultiplier ~= nil and movementSpeedMultiplier > 1 then
        local charTemplate = Ext.Template.GetTemplate(shortGuid)
        if charTemplate == nil then
            local charTemplateGuid = Osi.GetTemplate(shortGuid)
            if charTemplateGuid ~= nil then
                charTemplate = Ext.Template.GetTemplate(string.sub(charTemplateGuid, -36))
            end
        end
        if charTemplate ~= nil then
            local debugSettings = entity.Vars.LCC_DebugMode_RestoreSettings
            local originalMovementSpeedRun = debugSettings.OriginalMovementSpeed or charTemplate["MovementSpeedRun"]

            charTemplate["MovementSpeedRun"] = originalMovementSpeedRun * movementSpeedMultiplier

            debugSettings.OriginalMovementSpeed = originalMovementSpeedRun
            entity.Vars.LCC_DebugMode_RestoreSettings = debugSettings
        end
    end

    if SafeGetWithDefault(false, SessionContext.VarsJson, "DebugMode", "AddSpells") then
        AddDeveloperSpells(shortGuid)

        local debugSettings = entity.Vars.LCC_DebugMode_RestoreSettings
        debugSettings.SpellsAdded = true
        entity.Vars.LCC_DebugMode_RestoreSettings = debugSettings
    end
end

--- @diagnostic disable-next-line: unused-local
function UnDebugMode(sessionContext, characterGuid)
    local shortGuid = string.sub(characterGuid, -36)
    local entity = Ext.Entity.Get(shortGuid)
    if entity.Vars.LCC_DebugMode_RestoreSettings == nil then
        entity.Vars.LCC_DebugMode_RestoreSettings = {
            WasEnabled = false,
            OriginalMovementSpeed = nil,
            SpellsAdded = nil,
        }
    end

    if entity.Vars.LCC_DebugMode_RestoreSettings.OriginalMovementSpeed ~= nil then
        local charTemplate = Ext.Template.GetTemplate(shortGuid)
        if charTemplate == nil then
            local charTemplateGuid = Osi.GetTemplate(shortGuid)
            if charTemplateGuid ~= nil then
                charTemplate = Ext.Template.GetTemplate(string.sub(charTemplateGuid, -36))
            end
        end
        if charTemplate ~= nil then
            local debugSettings = entity.Vars.LCC_DebugMode_RestoreSettings

            charTemplate["MovementSpeedRun"] = debugSettings.OriginalMovementSpeed

            debugSettings.OriginalMovementSpeed = nil
            entity.Vars.LCC_DebugMode_RestoreSettings = debugSettings
        end
    end

    if entity.Vars.LCC_DebugMode_RestoreSettings.SpellsAdded ~= nil then
        RemoveDeveloperSpells(shortGuid)

        local debugSettings = entity.Vars.LCC_DebugMode_RestoreSettings
        debugSettings.SpellsAdded = nil
        entity.Vars.LCC_DebugMode_RestoreSettings = debugSettings
    end
end

Ext.Vars.RegisterUserVariable("LCC_PassivesAdded", {Server=true, Persistent=true, DontCache=true})
Ext.Vars.RegisterUserVariable("LCC_BoostsAdded", {Server=true, Persistent=true, DontCache=true})
Ext.Vars.RegisterUserVariable("LCC_Boosted", {Server=true, Persistent=true, DontCache=true})
Ext.Vars.RegisterUserVariable("LCC_BoostedWithHash", {Server=true, Persistent=true, DontCache=true})
Ext.Vars.RegisterUserVariable("LCC_BoostedWithClassification", {Server=true, Persistent=true, DontCache=true})
Ext.Vars.RegisterUserVariable("LCC_DebugMode_RestoreSettings", {Server=true, Persistent=true, DontCache=true})

Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

Ext.Events.GameStateChanged:Subscribe(function(event)
        _Log(DummySessionContext(), 2, string.format("GameStateChanged: %s -> %s", event.FromState, event.ToState))
        --- @cast event GameStateEvent
        if event.FromState == "Sync" and event.ToState == "Running" then
            _Log(DummySessionContext(), 2, "Game state loaded")
            for _, e in ipairs(Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")) do
                --- @cast e +Entity
                if e.Vars.LCC_BoostsAdded ~= nil then
                    local boosts = e.BoostsContainer.Boosts
                    for _, boost in ipairs(e.Vars.LCC_BoostsAdded) do
                        local _, _, boostKind, boostParams = string.find(boost, "(.+)[(](.+)[)]")
                        SessionContext.Log(5, string.format("Checking if boost %s(%s(%s)) is already applied to %s", boost, boostKind, boostParams, e.Uuid.EntityUuid))
                        if (
                            boosts[boostKind] == nil or
                            (boosts[boostKind] ~= nil and #Filter(function(iboost) return CompareBoost(iboost, {Boost = boostKind, Params = boostParams, Params2 =""}) end, boosts[boostKind]) == 0)
                        ) then
                            SessionContext.Log(6, string.format("Boost %s(%s(%s)) was not already applied to %s in %s", boost, boostKind, boostParams, e.Uuid.EntityUuid, J(Map(function(b) return b.BoostInfo end, boosts[boostKind] or {}))))
                            AddBoostsAdv(e.Uuid.EntityUuid, boost)
                        end
                    end
                end
            end
        end

        if event.FromState == "UnloadSession" and event.ToState == "LoadSession" then
            _Log(DummySessionContext(), 2, "Session ReLoading")
        end

        if event.FromState == "LoadLevel" and event.ToState == "Sync" then
            _Log(DummySessionContext(), 2, "LoadLevel  -> Sync: CreateSessionContext")
            --- @type SessionContext
            if rawget(_G, SessionContext) == nil then
                SessionContext = CreateSessionContext()
            end

            SessionContext.EntityCache = {}
            GetVarsJson(SessionContext)
        end
    end
)

function DBG_GetAffected()
    local affected = {}
    for _, e in ipairs(Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")) do
        --- @cast e +Entity
        local guid = string.sub(e.Uuid.EntityUuid, -36)
        local modified = e.Vars.LCC_Boosted.General
        if modified then
            affected[guid] = {
                Name = e.ServerCharacter.Character.Template.Name,
                Boosts = {},
                Passives = {},
            }
            for _, boostEntities in pairs(e.BoostsContainer.Boosts) do
                for _, boostEntity in ipairs(boostEntities) do
                    if boostEntity.BoostInfo.Cause.Cause == ModName then
                        local boost = FormatBoost(boostEntity)
                        table.insert(affected[guid].Boosts, {
                            BoostStr = boost,
                            BoostInfo = boostEntity.BoostInfo,
                        })
                    end
                end
            end
            affected[guid].Passives = Keys(e.Vars.LCC_PassivesAdded)
        end
    end
    return affected
end

function DBG_BoostsAndPassives(guid)
    local entity = Ext.Entity.Get(guid)
    return {
        Guid = guid,
        Name = entity.ServerCharacter.Character.Template.Name,
        ShortGuid = entity.Uuid.EntityUuid,
        FullGuid = string.format("%s_%s", entity.ServerCharacter.Character.Template.Name, entity.Uuid.EntityUuid),
        Boosts = Map(function(p) return FormatBoost(p) end, Flatten(Map(function(p) return Ext.Types.Serialize(p) end, Values(entity.BoostsContainer.Boosts)))),
        Passives = Map(function(p) return p.Passive.PassiveId end, entity.PassiveContainer.Passives),
    }
end

--- @diagnostic disable-next-line: unused-local
function DBG_Passives(_cmd, guid)
    local entity = Ext.Entity.Get(guid)
    local ourPassives = Keys(entity.Vars.LCC_PassivesAdded)
    _D(ourPassives)
end

Ext.RegisterConsoleCommand("LCC_PassivesFor", DBG_Passives);

function OurBoosts(guid, entity)
    if guid == nil and entity == nil then
        return {}
    end
    if guid ~= nil and entity ~= nil then
        return {}
    end
    if guid ~= nil then
        entity = Ext.Entity.Get(guid)
    end
    return Filter(
        function(bi) return bi.Cause.Cause == ModName end,
        Map(
            function(b) return b.BoostInfo end,
            Flatten(
                    Map(
                        function(cpp) return Ext.Types.Serialize(cpp) end,
                        Values(entity.BoostsContainer.Boosts
                    )
                )
            )
        )
    )
end

--- @diagnostic disable-next-line: unused-local
function DBG_Boosts(_cmd, guid)
    _D(OurBoosts(guid))
end

Ext.RegisterConsoleCommand("LCC_BoostsFor", DBG_Boosts);
