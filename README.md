# gnugo.js
port gnugo to javascript with emscripten

`build_gnugo.sh` is used to generate necessary step database

`rebuild_gnugo_with_em.sh` is used to generate `gnugo.js`

`gnugowrapper.c` is the main source file for `gnugo.js` to export APIs from `GNU-Go` (much code copied from `play_ascii.c` from `gnugo` source)

Currently we support APIs:

- `Module._initializeGoGame(boardSize, komi, handicap, randomSeed)`
- `Module._finalizeGoGame()`
- `Module._getBoard(i, j)`
- `Module._isLastMove(i, j)`
- `Module._genNextStep()`: make computer put current stone at a proper place
- `Module._moveTo(i, j)`: put current stone at (i,j), where 0 < i,j < size

after compiled out `gnugo.js`, try `test.html` with it.
