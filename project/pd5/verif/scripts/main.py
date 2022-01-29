import os
import re
import sys
import shlex
import subprocess

def run(path : str):
    filename = path.split("/")[-1]
    print(f"Running {filename}")

    output_name = "txt/" + filename.strip(".x") + ".txt"
    command = shlex.split(f"make -s run IVERILOG=1 TEST=test_pd MEM_PATH={path}")
    output = subprocess.check_output(command, encoding="UTF-8")
    with open(output_name, "w") as fd:
        fd.write(output)

    decode_path = path.strip(".x") + ".d"
    fail_address = ""
    pass_address = ""
    with open(decode_path, "r") as fd:
        file_contents = fd.read()
        match = re.search(r".*fail.*:", file_contents)
        if match:
            fail_address = match.group(0).split(" ")[0]
        match = re.search(r".*pass.*:", file_contents)
        if match:
            pass_address = match.group(0).split(" ")[0]

    if len(fail_address) == 0:
        print(f"No failure case for {filename}")
        return -1
    if len(pass_address) == 0:
        print(f"No pass address found for {filename}")
        return -1

    with open(output_name, "r") as fd:
        file_contents = fd.read()
        match = re.search(r"\[E\] {}.*".format(fail_address), file_contents)
        if match:
            print(f"Failure found for test {filename} as indicated by jump to <fail>:\n{match.group(0)}\n")
    
        match = re.search(r"\[E\] {}.*".format(pass_address), file_contents)
        if not match:
            print(f"Failure found for test {filename} as indicated by no jump to <pass>:\n{pass_address}\n")

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("hye")
        print("Usage: test.py <path to .x file>")
        exit(-1)
    
    paths = [os.path.realpath(p) for p in sys.argv[1:]]
    i = 0
    while i < len(paths):
        if not os.path.isfile(paths[i]):
            print(f"Path to non-existent file {path[i]}")
            paths.pop(i)
        else:
            i += 1

    if len(paths) == 0:
        print("No valid paths present to test")
        exit(-2)

    if not os.path.isdir("txt"):
        os.makedirs("txt")

    for path in paths:
        run(path)

