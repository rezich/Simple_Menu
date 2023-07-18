#module_parameters(MAX_MENUS := 8, MAX_ITEMS_PER_MENU := 4);

menu_handler: struct {
    open_menus: [MAX_MENUS] Open_Menu;
    current_menu_index := -1;

    Open_Menu :: struct {
        title: string;
        items: [MAX_ITEMS_PER_MENU] Item;
        item_count: int;
        on_cancel: ();
        cursor: int;

        Item :: struct {
            //definition: *Linear_Menu_Item;
        }
    }
}

Linear_Menu :: struct(
    title: string,
    items: ..Linear_Menu_Item,
    on_cancel: () = close_menu
) {
    THIS_MENU :: #this;

    open :: () {
        using menu_handler;
        current_menu_index += 1;
        assert(current_menu_index <= MAX_MENUS, "Opened too many menus -- increase MAX_MENUS to a number higher than %!", MAX_MENUS);
        
        log("This: %", #this);
        //log("This menu: %", THIS_MENU);

        log("OPENING: %", title);
    }
}

close_menu :: () {
    using menu_handler;
    assert(current_menu_index > -1);
    log("CLOSING %", open_menus[current_menu_index].title);
    current_menu_index -= 1;
    if current_menu_index > -1 then log("BACK TO %", open_menus[current_menu_index].title);
}

Linear_Menu_Item :: struct {
    text: string;
    kind: Kind;
    Kind :: enum {
        DEFAULT;
        CHECKBOX;
    }
}

#import "Basic";
