import re
import unittest
from pathlib import Path


CONFIG = (
    Path(__file__).parents[1] / "home/dot_config/zellij/config.kdl"
).read_text()


class ZellijModeCycleTest(unittest.TestCase):
    modes = [
        "normal",
        "locked",
        "resize",
        "pane",
        "tab",
        "scroll",
        "entersearch",
        "search",
        "renametab",
        "renamepane",
        "session",
        "move",
        "prompt",
        "tmux",
    ]

    def test_meh_page_up_cycles_backwards_through_modes(self):
        for index, mode in enumerate(self.modes):
            previous = self.modes[index - 1]
            mode_block = re.search(
                rf"(?ms)^    {mode} \{{(.*?)(?=^    \}})",
                CONFIG,
            )
            self.assertIsNotNone(mode_block, f"missing {mode} mode block")
            self.assertIn(
                f'bind "Ctrl Alt Shift PageUp" {{ SwitchToMode "{previous}"; }}',
                mode_block.group(1),
                f"{mode} should cycle back to {previous}",
            )

    def test_meh_page_down_cycles_forwards_through_modes(self):
        for index, mode in enumerate(self.modes):
            following = self.modes[(index + 1) % len(self.modes)]
            mode_block = re.search(
                rf"(?ms)^    {mode} \{{(.*?)(?=^    \}})",
                CONFIG,
            )
            self.assertIsNotNone(mode_block, f"missing {mode} mode block")
            self.assertIn(
                f'bind "Ctrl Alt Shift PageDown" {{ SwitchToMode "{following}"; }}',
                mode_block.group(1),
                f"{mode} should cycle forward to {following}",
            )


if __name__ == "__main__":
    unittest.main()
