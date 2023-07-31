#module_parameters(MAX_MENUS := 8, MAX_ITEMS_PER_MENU := 4, DEBUG_RENDERING := false);

Simple_Menu :: struct(
    title: string,
    items: ..Simple_Menu_Item,
    on_cancel: () = close_menu
) #modify {
    assert(items.count <= MAX_ITEMS_PER_MENU, "Added too many menu items -- increase MAX_ITEMS_PER_MENU to a number higher than %!", MAX_ITEMS_PER_MENU);
    return true;
} {
    THIS_MENU :: #this; // unused...

    open :: () {
        using menu_handler;
        current_menu_index += 1;
        assert(current_menu_index <= MAX_MENUS, "Opened too many menus -- increase MAX_MENUS to a number higher than %!", MAX_MENUS);

        menu := *open_menus[current_menu_index];
        menu.title = title;
        menu.on_cancel = on_cancel;
        menu.item_count = items.count;
        menu.cursor = 0;

        for * items {
            item := *menu.items[it_index];
            item.definition = it;
            item.disabled = false;
        }

        #if DEBUG_RENDERING then debug_render_current_menu();
    }
}

close_menu :: () {
    using menu_handler;
    assert(current_menu_index > -1);
    current_menu_index -= 1;
    #if DEBUG_RENDERING then debug_render_current_menu();
}

close_all_menus :: () { menu_handler.current_menu_index = -1; }

menu_prev :: () {
    using menu_handler;
    if current_menu_index == -1 then return;
    menu := *open_menus[current_menu_index];
    while true {
        menu.cursor -= 1;
        if menu.cursor < 0 then menu.cursor += menu.item_count;
        if !menu.items[menu.cursor].disabled break;
    }
    #if DEBUG_RENDERING then debug_render_current_menu();
}
menu_next :: () {
    using menu_handler;
    if current_menu_index == -1 then return;
    menu := *open_menus[current_menu_index];
    while true {
        menu.cursor += 1;
        if menu.cursor >= menu.item_count then menu.cursor -= menu.item_count;
        if !menu.items[menu.cursor].disabled then break;
    }
    #if DEBUG_RENDERING then debug_render_current_menu();
}
menu_select :: () {
    using menu_handler;
    if current_menu_index == -1 then return;
    menu := *open_menus[current_menu_index];
    proc := menu.items[menu.cursor].on_select;
    item := *menu.items[menu.cursor];
    if proc then proc(item);
}
menu_cancel :: () {
    using menu_handler;
    if current_menu_index == -1 then return;
    proc := open_menus[current_menu_index].on_cancel;
    if proc then proc();
}

Simple_Menu_Item :: struct {
    text: string;
    kind: Kind;
    Kind :: enum {
        DEFAULT;
        CHECKBOX;
        LIST;
    }
    on_select: (item: *Open_Simple_Menu.Item);
    data: Data;
    Data :: struct {
        pointer_to_value: *int;
        highest_value: int;
        value_to_string: (int) -> string;
    }
}

// generic menu item
make_simple_menu_item :: (text: string, on_select: (*Open_Simple_Menu.Item)) -> Simple_Menu_Item {
    item: Simple_Menu_Item;
    item.text = text;
    item.kind = .DEFAULT;
    item.on_select = on_select;
    return item;
}

// use this if on_select doesn't need the menu item
make_simple_menu_item :: (text: string, on_select: ()) -> Simple_Menu_Item {
    return make_simple_menu_item(text, cast((*Open_Simple_Menu.Item)) on_select);
}

// experimental...
make_simple_menu_item_from_code :: (text: string, on_select_code: Code) -> Simple_Menu_Item #expand {
    on_select :: (item: *Open_Simple_Menu.Item) { #insert on_select_code; }
    return make_simple_menu_item(text, on_select);
}

