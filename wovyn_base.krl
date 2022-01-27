ruleset wovyn_base {
    meta {
        name "Wovyn Base"
        description << Ruleset for Wovyn Base >>
        author "Cameron Brown"
    }
    rule process_heartbeat {
        select when wovyn heartbeat
        pre {
            msg = "The current temperature is: "
        }
        send_directive(msg)
    }
}