import bs4
import click
import requests

# Example usage from process bg3 animation file ID is top (uuid), MapKey is bottom (outfile-prefix)
# bash 4.0+ syntax
# while mapfile -t -n 2 ary && ((${#ary[@]})); do
#     python Source/search.py search --uuid "${ary[0]}" --outfile-prefix "Data/Dragon_Red_Base_AnimationSetParts/${ary[1]}"
# done < Data/Dragon_Red_Base_AnimationSet2.xml
#
# more portable
# while read -r var1 && read -r var2; do
#     python Source/search.py search --uuid "${var1}" --outfile-prefix "Data/Dragon_Red_Base_AnimationSetParts/${var2}"
# done < Data/Dragon_Red_Base_AnimationSet2.xml


BASE_URL = "https://bg3.norbyte.dev/search"

@click.group()
def cli():
    pass

@cli.command
@click.option("--uuid", help="The UUID of the resource to search for")
@click.option("--outfile-prefix", default=None, help="The file to write the search results to")
@click.option("--print-console", is_flag=True, default=False, help="Print the search results to the console")
def search(uuid, outfile_prefix, print_console):
    params = {}
    if uuid is not None:
        params = {"q": f"uuid:{uuid}"}

    response = requests.get(BASE_URL, params=params)
    response.raise_for_status()

    soup = bs4.BeautifulSoup(response.text, "html.parser")
    code = soup.find("div", id=lambda x: x is not None and x.startswith("raw-body")).get_text()
    if outfile_prefix is not None:
        with open(f"{outfile_prefix}.xml", "w") as outfile:
            outfile.write(code)
    if print_console:
        print(code)

if __name__ == "__main__":
    cli()
