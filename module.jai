#module_parameters(MAX_MENUS := 8, MAX_ITEMS_PER_MENU := 4);

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

        open_menus[current_menu_index].title = title;
        open_menus[current_menu_index].on_cancel = on_cancel;
        open_menus[current_menu_index].item_count = items.count;
        for * items open_menus[current_menu_index].items[it_index].definition = it;

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

menu_up :: () {
    using menu_handler;
    if current_menu_index == -1 then return;
    while true {
        menu := *open_menus[current_menu_index];
        menu.cursor -= 1;
        if menu.cursor < 0 then menu.cursor = menu.item_count-1;
        /*if !open_menus[current_menu_index].items[open_menus[current_menu_index].cursor].disabled then */break;
    }
}
menu_down :: () {
    using menu_handler;
    if current_menu_index == -1 then return;
    menu := *open_menus[current_menu_index];
    log("before: %", menu.cursor);
    while true {
        menu.cursor += 1;
        if menu.cursor >= menu.item_count then menu.cursor = 0;
        /*if !open_menus[current_menu_index].items[open_menus[current_menu_index].cursor].disabled then */break;
    }
    log("after: %", menu.cursor);
}
menu_select :: () {
    using menu_handler;
    if current_menu_index == -1 then return;
    menu := *open_menus[current_menu_index];
    log("didn't return, cursor: %", menu.cursor);
    proc := menu.items[menu.cursor].on_select;
    item := *menu.items[menu.cursor];
    log("proc: %", proc);
    if !!proc then proc(item);
}
menu_cancel :: () {
    using menu_handler;
    if current_menu_index == -1 then return;
    proc := open_menus[current_menu_index].on_cancel;
    if !!proc then proc();
}

Linear_Menu_Item :: struct {
    text: string;
    kind: Kind;
    Kind :: enum {
        DEFAULT;
        CHECKBOX;
    }
    on_select: (item: *Menu_Item);
}

Menu_Item :: struct {
    using definition: *Linear_Menu_Item;
}

menu_handler: struct {
    open_menus: [MAX_MENUS] struct {
        title: string;
        items: [MAX_ITEMS_PER_MENU] Menu_Item;
        item_count: int;
        on_cancel: ();
        cursor: int;
    };
    current_menu_index := -1;
}

#import "Basic";
