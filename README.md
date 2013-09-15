An interactive substitute/replace script.

Regex-based substitutions are applied across
files in the given directory.

perl isub.pl [options] <pattern> <repl> <dir>

options:

  --help              Print this message and exit
  --doall             Perform all replacements without asking
  --filter <regex>    Only process filenames that match <regex>
