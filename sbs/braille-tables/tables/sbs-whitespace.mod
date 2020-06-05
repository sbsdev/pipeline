#-------------------------------------------------------------------------------
#
#  sbs-whitespace.mod
#
#-------------------------------------------------------------------------------

# Mehrfach-Leerschläge eliminieren
noback correct [$s]$s. ?

# normalisiere Zeilenumbrüche in Leerschlägen
noback correct "\n" \s
