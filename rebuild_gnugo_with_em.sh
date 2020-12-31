#!/bin/bash

set -xe

SELF=$((cd `dirname $0`; pwd)

mkdir -p $SELF/gnugo-3.8/dist/reb/{utils,sgf,engine,patterns}
pushd $SELF/gnugo-3.8/dist

find $SELF/gnugo-3.8/dist/reb -name "*.a" -type f | xargs rm -f
find $SELF/gnugo-3.8/dist/reb -name "*.o" -type f | xargs rm -f

A=$SELF/gnugo-3.8/dist/reb/utils
B=$SELF/gnugo-3.8/utils
emcc -DHAVE_CONFIG_H -I.. -c -o $A/getopt.o   $B/getopt.c
emcc -DHAVE_CONFIG_H -I.. -c -o $A/getopt1.o  $B/getopt1.c
emcc -DHAVE_CONFIG_H -I.. -c -o $A/random.o   $B/random.c
emcc -DHAVE_CONFIG_H -I.. -c -o $A/gg_utils.o $B/gg_utils.c
pushd $A
emar cru libutils.a getopt.o getopt1.o random.o gg_utils.o
popd

A=$SELF/gnugo-3.8/dist/reb/sgf
B=$SELF/gnugo-3.8/sgf
emcc -DHAVE_CONFIG_H -I.. -I../utils -c -o $A/sgf_utils.o $B/sgf_utils.c
emcc -DHAVE_CONFIG_H -I.. -I../utils -c -o $A/sgfnode.o   $B/sgfnode.c
emcc -DHAVE_CONFIG_H -I.. -I../utils -c -o $A/sgftree.o   $B/sgftree.c
pushd $A
emar cru libsgf.a sgf_utils.o sgfnode.o sgftree.o
popd

A=$SELF/gnugo-3.8/dist/reb/engine
B=$SELF/gnugo-3.8/engine
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/aftermath.o     $B/aftermath.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/board.o         $B/board.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/boardlib.o      $B/boardlib.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/breakin.o       $B/breakin.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/cache.o         $B/cache.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/clock.o         $B/clock.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/combination.o   $B/combination.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/dragon.o        $B/dragon.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/endgame.o       $B/endgame.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/filllib.o       $B/filllib.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/fuseki.o        $B/fuseki.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/genmove.o       $B/genmove.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/globals.o       $B/globals.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/handicap.o      $B/handicap.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/hash.o          $B/hash.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/influence.o     $B/influence.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/interface.o     $B/interface.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/matchpat.o      $B/matchpat.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/montecarlo.o    $B/montecarlo.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/move_reasons.o  $B/move_reasons.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/movelist.o      $B/movelist.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/optics.o        $B/optics.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/oracle.o        $B/oracle.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/owl.o           $B/owl.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/persistent.o    $B/persistent.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/printutils.o    $B/printutils.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/readconnect.o   $B/readconnect.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/reading.o       $B/reading.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/semeai.o        $B/semeai.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/sgfdecide.o     $B/sgfdecide.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/sgffile.o       $B/sgffile.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/shapes.o        $B/shapes.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/showbord.o      $B/showbord.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/surround.o      $B/surround.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/unconditional.o $B/unconditional.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/utils.o         $B/utils.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/value_moves.o   $B/value_moves.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../sgf -I../utils   -c -o $A/worm.o          $B/worm.c;
pushd $A
ar cru libengine.a aftermath.o board.o boardlib.o breakin.o cache.o clock.o combination.o dragon.o endgame.o filllib.o fuseki.o genmove.o globals.o handicap.o hash.o influence.o interface.o matchpat.o montecarlo.o move_reasons.o movelist.o optics.o oracle.o owl.o persistent.o printutils.o readconnect.o reading.o semeai.o sgfdecide.o sgffile.o shapes.o showbord.o surround.o unconditional.o utils.o value_moves.o worm.o 
popd

A=$SELF/gnugo-3.8/dist/reb/patterns
B=$SELF/gnugo-3.8/patterns
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/connections.o    $B/connections.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/helpers.o        $B/helpers.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/transform.o      $B/transform.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/conn.o           $B/conn.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/patterns.o       $B/patterns.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/apatterns.o      $B/apatterns.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/dpatterns.o      $B/dpatterns.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/eyes.o           $B/eyes.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/influence.o      $B/influence.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/barriers.o       $B/barriers.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/endgame.o        $B/endgame.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/aa_attackpat.o   $B/aa_attackpat.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/owl_attackpat.o  $B/owl_attackpat.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/owl_vital_apat.o $B/owl_vital_apat.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/owl_defendpat.o  $B/owl_defendpat.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/fusekipat.o      $B/fusekipat.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/fuseki9.o        $B/fuseki9.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/fuseki13.o       $B/fuseki13.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/fuseki19.o       $B/fuseki19.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/josekidb.o       $B/josekidb.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/handipat.o       $B/handipat.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/oraclepat.o      $B/oraclepat.c;
emcc -DHAVE_CONFIG_H -I.. -I../engine -I../patterns -I../utils -I../sgf   -c -o $A/mcpat.o          $B/mcpat.c;
pushd $A
ar cru libpatterns.a connections.o helpers.o transform.o conn.o patterns.o apatterns.o dpatterns.o eyes.o influence.o barriers.o endgame.o aa_attackpat.o owl_attackpat.o owl_vital_apat.o owl_defendpat.o fusekipat.o fuseki9.o fuseki13.o fuseki19.o josekidb.o handipat.o oraclepat.o mcpat.o 
popd

cp $SELF/gnugowrapper.c $SELF/local/gnugo-3.8/dist/
emcc -DHAVE_CONFIG_H -I.. -I.. -I../utils -I../patterns -I../sgf -I../engine -I../interface \
gnugowrapper.c \
reb/engine/libengine.a \
reb/patterns/libpatterns.a \
reb/sgf/libsgf.a \
reb/utils/libutils.a \
-lm \
-s WASM=0 \
-s INITIAL_MEMORY=31457280 \
-s ALLOW_MEMORY_GROWTH=1
mv a.out.js $SELF/local/gnugo.js

popd