// checkbox
make_simple_menu_item :: (text: string, pointer_to_bool: *bool) -> Simple_Menu_Item {
    toggle_bool :: (item: *Open_Simple_Menu.Item) {
        (cast(*bool) item.data.pointer_to_value).* = !(cast(*bool) item.data.pointer_to_value).*;
        #if DEBUG_RENDERING then debug_render_current_menu();
    }
    item: Simple_Menu_Item;
    item.text = text;
    item.kind = .CHECKBOX;
    item.on_select = toggle_bool;
    item.data.pointer_to_value = cast(*int) pointer_to_bool;
    log("CHECKBOX %: %", item.text, item.data.pointer_to_value);
    return item;
}

// integer
/*make_simple_menu_item :: (text: string, pointer_to_value: *int, highest_value: int, value_to_string: (int) -> string = null) -> Simple_Menu_Item {
    toggle_int :: (item: *Open_Simple_Menu.Item) {
        new_value := item.data.pointer_to_value.* + 1;
        if new_value > item.data.highest_value then new_value = 0;
        item.data.pointer_to_value.* = new_value;
        #if DEBUG_RENDERING then debug_render_current_menu();
    }
    item: Simple_Menu_Item;
    item.text = text;
    item.kind = .LIST;
    item.on_select = toggle_int;
    item.data.pointer_to_value = pointer_to_value;
    item.data.highest_value = highest_value;
    item.data.value_to_string = value_to_string;
    return item;
}*/

// enum
make_simple_menu_item :: (text: string, $$pointer_to_enum: *$T, value_to_string: (int) -> string = null) -> Simple_Menu_Item
    #modify { return (cast(*Type_Info) T).type == .ENUM; }
{
    toggle :: (item: *Open_Simple_Menu.Item) {
        log("TOGGLING");
        value := (cast(*T) item.data.pointer_to_value).*;
        values := enum_values_as_enum(T);
        for values if it == value {
            next_index := it_index + 1;
            if next_index >= values.count then next_index = 0;
            value = values[next_index];
            break;
        }
        item.data.pointer_to_value.* = cast(int) value;
        #if DEBUG_RENDERING then debug_render_current_menu();
    }

    default_value_to_string :: (value: int) -> string { return tprint("%", cast(T) value); }

    log("\n--\n%", pointer_to_enum);
    item: Simple_Menu_Item;
    item.text = text;
    item.kind = .LIST;
    item.on_select = toggle;
    item.data.pointer_to_value = xx pointer_to_enum;
    item.data.value_to_string = ifx value_to_string else default_value_to_string;
    log("LIST     %: %\n--\n\n", item.text, item.data.pointer_to_value);
    return item;
}


Open_Simple_Menu :: struct {
    title: string;
    items: [MAX_ITEMS_PER_MENU] Item;
    item_count: int;
    on_cancel: ();
    cursor: int;

    Item :: struct {
        using definition: *Simple_Menu_Item;
        disabled: bool;
    }
};

#scope_module

menu_handler: struct {
    open_menus: [MAX_MENUS] Open_Simple_Menu;
    current_menu_index := -1;
}

debug_render_current_menu :: () {
    get_value :: (item: Open_Simple_Menu.Item) -> string {
        if item.kind == {
            case .DEFAULT; return "";
            case .CHECKBOX; return tprint("[%]", ifx (cast(*bool) item.data.pointer_to_value).* then "X" else " ");
            case .LIST;
                if item.data.value_to_string then return item.data.value_to_string(item.data.pointer_to_value.*);
                else return tprint("%", item.data.pointer_to_value.*);
        }
        return "";
    }
    using menu_handler;
    if current_menu_index == -1 then return;
    menu := *open_menus[current_menu_index];
    log("\n\n%\n----", menu.title);

    for 0..menu.item_count-1 log("%5 %1 %2%3%4",
    /* 1 */ ifx it == menu.cursor then "->" else "  ",
    /* 2 */ menu.items[it].text,
    /* 3 */ ifx menu.items[it].kind != .DEFAULT then ": " else "",
    /* 4 */ ifx menu.items[it].kind != .DEFAULT then get_value(menu.items[it]),
    /* 5 */ menu.items[it].data.pointer_to_value
    );
    log("\n\n");
}

#import "Basic";
