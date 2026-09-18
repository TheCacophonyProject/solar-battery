# Solar battery

KiCad projects for the solar battery hardware. The board itself is in
[`solar-BQ25798`](solar-BQ25798), with the shared symbols and footprints pulled
in as the [`kicad-library`](kicad-library) submodule.

[`panel-solar-battery.py`](panel-solar-battery.py) panelises the board with
[KiKit](https://github.com/yaqwsx/KiKit) into `.generated-pcbs/`, and adds the
DRC exclusions for the footprints that the panelisation cuts through, so the
generated panel passes DRC.

### Install dependencies
KiCad supplies the `pcbnew` python module as a system package, and it can't be
installed with pip, so the virtual environment has to be able to see it:
- `sudo apt-get install kicad`
- `python3 -m venv --system-site-packages venv`
- `source venv/bin/activate`
- `pip install kikit`

Check both halves are importable before running anything:
- `python -c "import pcbnew, kikit"`

### Generating the panel
With the virtual environment activated, from the root of the repo:
- `python panel-solar-battery.py`

The script needs `kikit` on the `PATH` (it shells out to `kikit panelize`) as
well as `pcbnew` importable, which is why it is run from inside the virtual
environment rather than with the system python.

### Notes
- `.generated-pcbs/` is ignored by git — it is rebuilt from scratch on every
  run, and KiKit gives the footprints new UUIDs each time, so the DRC
  exclusions are only valid for the panel they were generated with.
- Getting the submodule if the checkout is fresh: `git submodule update --init`
