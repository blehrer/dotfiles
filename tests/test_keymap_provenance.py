import unittest
from pathlib import Path

REPO = Path(__file__).parents[1]
ZELLIJ = (REPO / "home/dot_config/zellij/config.kdl").read_text()
GHOSTTY = (REPO / "home/dot_config/ghostty/config").read_text()

ZELLIJ_MARKER = "// keymap-ref: zellij-mode-cycle"
ZELLIJ_MODE_CYCLE_COMMENT = "// Meh PageUp/PageDown mode-cycle bindings repeat in every mode below."
ZELLIJ_BLOCK = "    normal {"
GHOSTTY_MARKER = "# keymap-ref: ghostty-f5-reload"
GHOSTTY_BINDING = "keybind = unconsumed:f5=reload_config"
GHOSTTY_CONSUMED_ESCAPE_BINDING = "keybind = escape=end_search"
GHOSTTY_SUPER_DIRECTION_BINDINGS = (
    "keybind = super+h=csi:104;9u",
    "keybind = super+j=csi:106;9u",
    "keybind = super+k=csi:107;9u",
    "keybind = super+l=csi:108;9u",
)
ZELLIJ_SUPER_DIRECTION_BINDINGS = (
    '        bind "Super h" { MoveFocusOrTab "left"; }',
    '        bind "Super j" { MoveFocus "down"; }',
    '        bind "Super k" { MoveFocus "up"; }',
    '        bind "Super l" { MoveFocusOrTab "right"; }',
)
ZELLIJ_ALT_DIRECTION_BINDINGS = (
    '        bind "Alt h" { MoveFocusOrTab "left"; }',
    '        bind "Alt j" { MoveFocus "down"; }',
    '        bind "Alt k" { MoveFocus "up"; }',
    '        bind "Alt l" { MoveFocusOrTab "right"; }',
)
ZELLIJ_REMOVED_MEH_OP_BINDINGS = (
    'bind "Ctrl Alt Shift o"',
    'bind "Ctrl Alt Shift p"',
)
GHOSTTY_REPLACED_BINDINGS = (
    "keybind = super+j=scroll_to_selection",
    "keybind = super+k=clear_screen",
    "keybind = super+t=new_tab",
)
GHOSTTY_NATIVE_LINK = (
    REPO
    / "home/Library/Application Support/com.mitchellh.ghostty/symlink_config.ghostty"
)
ZELLIJ_FORGOT_MODES = (
    "normal",
    "locked",
    "pane",
    "tab",
    "resize",
    "move",
    "scroll",
    "search",
    "session",
    "tmux",
)
ZELLIJ_FAMILY_CATALOG = (
    (
        "// keymap-ref: zellij-keybind-tooltip",
        '    forgot-normal location="file:~/.config/zellij/plugins/zellij_forgot.wasm" {',
    ),
    ("// keymap-ref: zellij-pane-mode", "    pane {"),
    ("// keymap-ref: zellij-tab-mode", "    tab {"),
    ("// keymap-ref: zellij-resize-mode", "    resize {"),
    ("// keymap-ref: zellij-move-mode", "    move {"),
    ("// keymap-ref: zellij-scroll-search-modes", "    scroll {"),
    ("// keymap-ref: zellij-session-mode", "    session {"),
    (
        "// keymap-ref: zellij-quick-pane-tab",
        '        bind "Super Shift ]" { MoveFocusOrTab "right"; }',
    ),
    (
        "// keymap-ref: zellij-quick-resize",
        '        bind "Ctrl Alt Shift  +" { Resize "Increase"; }',
    ),
    (
        "// keymap-ref: zellij-mode-entry",
        '    shared_except "locked" "entersearch" "renametab" "renamepane" "move" "prompt" "tmux" {',
    ),
    (
        "// keymap-ref: zellij-new-tab",
        '        bind "Super t" { NewTab; SwitchToMode "normal"; }',
    ),
    ('// keymap-ref: zellij-alt-quick-actions', '    shared_except "normal" "locked" {'),
    ('// keymap-ref: zellij-scroll-navigation', '    shared_among "scroll" "search" {'),
    ("// keymap-ref: zellij-rename-modes", "    renametab {"),
    ("// keymap-ref: zellij-tmux-mode", "    tmux {"),
)
AEROSPACE = (REPO / "home/dot_config/aerospace/aerospace.toml").read_text()
AEROSPACE_FAMILY_CATALOG = (
    ("# keymap-ref: aerospace-layout-cycle", "    alt-tab = 'layout horizontal vertical'"),
    (
        "# keymap-ref: aerospace-focus-cycle",
        "    ctrl-tab = 'focus --boundaries workspace --boundaries-action wrap-around-the-workspace dfs-next'",
    ),
    ("# keymap-ref: aerospace-directional-focus", "    alt-h = 'focus left'"),
    ("# keymap-ref: aerospace-directional-move", "    alt-shift-h = 'move left'"),
    ("# keymap-ref: aerospace-resize", "    alt-minus = 'resize smart -50'"),
    ("# keymap-ref: aerospace-workspaces", "    ctrl-alt-y = 'workspace 1'"),
    ("# keymap-ref: aerospace-service-mode", "    alt-shift-quote = 'mode service'"),
)


