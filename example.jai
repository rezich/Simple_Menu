// there is a compiler bug that prevents this anonymous struct from working with
// this menu system
/*options: struct {
    gameplay: struct {
        gore:          bool = true;
        toggle_crouch: bool;
        show_tips:     enum { NEVER; FIRST_TIME_ONLY; ALWAYS; } = .ALWAYS;
    }
    graphics: struct {
        antialiasing: bool;
        quality:      enum { LOW; MEDIUM; HIGH; } = .MEDIUM;
    }
    sound: struct {
        speaker_configuration: enum { DESKTOP; SURROUND; HEADPHONES; }
        subtitles:             bool;
    }
}*/

// so, for now, let's just have the settings be unstructured globals:

// gameplay
gore:                  bool                                           = true;
toggle_crouch:         bool;
show_tips:             enum { NEVER;   FIRST_TIME_ONLY; ALWAYS;     } = .ALWAYS;
// graphics
antialiasing:          bool;
quality:               enum { LOW;     MEDIUM;          HIGH;       } = .MEDIUM;
// sound
speaker_configuration: enum { DESKTOP; SURROUND;        HEADPHONES; }
subtitles:             bool;


MENU :: struct {
    M/*enu  */ :: Simple_Menu;
    I/*tem  */ :: make_simple_menu_item;

    MAIN ::
        M("Main Menu",
        #run I("New Game" , () { MENU.SELECT_DIFFICULTY.open(); }),
        #run I("Load Game", () { MENU.SELECT_SAVE_SLOT.open();  }),
        #run I("Options"  , () { MENU.OPTIONS.open();           }),
        #run I("Quit"     , () { MENU.CONFIRM_QUIT.open();      }),
        on_cancel=() { MENU.CONFIRM_QUIT.open(); }
    );
    SELECT_DIFFICULTY ::
        M("Select Difficulty",
        #run I("I'm too young to die", () { start_new_game(0); }),
        #run I("Hey, not too rough"  , () { start_new_game(1); }),
        #run I("Hurt me plenty"      , () { start_new_game(2); }),
        #run I("Ultra-Violence"      , () { start_new_game(3); }),
        #run I("Nightmare!"          , () { start_new_game(4); }),
    );
    SELECT_SAVE_SLOT ::
        M("Select Save Slot",
        #run I("Slot A", () { load_game_from_slot(0); }),
        #run I("Slot B", () { load_game_from_slot(1); }),
        #run I("Slot C", () { load_game_from_slot(2); }),
    );
    OPTIONS ::
        M("Options",
        #run I("Gameplay", () { MENU.GAMEPLAY_OPTIONS.open(); }),
        #run I("Graphics", () { MENU.GRAPHICS_OPTIONS.open(); }),
        #run I("Sound"   , () { MENU.SOUND\  _OPTIONS.open(); }),
    );
    GAMEPLAY_OPTIONS ::
        M("Gameplay Options",
        #run I("Gore",          */*options.gameplay.*/gore         ),
        #run I("Toggle crouch", */*options.gameplay.*/toggle_crouch),
    );
    GRAPHICS_OPTIONS ::
        M("Graphics Options",
        #run I("Antialiasing", */*options.graphics.*/antialiasing),
        #run I("Quality"     , */*options.graphics.*/quality     ),
    );
    SOUND_OPTIONS ::
        M("Sound Options",
        #run I("Speaker configuration", */*options.sound.*/speaker_configuration),
        #run I("Subtitles",             */*options.sound.*/subtitles            ),
    );
    CONFIRM_QUIT ::
        M("Are you sure you want to quit?",
        #run I("Yes", () { /*  TODO   */ }),
        #run I("No" , () { close_menu(); }),
    );
}

start_new_game :: (difficulty: int) { close_all_menus(); }
load_game_from_slot ::  (slot: int) { close_all_menus(); }

main :: () {
    up   :: menu_prev;
    down :: menu_next;
    o    :: menu_select;
    x    :: menu_cancel;

    MENU.MAIN.open();

    down();
    down();
    o();
    down();
    o();
    o();
    o();
    o();
    down();
    o();
    o();
    o();

    report_memory_leaks();
}

#import "Basic"()(MEMORY_DEBUGGER=true);
#import,dir "../Simple_Menu"(MAX_ITEMS_PER_MENU=5, DEBUG_RENDERING=true);
