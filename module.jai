#module_parameters(MAX_MENUS := 8, MAX_ITEMS_PER_MENU := 4, DEBUG_RENDERING := false);

Linear_Menu :: struct(
    title: string,
    items: ..Linear_Menu_Item,
    on_cancel: () = close_menu
) #modify {
    assert(items.count <= MAX_ITEMS_PER_MENU, "Added too many menu items -- increase MAX_ITEMS_PER_MENU to a number higher than %!", MAX_ITEMS_PER_MENU);
    return true;
} {
    THIS_MENU :: #this;

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

menu_up :: () {
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
menu_down :: () {
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

Linear_Menu_Item :: struct {
    text: string;
    kind: Kind;
    Kind :: enum {
        DEFAULT;
        CHECKBOX;
        LIST;
    }
    on_select: (item: *Open_Linear_Menu.Item);
    data: Data;
    Data :: struct {
        pointer_to_bool: *bool;
        pointer_to_value: *int;
        highest_value: int;
        value_to_string: (int) -> string;
    }
}

// generic menu item
make_linear_menu_item :: (text: string, on_select: (*Open_Linear_Menu.Item)) -> Linear_Menu_Item {
    item: Linear_Menu_Item;
    item.text = text;
    item.kind = .DEFAULT;
    item.on_select = on_select;
    return item;
}
make_linear_menu_item_from_code :: (text: string, on_select_code: Code) -> Linear_Menu_Item #expand {
    on_select :: (item: *Open_Linear_Menu.Item) {
        #insert on_select_code;
    }
    return make_linear_menu_item(text, on_select);
}

// checkbox
make_linear_menu_item :: (text: string, pointer_to_bool: *bool) -> Linear_Menu_Item {
    toggle_bool :: (item: *Open_Linear_Menu.Item) {
        item.data.pointer_to_bool.* = !item.data.pointer_to_bool.*;
        #if DEBUG_RENDERING then debug_render_current_menu();
    }

    item: Linear_Menu_Item;
    item.text = text;
    item.kind = .CHECKBOX;
    item.on_select = toggle_bool;
    item.data.pointer_to_bool = pointer_to_bool;
    return item;
}

// integer
make_linear_menu_item :: (text: string, pointer_to_value: *int, highest_value: int, value_to_string: (int) -> string = null) -> Linear_Menu_Item {
    toggle_int :: (item: *Open_Linear_Menu.Item) {
        new_value := item.data.pointer_to_value.* + 1;
        if new_value > item.data.highest_value then new_value = 0;
        item.data.pointer_to_value.* = new_value;
        #if DEBUG_RENDERING then debug_render_current_menu();
    }
    item: Linear_Menu_Item;
    item.text = text;
    item.kind = .LIST;
    item.on_select = toggle_int;
    item.data.pointer_to_value = pointer_to_value;
    item.data.highest_value = highest_value;
    item.data.value_to_string = value_to_string;
    return item;
}

// enum
make_linear_menu_item :: (text: string, pointer_to_enum: *$T, value_to_string: (int) -> string = null) -> Linear_Menu_Item #modify {
    info := cast(*Type_Info) T;
    return info.type == .ENUM;
} {
    toggle :: (item: *Open_Linear_Menu.Item) {
        value := (cast(*T) item.data.pointer_to_value).*;
        values := enum_values_as_enum(T);
        for values if it == value {
            next_index := it_index + 1;
            if next_index >= values.count then next_index = 0;
            value = values[next_index];
            break;
        }
        item.data.pointer_to_value.* = xx value;
        #if DEBUG_RENDERING then debug_render_current_menu();
    }

    default_value_to_string :: (value: int) -> string { return tprint("%", cast(T) value); }

    item: Linear_Menu_Item;
    item.text = text;
    item.kind = .LIST;
    item.on_select = toggle;
    item.data.pointer_to_value = xx pointer_to_enum;
    item.data.value_to_string = ifx value_to_string else default_value_to_string;
    return item;
}


Open_Linear_Menu :: struct {
    title: string;
    items: [MAX_ITEMS_PER_MENU] Item;
    item_count: int;
    on_cancel: ();
    cursor: int;

    Item :: struct {
        using definition: *Linear_Menu_Item;
        disabled: bool;
    }
};

#scope_module

menu_handler: struct {
    open_menus: [MAX_MENUS] Open_Linear_Menu;
    current_menu_index := -1;
}

debug_render_current_menu :: () {
    get_value :: (item: Open_Linear_Menu.Item) -> string {
        if item.kind == {
            case .DEFAULT; return "";
            case .CHECKBOX; return tprint("[%]", ifx item.data.pointer_to_bool.* then "X" else " ");
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

    for 0..menu.item_count-1 log("%1 %2%3%4",
    /* 1 */ ifx it == menu.cursor then "->" else "  ",
    /* 2 */ menu.items[it].text,
    /* 3 */ ifx menu.items[it].kind != .DEFAULT then ": " else "",
    /* 4 */ ifx menu.items[it].kind != .DEFAULT then get_value(menu.items[it])
    );
    log("\n\n");
}

#import "Basic";
