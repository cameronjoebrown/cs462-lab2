ruleset wovyn_base {
    meta {
        name "Wovyn Base"
        description << Ruleset for Wovyn Base >>
        author "Cameron Brown"
    }
    rule process_heartbeat {
        select when wovyn heartbeat
        pre {
            log = event:attrs.klog("attrs")
            msg = "The current temperature is: ".klog()
        }
        if event:attrs{"genericThing"} then send_directive("wovyn heartbeat", {"body": msg});
        fired {
            raise wovyn event "new_temperature_reading" attributes {
                "temperature" : event:attrs{"genericThing"}{"data"}{"temperature"}[0]{"temperatureF"},
                "timestamp" : time:now()
            }
        }
    }
}