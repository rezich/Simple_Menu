MAIN_MENU :: Linear_Menu("Main Menu",
    Linear_Menu_Item.{"New Game"    , .DEFAULT},
    Linear_Menu_Item.{"Load Game"   , .DEFAULT},
    Linear_Menu_Item.{"Options"     , .DEFAULT},
    Linear_Menu_Item.{"Quit"        , .DEFAULT}
);



main :: () {
    MAIN_MENU.open();



    report_memory_leaks();
}






#import "Basic"()(MEMORY_DEBUGGER=true);
#import,dir "../Linear_Menu";