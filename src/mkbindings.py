import subprocess

from pathlib import Path
from dataclasses import dataclass

ROOT = (Path(__file__).parent / "bindings").resolve()
PATCH_TYPE = "PATCH_TYPE"
LINE_REPLACE = "LINE_REPLACE"
LINE_DELETE = "LINE_DELETE"
LINE_APPEND = "LINE_APPEND"
LINE_NO = "LINE_NO"
EXPECT = "EXPECT"
CONTENT = "CONTENT"

BINDINGS = [
    (
        ROOT / "sys" / "mman.h",
        ROOT / "sys" / "mman.zig",
        []
    ),
    (
        ROOT / "setjmp.h",
        ROOT / "setjmp.zig",
        []
    ),
]

@dataclass
class Binding:
    path: str
    patches: list[dict]

def generate_bindings(bindings):
    for (c_path, zig_path, zig_patches) in bindings:
        path = str(c_path.resolve())
        print(f"Generating bindings for {path}...")

        cmd = ["zig", "translate-c", path]
        print(f"    Running `{repr(cmd)}` ...")
        proc = subprocess.run(cmd, capture_output=True)
        if (proc.returncode != 0):
            print(f"        Failed with exit code '{proc.returncode}'")
            exit(1)

        zig_src_lines = ["<<< synthetic line added to enable 0-based indexing, remove before writing >>>\n"] + list(proc.stdout.decode("utf-8").split("\n"))

        for (i, patch) in enumerate(zig_patches):
            if (i == 0):
                print(f"    Applying source code patches to {zig_path} ...")
            if (patch[PATCH_TYPE] == LINE_REPLACE):
                line = patch[LINE_NO]
                expect = patch[EXPECT]
                content = patch[CONTENT]
                assert(expect in zig_src_lines[line])
                whitespace_prefix = zig_src_lines[line][0:(zig_src_lines[line].find(expect))]
                comment = f" // Patch [{i}] created by {__file__}"
                zig_src_lines[line] = whitespace_prefix + content + comment
            elif (patch[PATCH_TYPE] == LINE_DELETE):
                line = patch[LINE_NO]
                assert(line > 0 and line < len(zig_src_lines))
                _ = zig_src_lines.pop(line)
            elif (patch[PATCH_TYPE] == LINE_APPEND):
                content = patch[CONTENT]
                comment = f" // Patch [{i}] created by {__file__}"
                zig_src_lines.append(content + comment)
            else:
                print(f"        Failed to apply patch [{i}], unknown {PATCH_TYPE}: '{patch[PATCH_TYPE]}'")
                exit(1);

        print(f"    Writing translation to {zig_path} ...")
        zig_src_content = "\n".join(zig_src_lines[1:])
        zig_path.write_text(zig_src_content, encoding="utf-8")
        print()

if __name__ == "__main__":
    generate_bindings(BINDINGS)
