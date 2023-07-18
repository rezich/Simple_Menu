antialiasing: bool;
quality: enum { LOW; MEDIUM; HIGH; };

options: struct {
    gameplay: struct {
        gore:          bool = true;
        toggle_crouch: bool;
        show_tips:     enum { NEVER; FIRST_TIME_ONLY; ALWAYS; } = .ALWAYS;
    }
    graphics: struct {
        antialiasing: bool;
        quality: enum { LOW; MEDIUM; HIGH; };
    }
};

OPTIONS_POINTER :: *options;

proc :: (pointer_to_bool: *bool) {
    log("bool: %", pointer_to_bool);
}
proc :: (pointer_to_enum: *$T) #modify { return (cast(*Type_Info) T).type == .ENUM; } {
    log("enum: %", pointer_to_enum);
}

main :: () {
    #run {
        proc(*antialiasing);
        proc(*quality);
        proc(*options.graphics.antialiasing);
        proc(*options.graphics.quality);
        log("OPTIONS_POINTER: %", OPTIONS_POINTER);
    }
    log("OPTIONS_POINTER: %", OPTIONS_POINTER);

    proc(*antialiasing);
    proc(*quality);

    proc(*options.graphics.antialiasing);
    proc(*options.graphics.quality);
}

#import "Basic";