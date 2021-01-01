#include "emscripten.h"

#include "gnugo.h"

#include <stdio.h>

#include "liberty.h"
#include "interface.h"
#include "sgftree.h"
#include "gg_utils.h"

static Gameinfo globalGameInfo;
static SGFTree  globalSgfTree;
static SGFTree *globalRoot;
static int globalPasses = 0;

void EMSCRIPTEN_KEEPALIVE initializeGoGame(int boardSize, int komi, int handicap, int seed) {
   char debuginfluenceMove[4] = "\0";

   sgftree_clear(&globalSgfTree);
   gameinfo_clear(&globalGameInfo);
   globalGameInfo.handicap = handicap;

   // ko_rule = SIMPLE, NONE, PSK, SSK
   // use_monte_carlo_genmove
   // set_level(), set_min_level(), set_max_level(), autolevel_on
   // josekidb, disable_fuseki, fusekidb
   // mandated_depth, mandated_backfill_depth, mandated_fourlib_depth, mandated_ko_depth
   // mandated_owl_reading_depth, mandated_owl_node_limit,
   // mandated_owl_branch_depth, mandated_owl_distrust_depth
   // mandated_aa_depth, mandated_superstring_depth,
   // mandated_break_chain_depth, mandated_backfill2_depth,
   // mandated_branch_depth
   // resign_allowed
   // suicide_rule = ALL_ALLOWED, ALLOWED, FORBIDDEN
   // large_scale, cosmic_gnugo, experimental_break_in, alternate_connections,
   // experimental_connections, mandated_semeai_node_limit, experimental_owl_ext
   // metamachine, owl_threats
   // orientation = 0, 1, 2, 3, 4, 5, 6, 7
   chinese_rules = 1;

   if (!check_boardsize(boardSize, stderr)) {
      printf("invalid boardSize=%d\n", boardSize);
      return;
   }
   gnugo_clear_board(boardSize);

   /* Default hash table size in megabytes; DEFAULT_MEMORY in config.h */
   float memory = (float) DEFAULT_MEMORY;
   /* if would like to have different game, seed = new Date().getTime() */
   init_gnugo(memory, seed);

   /*
    * Monte Carlo pattern name: use `gnugo --mc-list-patterns` to list the available names
    * // if(!choose_mc_patterns(mc_pattern_name)) {}
    */
   sgftreeCreateHeaderNode(&globalSgfTree, boardSize, komi, handicap);
   globalGameInfo.game_record = globalSgfTree;

   if (debuginfluenceMove[0]) {
      int pos = string_to_location(boardSize, debuginfluenceMove);
      debug_influence_move(pos);
   }
   globalGameInfo.computer_player = EMPTY; /* EMPTY, BLACK, WHITE */

   // then play_ascii(&globalSgfTree, &globalGameInfo, infilename, untilstring);
   globalRoot = &globalSgfTree;
   // sgfGetIntProperty(globalSgfTree.root, "SZ", &boardSize)
   if (globalGameInfo.handicap == 0) {
      globalGameInfo.to_move = BLACK;
   } else {
      globalGameInfo.handicap = place_fixed_handicap(globalGameInfo.handicap);
      globalGameInfo.to_move = WHITE;
   }

   sgf_write_header(globalSgfTree.root, 1, get_random_seed(), komi, globalGameInfo.handicap, get_level(), chinese_rules);
   if (globalGameInfo.handicap > 0) sgffile_recordboard(globalSgfTree.root);
}

/*
 * while (state == 1) {
 *    state = 0
 *    current_score_estimate = NO_SCORE;
 *    resignation_allowed = 1;
 *    gameinfo_print(gameinfo);
 *
 *    computer_move(gameinfo, &passes)
 *
 *    ascii_showboard()
 *    get_command(command) ->
 *    RESIGN, END, EXIT, QUIT, HELP, CMD_HELPDEBUG, SHOWBOARD
 *    INFO, SETBOARDSIZE, SETHANDICAP*, FREEHANDICAP*, SETKOMI*
 *    SETDEPTH, SETLEVEL, DISPLAY, FORCE(MOVE, PASS, ...),
 *    MOVE, PASS, PLAY, PLAYBLACK, PLAYWHITE, SWITCH,
 *    UNDO, CMD_BACK, CMD_FORWARD, CMD_LAST, COMMENT, SCORE
 *    CMD_DEAD, CMD_CAPTURE, CMD_DEFEND, CMD_GOTO, CMD_SAVE, CMD_LOAD,
 *    CMD_LISTDRAGONS
 *    *: should not change after init
 *
 *    SETBOARDSIZE -> {
 *       clear_board();
 *       gameinfo->handicap = place_fixed_handicap(gameinfo->handicap);
 *       sgfOverwritePropertyInt(sgftree.root, "SZ", board_size);
 *       sgfOverwritePropertyInt(sgftree.root, "HA", gameinfo->handicap);
 *    }
 *
 *    MOVE { state = do_move(gameinfo, command, &passes, 0); }
 *    PASS { state = do_pass(gameinfo, &passes, 0); }
 *    PLAY { for 0..n
 *       gameinfo->computer_player = = OTHER_COLOR(gameinfo->computer_player);
 *       state = computer_move(gameinfo, &passes);
 *       if (state) break;
 *       if (passes >= 2) break;
 *    }
 * }
 */

