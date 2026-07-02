#!/usr/bin/env python3
import sys
import os
import re

TEMPLATES_DIR = os.path.expanduser('~/.config/theme-templates')

TEMPLATE_OUTPUTS = [
    ('dunstrc.j2',            '~/.config/dunst/dunstrc'),
    ('rofi.rasi.j2',          '~/.config/rofi/theme.rasi'),
    ('yazi.toml.j2',          '~/.config/yazi/theme.toml'),
    ('gtk2.j2',               '~/.gtkrc-2.0'),
    ('gtk3.ini.j2',           '~/.config/gtk-3.0/settings.ini'),
    ('gtk3.ini.j2',           '~/.config/gtk-4.0/settings.ini'),
    ('gtk.css.j2',            '~/.config/gtk-3.0/gtk.css'),
    ('gtk.css.j2',            '~/.config/gtk-4.0/gtk.css'),
    ('qt5ct-colors.conf.j2',  '~/.config/qt5ct/colors/dwm.conf'),
    ('qt5ct-colors.conf.j2',  '~/.config/qt6ct/colors/dwm.conf'),
    ('qt5ct.conf.j2',         '~/.config/qt5ct/qt5ct.conf'),
    ('qt6ct.conf.j2',         '~/.config/qt6ct/qt6ct.conf'),
    ('xsettingsd.conf.j2',    '~/.config/xsettingsd/xsettingsd.conf'),
    ('kitty.conf.j2',         '~/.config/kitty/theme.conf'),
    ('fcitx5.conf.j2',        '~/.local/share/fcitx5/themes/dwm/theme.conf'),
    ('fcitx5-dark.conf.j2',   '~/.local/share/fcitx5/themes/dwm-dark/theme.conf'),
    ('nvim.lua.j2',            '~/.config/nvim/theme.lua'),
]


def hex_to_rgb(hex_color):
    hex_color = hex_color.strip().lstrip('#')
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)
    return '{}, {}, {}'.format(r, g, b)


def hex_to_rgb_s(hex_color):
    """hex_to_rgb with semicolons (for ANSI escape sequences)"""
    hex_color = hex_color.strip().lstrip('#')
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)
    return '{};{};{}'.format(r, g, b)


def hex_to_argb(hex_color):
    hex_color = hex_color.strip().lstrip('#')
    return '#ff{}'.format(hex_color)


def hex_to_argb_50(hex_color):
    """50% alpha ARGB"""
    hex_color = hex_color.strip().lstrip('#')
    return '#80{}'.format(hex_color)


FILTERS = {
    'hex_to_rgb': hex_to_rgb,
    'hex_to_rgb_s': hex_to_rgb_s,
    'hex_to_argb': hex_to_argb,
    'hex_to_argb_50': hex_to_argb_50,
}


def parse_palette(filepath):
    palette = {}
    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if line.startswith('#define'):
                rest = line[8:].strip()
                parts = rest.split(None, 1)
                if len(parts) >= 2:
                    palette[parts[0]] = parts[1]
                elif len(parts) == 1:
                    palette[parts[0]] = ''
    return palette


MISSING_VARS = set()

def render_template(text, context, tpl_name=''):
    def replacer(match):
        global MISSING_VARS
        expr = match.group(1).strip()
        if '|' in expr:
            var_name, filter_name = (x.strip() for x in expr.split('|', 1))
            if var_name not in context:
                MISSING_VARS.add(var_name)
                return ''
            value = context[var_name]
            if filter_name in FILTERS:
                return FILTERS[filter_name](value)
            return value
        if expr not in context:
            MISSING_VARS.add(expr)
            return ''
        return context[expr]
    return re.sub(r'\{\{(.*?)\}\}', replacer, text)


def main():
    if len(sys.argv) < 2:
        print("Usage: generate-app-themes.py <theme_file>", file=sys.stderr)
        sys.exit(1)

    theme_file = sys.argv[1]
    if not os.path.isfile(theme_file):
        print("Error: Theme file not found: {}".format(theme_file), file=sys.stderr)
        sys.exit(1)

    if not os.path.isdir(TEMPLATES_DIR):
        print("Error: Templates directory not found: {}".format(TEMPLATES_DIR), file=sys.stderr)
        sys.exit(1)

    palette = parse_palette(theme_file)
    palette['QT5CT_COLOR_DIR'] = os.path.expanduser('~/.config/qt5ct/colors')
    palette['QT6CT_COLOR_DIR'] = os.path.expanduser('~/.config/qt6ct/colors')

    # Pick the correct variant based on DARK_THEME flag:
    #   DARK_THEME=0 (prefer light) → *-light variant (no suffix)
    #   DARK_THEME=1 (prefer dark)  → *-dark variant
    dark_theme = palette.get('DARK_THEME', '0')
    variant_suffix = '-dark' if dark_theme == '1' else ''

    for tpl_name, rel_output in TEMPLATE_OUTPUTS:
        # Override template based on dark/light preference
        if rel_output.endswith('/gtk.css'):
            tpl_name = 'gtk-dark.css.j2' if dark_theme == '1' else 'gtk.css.j2'
        elif rel_output.endswith('/gtk-dark.css'):
            continue
        elif 'qt5ct-colors' in tpl_name and not 'dark' in tpl_name:
            tpl_name = 'qt5ct-colors{}.conf.j2'.format(variant_suffix)

        tpl_path = os.path.join(TEMPLATES_DIR, tpl_name)
        if not os.path.isfile(tpl_path):
            continue

        global MISSING_VARS
        MISSING_VARS.clear()

        with open(tpl_path) as f:
            template_text = f.read()

        rendered = render_template(template_text, palette, tpl_name)

        if MISSING_VARS:
            print("Warning: {}: missing macros: {}".format(tpl_name, ', '.join(sorted(MISSING_VARS))), file=sys.stderr)

        output = os.path.expanduser(rel_output)
        os.makedirs(os.path.dirname(output), exist_ok=True)
        if os.path.islink(output):
            os.unlink(output)

        with open(output, 'w') as f:
            f.write(rendered)

    print("Theme configs generated successfully from: {}".format(os.path.basename(theme_file)))


if __name__ == '__main__':
    main()
