#!/usr/bin/env python

import collections
from dataclasses import field
import glob
import json
import os
import re
import sys

import bs4
import click
import lxml

@click.group()
def cli():
    pass

@cli.command()
@click.option("--vanilla-spell-lists-file")
@click.option("--vanilla-with-5E-spell-lists-file")
@click.option("--only-5E-spell-lists-file")
def diff_spell_lists(
    vanilla_spell_lists_file,
    vanilla_with_5e_spell_lists_file,
    only_5e_spell_lists_file,
):
    vanilla_spell_lists = json.load(open(vanilla_spell_lists_file, "r"))
    vanilla_with_5E_spell_lists = json.load(open(vanilla_with_5e_spell_lists_file, "r"))

    only_5e_spell_lists = {}
    for class_name, spell_lists in vanilla_spell_lists.items():
        only_5e_spell_lists[class_name] = {}
        for spell_list_name, spell_list in spell_lists.items():
            vanilla_with_5E_spell_list = vanilla_with_5E_spell_lists[class_name][spell_list_name]
            only_5E_spells = set(vanilla_with_5E_spell_list) - set(spell_list)
            only_5e_spell_lists[class_name][spell_list_name] = list(only_5E_spells)

    json.dump(only_5e_spell_lists, open(only_5e_spell_lists_file, "w"), indent=4)


@cli.command()
@click.option("--vanilla-spell-lists-file")
@click.option("--vanilla-with-5E-spell-lists-file")
@click.option("--only-5E-spell-lists-file")
def diff_spell_lists_globally(
    vanilla_spell_lists_file,
    vanilla_with_5e_spell_lists_file,
    only_5e_spell_lists_file,
):
    vanilla_spell_lists = json.load(open(vanilla_spell_lists_file, "r"))
    vanilla_with_5E_spell_lists = json.load(open(vanilla_with_5e_spell_lists_file, "r"))

    vanilla_spells_by_level = collections.defaultdict(set)
    for class_name, spell_lists in vanilla_spell_lists.items():
        for spell_list_name, spell_list in spell_lists.items():
            simplified_level_name = re.match(r".*(?P<level>base|Cantrip|First|Second|Third|Fourth|Fifth|Sixth)", spell_list_name).groupdict()["level"]
            spells = set(spell_list)
            vanilla_spells_by_level[simplified_level_name] = list(set(vanilla_spells_by_level[simplified_level_name]).union(spells))

    only_5e_spell_lists = {}
    for class_name, spell_lists in vanilla_spell_lists.items():
        only_5e_spell_lists[class_name] = {}
        for spell_list_name, spell_list in spell_lists.items():
            simplified_level_name = re.match(r".*(?P<level>base|Cantrip|First|Second|Third|Fourth|Fifth|Sixth)", spell_list_name).groupdict()["level"]
            vanilla_with_5E_spell_list = vanilla_with_5E_spell_lists[class_name][spell_list_name]
            only_5E_spells = set(vanilla_with_5E_spell_list) - (set(spell_list) | set(vanilla_spells_by_level[simplified_level_name]))
            only_5e_spell_lists[class_name][spell_list_name] = list(only_5E_spells)

    json.dump(only_5e_spell_lists, open(only_5e_spell_lists_file, "w"), indent=4)


@cli.command()
@click.option("--spell-lists-file")
@click.option("--output-file")
def collect_spells_by_level(
    spell_lists_file,
    output_file,
):
    spell_lists = json.load(open(spell_lists_file, "r"))

    spells_by_level = collections.defaultdict(set)
    for class_name, spell_lists_by_level in spell_lists.items():
        for spell_list_level in ["Cantrip", "First", "Second", "Third", "Fourth", "Fifth", "Sixth"]:
            spells = set(spell_lists_by_level.get(spell_list_level, []))
            spells_by_level[spell_list_level] = sorted(list(set(spells_by_level[spell_list_level]).union(spells)))

    json.dump(spells_by_level, open(output_file, "w"), indent=4)

@cli.command()
@click.option("--spell-level-file")
@click.option("--output-file")
def json_to_lua(
    spell_level_file,
    output_file,
):
    spells_by_level = json.load(open(spell_level_file, "r"))

    strings = []
    strings += ["{"]
    for level, spells in spells_by_level.items():
        strings += [f"        {level} = {{"]
        for spell in spells:
            strings += [f"            \"{spell}\","]
        strings += ["        },"]
    strings += ["}"]

    with open(output_file, "w") as f:
        f.write("\n".join(strings))

