I :: Linear_Menu_Item;

MENU :: struct {
    MAIN :: Linear_Menu("Main Menu",
        I.{"New Game"    , .DEFAULT, null},
        I.{"Load Game"   , .DEFAULT, null},
        I.{"Options"     , .DEFAULT, (item: *Menu_Item) {
            log("Hello");
        }},
        I.{"Quit"        , .DEFAULT, null}
    );
}





main :: () {
    MENU.MAIN.open();

    log("MENU TITLE: %", menu_handler.open_menus[menu_handler.current_menu_index]);

    menu_down();
    menu_down();
    menu_select();

    report_memory_leaks();
}






#import "Basic"()(MEMORY_DEBUGGER=true);
#import,dir "../Linear_Menu";