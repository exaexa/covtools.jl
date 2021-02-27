# covtools.jl

Commandline tools for exploring test coverage of Julia stuff. This is useful if you don't have a code-coverage-displaying IDE and refuse to wait for CI to show you your lovely 100% coverages in codecov.

## How-to

### 1. Run the tests with `--coverage`

```
$ cd YourPackage
$ find . -name '*.cov' -exec rm {} \;   # remove the previous coverage files; `git clean -f` might be sufficient too.
$ julia
pkg] dev --local .                    # develop YourPackage locally (this only needs to be done once per project)
pkg] test --coverage YourPackage      # run the tests and output up-to-date coverage files
```

this should generate a lot of `.cov` files scattered around your normal source files.

### 2. Use `coverstat.jl` to get testing statistics
```
$ coverstat.jl src/
       7      75      68  90.67% (TOTAL)
       7      75      68  90.67% src
               1       1 100.00% src/YourPackage.jl
       5      57      52  91.23% src/readinput.jl
               4       4 100.00% src/structs.jl
              11      11 100.00% src/utils.jl
       2       2           0.00% src/version.jl
```
(The columns are in fact colored, it looks much better in the commandline. The first column is "untested lines", then "total lines", "tested lines", "percent coverage" and file/subdirectory name.)

### 3. Use `cover.jl` to find untested lines
If you find a problematic file, you can use `cover.jl` to find the lines that need testing:
```
$ cover.jl src/readinput.jl
-
-      const X = Y            # untested line
- 
1      testedFunctionCall()
0 ***  untestedFunctionCall()
0 ***  moreUntestedCode
```

(The first column is separated by a tab and contains either `-` for lines irrelevant for testing coverage, `0` (highlighted with `***`) for lines that were not executed in tests, and a number of executions for lines that were tested.)