@cli.command()
def read_progressions():
    result = collections.defaultdict(lambda: collections.defaultdict(dict))

    for progression_file in [
        "../Gustav/Public/Gustav/Progressions/Progressions.lsx",
        "../Gustav/Public/GustavDev/Progressions/Progressions.lsx",
        "../Shared/Public/Shared/Progressions/Progressions.lsx",
        "../Shared/Public/SharedDev/Progressions/Progressions.lsx",
    ]:
        f = bs4.BeautifulSoup(open(progression_file, 'r').read(), features="xml")
        all_progressions = f.find_all("node", id="Progression")
        for progression in all_progressions:
            class_name = progression.find("attribute", id="Name").get("value")
            level = 0
            if (level_block := progression.find("attribute", id="Level")) is not None:
                level = level_block.get("value")

            passives_added = []
            if (passives_added_block := progression.find("attribute", id="PassivesAdded")) is not None:
                passives_added_raw = passives_added_block.get("value")
                passives_added = passives_added_raw.split(";")

            selectors = []
            if (selectors_block := progression.find("attribute", id="Selectors")) is not None:
                selectors_raw = selectors_block.get("value")
                selectors = selectors_raw.split(";")

            if "selectors" in result[class_name][level]:
                result[class_name][level]["selectors"] = list(set(result[class_name][level]["selectors"]) | set(selectors))
            else:
                result[class_name][level]["selectors"] = selectors

            if "passives_added" in result[class_name][level]:
                result[class_name][level]["passives_added"] = list(set(result[class_name][level]["passives_added"]) | set(passives_added))
            else:
                result[class_name][level]["passives_added"] = passives_added
    json.dump(result, open("progressions.json", "w"), indent=4)

@cli.command()
@click.option("--progression-json-file")
def process_progressions_json(progression_json_file):
    result = collections.defaultdict(lambda: collections.defaultdict(dict))

    loaded = json.load(open(progression_json_file, "r"))
    subclass_to_classes = {
        "BattleMaster": "Fighter",
        "Champion": "Fighter",
        "EldrithKnight": "Fighter",

        "ArcaneTrickster": "Rogue",
        "Thief": "Rogue",
        "Assassin": "Rogue",

        "Vengeance": "Paladin",
        "Devotion": "Paladin",
        "Ancients": "Paladin",

        "Fiend": "Warlock",
        "Archfey": "Warlock",
        "GreatOldOne": "Warlock",

        "AbjurationSchool": "Wizard",
        "DivinationSchool": "Wizard",
        "EvocationSchool": "Wizard",
        "ConjurationSchool": "Wizard",
        "EnchantmentSchool": "Wizard",
        "IllusionSchool": "Wizard",
        "NecromancySchool": "Wizard",
        "TransmutationSchool": "Wizard",

        "BeastMaster": "Ranger",
        "GloomStalker": "Ranger",
        "Hunter": "Ranger",

        "BersekerPath": "Barbarian",
        "TotemWarriorPath": "Barbarian",
        "WildMagicPath": "Barbarian",

        "CircleOfTheLand": "Druid",
        "CircleOfTheMoon": "Druid",
        "CircleOfTheSpores": "Druid",

        "DraconicBloodline": "Sorcerer",
        "WildMagic": "Sorcerer",
        "StormSorcery": "Sorcerer",

        "LoreCollege": "Bard",
        "ValorCollege": "Bard",
        "SwordsCollege": "Bard",

        "LightDomain": "Cleric",
        "LifeDomain": "Cleric",
        "NatureDomain": "Cleric",
        "TempestDomain": "Cleric",
        "TrickeryDomain": "Cleric",
        "WarDomain": "Cleric",
        "KnowledgeDomain": "Cleric",

        "OpenHand": "Monk",
        "Shadow": "Monk",
        "FourElements": "Monk",
    }
    classes = set(subclass_to_classes.values())

    spell_lists = {}

    for spell_lists_file in [
        "../Shared/Public/Shared/Lists/SpellLists.lsx",
        "../Shared/Public/SharedDev/Lists/SpellLists.lsx",
    ]:
        f = bs4.BeautifulSoup(open(spell_lists_file, 'r').read(), features="xml")
        all_spell_lists = f.find_all("node", id="SpellList")
        for spell_list in all_spell_lists:
            spell_list_id = spell_list.find("attribute", id="UUID").get("value")
            spell_list_comment = spell_list.find("attribute", id="Comment").get("value")
            spell_list_spells_raw = spell_list.find("attribute", id="Spells").get("value")
            spell_list_spells = spell_list_spells_raw.split(";")
            spell_lists[spell_list_id] = {
                "comment": spell_list_comment,
                "spells": spell_list_spells,
            }

    passive_lists = {}

    for passive_lists_file in [
        "../Shared/Public/Shared/Lists/PassiveLists.lsx",
        "../Shared/Public/SharedDev/Lists/PassiveLists.lsx",
    ]:
        f = bs4.BeautifulSoup(open(passive_lists_file, 'r').read(), features="xml")
        all_passive_lists = f.find_all("node", id="PassiveList")
        for passive_list in all_passive_lists:
            passive_list_id = passive_list.find("attribute", id="UUID").get("value")
            passive_list_passives_raw = passive_list.find("attribute", id="Passives").get("value")
            passive_list_passives = passive_list_passives_raw.split(",")
            passive_lists[passive_list_id] = {
                "spells": passive_list_passives,
            }

    for class_name, levels in loaded.items():
        normalized_class_name = subclass_to_classes.get(class_name, class_name)
        if normalized_class_name not in classes:
            print(f"Skipping {class_name}")
            continue
        for level, level_data in levels.items():
            if "passives_added" in level_data:
                if "passives_added" in result[normalized_class_name][level]:
                    result[normalized_class_name][level]["passives_added"] = list(set(result[normalized_class_name][level]["passives_added"]) | set(level_data["passives_added"]))
                else:
                    result[normalized_class_name][level]["passives_added"] = list(set(level_data["passives_added"]))

                if "passives_added_extra_data" not in result[normalized_class_name][level]:
                    result[normalized_class_name][level]["passives_added_extra_data"] = []

                result[normalized_class_name][level]["passives_added_extra_data"] += [
                    {"passive_added": passive_added, "origin": class_name}
                    for passive_added in level_data["passives_added"]
                ]

            if "selectors" in level_data:
                selectors = level_data["selectors"]

                normalized_selectors = []
                normalized_selectors_extra_data = []
                for selector in selectors:
                    match = re.match(r"(?P<action>AddSpells|SelectPassives|SelectSpells)[(](?P<selector>.*)[)]", selector)
                    if match is not None:
                        action = match.groupdict()["action"]
                        selector = match.groupdict()["selector"]
                        selector_parts = selector.split(",")
                        important = selector_parts[0]
                        normalized_selectors.append((action, important))
                        if "Spell" in action:
                            list_data = spell_lists[important]
                        else:
                            list_data = passive_lists[important]

                        normalized_selectors_extra_data.append(
                            {
                                "action": action,
                                "guid": important,
                                "origin": class_name,
                                "list_data": list_data,
                            },
                        )

                if "selectors" in result[normalized_class_name][level]:
                    result[normalized_class_name][level]["selectors"] = list(set(result[normalized_class_name][level]["selectors"]) | set(normalized_selectors))
                else:
                    result[normalized_class_name][level]["selectors"] = list(set(normalized_selectors))

                if "selectors_extra_data" not in result[normalized_class_name][level]:
                    result[normalized_class_name][level]["selectors_extra_data"] = []

                result[normalized_class_name][level]["selectors_extra_data"] += normalized_selectors_extra_data

    json.dump(result, open("processed_progressions.json", "w"), indent=4)

