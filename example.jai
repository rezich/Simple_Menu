options: struct {
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
}

OPTIONS_POINTER :: *options;

antialiasing: bool;
quality:      enum { LOW; MEDIUM; HIGH; } = .MEDIUM;


MENU :: struct {
    Menu_Item  :: Open_Linear_Menu.Item;
    I/*tem  */ :: make_linear_menu_item;
    A/*ction*/ :: make_linear_menu_item_from_code;

    MAIN :: Linear_Menu("Main Menu",
        #run A("New Game" , #code { MENU.SELECT_DIFFICULTY.open(); }),
        #run A("Load Game", #code { MENU.SELECT_SAVE_SLOT.open();  }),
        #run A("Options"  , #code { MENU.OPTIONS.open();           }),
        #run A("Quit"     , #code { MENU.CONFIRM_QUIT.open();      }),
        on_cancel=() { MENU.CONFIRM_QUIT.open(); }
    );
    SELECT_DIFFICULTY :: Linear_Menu("Select Difficulty",
        #run A("I'm too young to die", #code { start_new_game(0); }),
        #run A("Hey, not too rough"  , #code { start_new_game(1); }),
        #run A("Hurt me plenty"      , #code { start_new_game(2); }),
        #run A("Ultra-Violence"      , #code { start_new_game(3); }),
        #run A("Nightmare!"          , #code { start_new_game(4); }),
    );
    SELECT_SAVE_SLOT :: Linear_Menu("Select Save Slot",
        #run A("Slot A", #code { load_game_from_slot(0); }),
        #run A("Slot B", #code { load_game_from_slot(1); }),
        #run A("Slot C", #code { load_game_from_slot(2); }),
    );
    OPTIONS :: Linear_Menu("Options",
        #run A("Gameplay", #code { MENU.GAMEPLAY_OPTIONS.open(); }),
        #run A("Graphics", #code { MENU.GRAPHICS_OPTIONS.open(); }),
        #run A("Sound"   , #code { MENU.SOUND\  _OPTIONS.open(); }),
    );
    GAMEPLAY_OPTIONS :: Linear_Menu("Gameplay Options",
        #run I("Gore",          *options.gameplay.gore         ),
        #run I("Toggle crouch", *options.gameplay.toggle_crouch)
    );
    GRAPHICS_OPTIONS :: Linear_Menu("Graphics Options",
        #run I("Antialiasing", *options.graphics.antialiasing),
        #run I("Quality"     , *options.graphics.quality     )
    );
    SOUND_OPTIONS :: Linear_Menu("Sound Options",
        #run I("Speaker configuration", *options.sound.speaker_configuration),
        #run I("Subtitles",             *options.sound.subtitles            )
    );
    CONFIRM_QUIT :: Linear_Menu("Are you sure you want to quit?",
        #run A("Yes", #code,null             ),
        #run A("No" , #code { close_menu(); })
    );
}

start_new_game :: (difficulty: int) { close_all_menus(); }
load_game_from_slot ::  (slot: int) { close_all_menus(); }

main :: () {
    log("OPTIONS_POINTER: %", OPTIONS_POINTER);
    MENU.MAIN.open();

    menu_down();
    menu_down();
    menu_select();
    menu_down();
    menu_select();
    menu_select();
    menu_select();
    menu_select();
    menu_down();
    menu_select();
    menu_select();
    menu_select();

    report_memory_leaks();
}

#import "Basic"()(MEMORY_DEBUGGER=true);
#import,dir "../Linear_Menu"(MAX_ITEMS_PER_MENU=5, DEBUG_RENDERING=true);