class KeymapProvenanceTest(unittest.TestCase):
    def test_zellij_marker_once_and_adjacent_to_normal_block(self):
        self.assertEqual(ZELLIJ.count(ZELLIJ_MARKER), 1)
        idx = ZELLIJ.index(ZELLIJ_MARKER)
        after_marker = ZELLIJ[idx + len(ZELLIJ_MARKER) :]
        self.assertTrue(
            after_marker.startswith("\n" + ZELLIJ_BLOCK),
            "marker must be immediately above normal { mode block",
        )

    def test_zellij_mode_cycle_comment_above_marker(self):
        self.assertEqual(ZELLIJ.count(ZELLIJ_MODE_CYCLE_COMMENT), 1)
        comment_idx = ZELLIJ.index(ZELLIJ_MODE_CYCLE_COMMENT)
        marker_idx = ZELLIJ.index(ZELLIJ_MARKER)
        self.assertLess(comment_idx, marker_idx)
        self.assertIn(
            ZELLIJ_MODE_CYCLE_COMMENT + "\n    " + ZELLIJ_MARKER,
            ZELLIJ,
        )

    def test_ghostty_f5_reload_marker_absent(self):
        self.assertNotIn(GHOSTTY_MARKER, GHOSTTY)
        self.assertIn(GHOSTTY_BINDING, GHOSTTY)

    def test_ghostty_does_not_consume_escape(self):
        self.assertNotIn(GHOSTTY_CONSUMED_ESCAPE_BINDING, GHOSTTY)

    def test_ghostty_super_directions_and_native_config_link(self):
        self.assertIn("keybind = clear", GHOSTTY)
        for binding in GHOSTTY_SUPER_DIRECTION_BINDINGS:
            with self.subTest(binding=binding):
                self.assertIn(binding, GHOSTTY)
        for binding in GHOSTTY_REPLACED_BINDINGS:
            with self.subTest(binding=binding):
                self.assertNotIn(binding, GHOSTTY)
        self.assertEqual(
            GHOSTTY_NATIVE_LINK.read_text().strip(),
            "../../../.config/ghostty/config",
        )

    def test_zellij_super_directions_replace_shadowed_alt_directions(self):
        normal_locked = ZELLIJ.split(
            '    shared_among "normal" "locked" {', 1
        )[1].split("\n    }", 1)[0]
        for binding in ZELLIJ_SUPER_DIRECTION_BINDINGS:
            with self.subTest(binding=binding):
                self.assertIn(binding, normal_locked)
        for binding in ZELLIJ_ALT_DIRECTION_BINDINGS:
            with self.subTest(binding=binding):
                self.assertNotIn(binding, ZELLIJ)

    def test_zellij_has_no_meh_o_or_p_bindings(self):
        for binding in ZELLIJ_REMOVED_MEH_OP_BINDINGS:
            with self.subTest(binding=binding):
                self.assertNotIn(binding, ZELLIJ)

    def test_zellij_forgot_has_one_manual_configuration_per_non_editing_mode(self):
        load_plugins = ZELLIJ.split("load_plugins {", 1)[1].split("\n}", 1)[0]
        self.assertNotIn('tooltip "Super /"', ZELLIJ)
        self.assertNotIn('compact-bar location="zellij:compact-bar"', load_plugins)
        self.assertEqual(ZELLIJ.count('bind "Super /"'), len(ZELLIJ_FORGOT_MODES))
        for mode in ZELLIJ_FORGOT_MODES:
            with self.subTest(mode=mode):
                self.assertIn(
                    f'bind "Super /" {{\n'
                    f'            LaunchOrFocusPlugin "forgot-{mode}" {{\n'
                    "                floating true\n"
                    "                move_to_focused_tab true\n"
                    f'                title "{mode.upper()}"\n'
                    "            }\n"
                    "        }",
                    ZELLIJ,
                )
                alias = ZELLIJ.split(
                    f'forgot-{mode} location="file:~/.config/zellij/plugins/zellij_forgot.wasm" {{',
                    1,
                )[1].split("\n    }", 1)[0]
                self.assertIn('"LOAD_ZELLIJ_BINDINGS" "false"', alias)
                self.assertNotIn('"Mode"', alias)

    def test_zellij_family_markers_once_and_adjacent_to_bindings(self):
        for marker, binding in ZELLIJ_FAMILY_CATALOG:
            with self.subTest(marker=marker):
                self.assertEqual(ZELLIJ.count(marker), 1, marker)
                idx = ZELLIJ.index(marker)
                after_marker = ZELLIJ[idx + len(marker) :]
                self.assertTrue(
                    after_marker.startswith("\n" + binding),
                    f"{marker} must be immediately above binding",
                )

    def test_aerospace_family_markers_once_and_adjacent_to_bindings(self):
        for marker, binding in AEROSPACE_FAMILY_CATALOG:
            with self.subTest(marker=marker):
                self.assertEqual(AEROSPACE.count(marker), 1, marker)
                idx = AEROSPACE.index(marker)
                after_marker = AEROSPACE[idx + len(marker) :]
                self.assertTrue(
                    after_marker.startswith("\n" + binding),
                    f"{marker} must be immediately above binding",
                )


if __name__ == "__main__":
    unittest.main()