@cli.command()
@click.option("--path")
def collect_spells(
    path,
):
    res = {}
    files = glob.glob(f"{os.path.expanduser(path)}/**/Spell_*.txt", recursive=True)
    for file in files:
        res[file] = {}

        lines = []
        with open(file, "r") as f:
            lines = f.readlines()

        entry = None
        for line in lines:
            if re.match(r"^\s*$", line) is not None:
                entry = None
            if entry is not None:
                using_match = re.match(r"^using \"(?P<parent>.*?)\"$", line)
                if using_match is not None:
                    res[file][entry]["using"] = using_match.groupdict()["parent"]

                data_match = re.match(r"^data \"(?P<field>.*?)\" \"(?P<rest>.*?)\"$", line)
                if data_match is not None:
                    field = data_match.groupdict()["field"]
                    rest = data_match.groupdict()["rest"]
                    if field in ["SpellProperties", "UseCosts", "SpellFlags", "SpellSuccess", "SpellFail", "DescriptionParams", "TooltipDamageList"]:
                        rest = rest.split(";")
                        rest = [xx for x in rest if (xx := x.strip()) != ""]
                        if field == "UseCosts":
                            rest = [{"Resource": xx[0], "Cost": xx[1]} for x in rest if len((xx := x.split(":"))) == 2]
                    res[file][entry][field] = rest

            if "new entry" in line:
                entry = re.match(r"^new entry \"(?P<entry>.*)\"$", line).groupdict()["entry"]
                res[file][entry] = {}
                res[file][entry]["name"] = entry

    print(json.dumps(res, indent=4))

if __name__ == "__main__":
    cli()