static int
ascii_endgame(Gameinfo *gameinfo, int reason)
{
  char line[80];
  char *line_ptr;
  char *command;
  char *tmpstring;
  int state = 0;

  if (reason == 0) {		/* Two passes, game is over. */
    who_wins(gameinfo->computer_player, stdout);
    printf("\nIf you disagree, we may count the game together.\n");

    sgftreeWriteResult(&globalSgfTree, (white_score + black_score)/2.0, 1);
  }
  else {
    int color = OTHER_COLOR(gameinfo->to_move);

    if (reason == 1)		/* Our opponent has resigned. */
      printf("GNU Go wins by resignation.\n");
    else			/* We have resigned. */
      printf("You win by resignation.\n");

    printf("Result: %c+Resign\n\n", color == WHITE ? 'W' : 'B');
    sgftreeWriteResult(&globalSgfTree, color == WHITE ? 1000.0 : -1000.0, 1);
  }
  return state;
}

static int privateComputerMove(Gameinfo *gameinfo, int *passes)
{
   int move;
   float move_value;
   int resign;
   // int resignation_declined = 0;
   float upper_bound, lower_bound;

   /* Generate computer move. */
   if (autolevel_on) adjust_level_offset(gameinfo->to_move);
   move = genmove(gameinfo->to_move, &move_value, &resign);
   /*
   if (resignation_allowed && resign) {
     int state = ascii_endgame(gameinfo, 2);
     if (state != -1)
       return state;

     // The opponent declined resignation. Remember not to resign again.
     resignation_allowed = 0;
     resignation_declined = 1;
   }

   if (showscore) {
     gnugo_estimate_score(&upper_bound, &lower_bound);
     current_score_estimate = (int) ((lower_bound + upper_bound) / 2.0);
   }*/
   
   mprintf("%s(%d): %1m\n", color_to_string(gameinfo->to_move), movenum + 1, move);
   if (is_pass(move)) (*passes)++;
                 else *passes = 0;

   gnugo_play_move(move, gameinfo->to_move);
   sgffile_add_debuginfo(globalSgfTree.lastnode, move_value);
   sgftreeAddPlay(&globalSgfTree, gameinfo->to_move, I(move), J(move));
   // if (resignation_declined) sgftreeAddComment(&globalSgfTree, "GNU Go resignation was declined");
   sgffile_output(&globalSgfTree);

   gameinfo->to_move = OTHER_COLOR(gameinfo->to_move);
   return 0;
}

int EMSCRIPTEN_KEEPALIVE genNextStep() {
   globalGameInfo.computer_player = OTHER_COLOR(globalGameInfo.computer_player);
   return privateComputerMove(&globalGameInfo, &globalPasses);
}

int EMSCRIPTEN_KEEPALIVE isLastMove(int i, int j) {
   int last_move = get_last_move();
   return (POS(i, j) == last_move);
}

int EMSCRIPTEN_KEEPALIVE getBoard(int i, int j) {
   return BOARD(i, j);
}

int EMSCRIPTEN_KEEPALIVE moveTo(int i, int j) {
   int boardSize = board_size;
   sgfGetIntProperty(globalSgfTree.root, "SZ", &boardSize);
   if (i < 0 || i >= boardSize) return -1;
   if (j < 0 || j >= boardSize) return -1;
   int move = POS(i, j);
   if (!is_allowed_move(move, globalGameInfo.to_move)) return -2;
   globalPasses = 0;
   gnugo_play_move(move, globalGameInfo.to_move);
   sgffile_add_debuginfo(globalSgfTree.lastnode, 0.0);
   sgftreeAddPlay(&globalSgfTree, globalGameInfo.to_move, I(move), J(move));
   sgffile_output(&globalSgfTree);
   globalGameInfo.to_move = OTHER_COLOR(globalGameInfo.to_move);
   return 0;
}

void EMSCRIPTEN_KEEPALIVE finalizeGoGame() {
   // report_pattern_profiling();
   sgfFreeNode(globalSgfTree.root);
}
